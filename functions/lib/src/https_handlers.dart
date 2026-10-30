import 'dart:convert';
import 'dart:io' show Platform;
import 'package:firebase_functions/firebase_functions.dart';
import 'package:firebase_functions/logger.dart' as logger;
import 'event_handlers.dart';
import 'registration_handlers.dart';

/// Helper to recursively unwrap Firestore REST / CloudEvent value encodings
/// (e.g. `{"stringValue": "val"}`, `{"booleanValue": true}`).
dynamic unwrapFirestoreValue(dynamic val) {
  if (val is Map<String, dynamic>) {
    if (val.containsKey('stringValue')) return val['stringValue'];
    if (val.containsKey('booleanValue')) return val['booleanValue'];
    if (val.containsKey('integerValue')) return int.tryParse(val['integerValue'].toString());
    if (val.containsKey('doubleValue')) return double.tryParse(val['doubleValue'].toString());
    if (val.containsKey('timestampValue')) return val['timestampValue'];
    if (val.containsKey('mapValue') && val['mapValue'] is Map<String, dynamic>) {
      final fields = val['mapValue']['fields'];
      if (fields is Map<String, dynamic>) {
        return fields.map((k, v) => MapEntry(k, unwrapFirestoreValue(v)));
      }
    }
    if (val.containsKey('arrayValue') && val['arrayValue'] is Map<String, dynamic>) {
      final values = val['arrayValue']['values'];
      if (values is List) {
        return values.map(unwrapFirestoreValue).toList();
      }
      return [];
    }
  }
  return val;
}

/// Unwraps a map of Firestore fields into plain Dart values.
Map<String, dynamic> unwrapFirestoreFields(Map<String, dynamic>? fields) {
  if (fields == null) return <String, dynamic>{};
  return fields.map((k, v) => MapEntry(k, unwrapFirestoreValue(v)));
}

/// Normalized payload extracted from an incoming HTTPS or CloudEvent/Eventarc request.
class NotificationPayload {
  final String? sectionId;
  final String? eventId;
  final String? registrationId;
  final String? userId;
  final String? status;
  final String? beforeStatus;
  final String? afterStatus;
  final String? authId;
  final String? title;
  final String? eventType;
  final Map<String, dynamic> data;
  final Map<String, dynamic> beforeData;
  final Map<String, dynamic> afterData;

  NotificationPayload({
    this.sectionId,
    this.eventId,
    this.registrationId,
    this.userId,
    this.status,
    this.beforeStatus,
    this.afterStatus,
    this.authId,
    this.title,
    this.eventType,
    this.data = const {},
    this.beforeData = const {},
    this.afterData = const {},
  });
}

final _documentPathRegex = RegExp(
  r'sections/([^/]+)/events/([^/]+)(?:/registrations/([^/]+))?',
);

/// Environment variable that, when set, requires non-CloudEvent callers
/// (manual replay / webhooks) to present a shared secret. Eventarc does not
/// support custom headers, so this is only for callers you control.
const _webhookSecretEnv = 'NOTIFICATION_WEBHOOK_SECRET';

/// Lightweight, defence-in-depth verification for the notification endpoints.
///
/// The real security boundary is Cloud Run IAM: the service must not grant
/// `roles/run.invoker` to `allUsers`, and Eventarc attaches a Google-signed
/// OIDC token that Cloud Run validates before the request reaches this code.
/// This check only rejects requests that clearly did not come from the
/// expected event pipeline:
///
///  * non-`POST` requests (the `GET` readiness probe is still allowed);
///  * requests without a bearer token when running on Cloud Run;
///  * CloudEvents whose `ce-source`/`ce-type` are not Firestore document
///    events;
///  * on Cloud Run, non-CloudEvent callers unless they present a matching
///    `x-notification-secret` (`NOTIFICATION_WEBHOOK_SECRET`);
///  * elsewhere, non-CloudEvent callers when a webhook secret is configured
///    and does not match.
///
/// Returns a [Response] to send when the request should be rejected, or `null`
/// when it may proceed.
///
/// TODO(security): migrate these endpoints to native Firestore triggers
/// (`onDocumentCreated`/`onDocumentUpdated`/`onDocumentDeleted`) when the Dart
/// `firebase_functions` package supports deploying them in production. That
/// removes the public HTTP surface entirely. Until then, keep the Cloud Run
/// invoker restricted to the Eventarc service account and do not grant it to
/// `allUsers`.
Response? verifyNotificationRequest(
  Request request, {
  bool? isCloudRun,
  String? webhookSecret,
}) {
  final method = request.method.toUpperCase();
  if (method == 'GET') return null; // readiness probe
  if (method != 'POST') {
    return _jsonError('Method not allowed', statusCode: 405);
  }

  // `K_SERVICE` is set by Cloud Run for every running revision. Ignore it in
  // the emulator so local/manual calls do not need a bearer token.
  final isEmulator = Platform.environment['FUNCTIONS_EMULATOR'] == 'true';
  final onCloudRun = isCloudRun ?? (Platform.environment.containsKey('K_SERVICE') && !isEmulator);
  if (onCloudRun) {
    final auth = request.headers['authorization'] ?? '';
    if (!auth.startsWith('Bearer ')) {
      return _jsonError('Missing or invalid Authorization header', statusCode: 401);
    }
  }

  final isCloudEvent = request.headers.containsKey('ce-specversion') ||
      (request.headers['content-type'] ?? '').startsWith('application/cloudevents');

  if (isCloudEvent) {
    final source = request.headers['ce-source'];
    if (source != null && !source.startsWith('//firestore.googleapis.com/projects/')) {
      return _jsonError('Unexpected CloudEvent source', statusCode: 403);
    }
    final type = request.headers['ce-type'];
    if (type != null && !type.startsWith('google.cloud.firestore.document.v1.')) {
      return _jsonError('Unexpected CloudEvent type', statusCode: 403);
    }
    return null;
  }

  // Direct JSON (manual replay / webhook) is only allowed when the caller
  // proves it knows the shared secret. On Cloud Run this is mandatory so a
  // stray HTTP call cannot masquerade as an event.
  final secret = webhookSecret ?? Platform.environment[_webhookSecretEnv];
  final hasSecret = secret != null && secret.isNotEmpty;
  final provided = request.headers['x-notification-secret'] ?? '';
  if (hasSecret && _constantTimeEquals(provided, secret)) return null;
  if (onCloudRun) {
    return _jsonError('Expected a CloudEvent or a valid webhook secret', statusCode: 403);
  }
  if (hasSecret) {
    return _jsonError('Unauthorized', statusCode: 401);
  }

  return null;
}

bool _constantTimeEquals(String a, String b) {
  if (a.length != b.length) return false;
  var diff = 0;
  for (var i = 0; i < a.length; i++) {
    diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
  }
  return diff == 0;
}

/// Extracts payload fields from an HTTP [Request].
///
/// Supports:
/// 1. Direct JSON body (`{"sectionId": "...", "eventId": "...", ...}`).
/// 2. Eventarc CloudEvent binary mode (`ce-type`, `ce-subject`, `ce-document`, etc.).
/// 3. Eventarc CloudEvent structured mode (`{"type": "...", "subject": "...", "data": {...}}`).
/// 4. Query parameters for GET / test requests.
Future<NotificationPayload> parseNotificationRequest(Request request) async {
  Map<String, dynamic> body = {};
  if (request.method.toUpperCase() != 'GET') {
    final raw = await request.readAsString();
    if (raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          body = decoded;
        }
      } catch (e) {
        logger.info('Failed to parse request JSON body: $e');
      }
    }
  }

  // ── 1. CloudEvent / Eventarc headers ───────────────────────────────────────
  final ceType = request.headers['ce-type'] ?? body['type']?.toString();
  final ceSubject = request.headers['ce-subject'] ??
      request.headers['ce-document'] ??
      body['subject']?.toString() ??
      body['document']?.toString();
  final ceAuthId = request.headers['ce-authid'] ?? body['authId']?.toString();

  // Try extracting path IDs from subject or document path
  String? pathSectionId;
  String? pathEventId;
  String? pathRegistrationId;

  if (ceSubject != null) {
    final match = _documentPathRegex.firstMatch(ceSubject);
    if (match != null) {
      pathSectionId = match.group(1);
      pathEventId = match.group(2);
      pathRegistrationId = match.group(3);
    }
  }

  // ── 2. Firestore CloudEvent / REST data unwrap ─────────────────────────────
  Map<String, dynamic> extractedData = {};
  Map<String, dynamic> extractedBefore = {};
  Map<String, dynamic> extractedAfter = {};

  final rawData = body['data'];
  if (rawData is Map<String, dynamic>) {
    // CloudEvent structured data
    if (rawData.containsKey('value') || rawData.containsKey('oldValue')) {
      final valueObj = rawData['value'];
      if (valueObj is Map<String, dynamic>) {
        if (valueObj['fields'] is Map<String, dynamic>) {
          extractedAfter = unwrapFirestoreFields(valueObj['fields'] as Map<String, dynamic>);
        }
        if (pathSectionId == null && valueObj['name'] is String) {
          final match = _documentPathRegex.firstMatch(valueObj['name'] as String);
          if (match != null) {
            pathSectionId = match.group(1);
            pathEventId = match.group(2);
            pathRegistrationId = match.group(3);
          }
        }
      }
      final oldValueObj = rawData['oldValue'];
      if (oldValueObj is Map<String, dynamic>) {
        if (oldValueObj['fields'] is Map<String, dynamic>) {
          extractedBefore = unwrapFirestoreFields(oldValueObj['fields'] as Map<String, dynamic>);
        }
      }
      extractedData = extractedAfter.isNotEmpty ? extractedAfter : extractedBefore;
    } else {
      extractedData = rawData;
    }
  }

  if (body['before'] is Map<String, dynamic>) {
    extractedBefore = body['before'] as Map<String, dynamic>;
  }
  if (body['after'] is Map<String, dynamic>) {
    extractedAfter = body['after'] as Map<String, dynamic>;
  }

  final query = request.url.queryParameters;

  final sectionId = body['sectionId']?.toString() ?? query['sectionId'] ?? pathSectionId;
  final eventId = body['eventId']?.toString() ?? query['eventId'] ?? pathEventId;
  final registrationId = body['registrationId']?.toString() ?? query['registrationId'] ?? pathRegistrationId;
  final userId = body['userId']?.toString() ??
      extractedData['userId']?.toString() ??
      extractedAfter['userId']?.toString() ??
      query['userId'] ??
      registrationId;

  final status = body['status']?.toString() ??
      extractedData['status']?.toString() ??
      extractedAfter['status']?.toString() ??
      query['status'];

  final beforeStatus = body['beforeStatus']?.toString() ??
      extractedBefore['status']?.toString() ??
      query['beforeStatus'];

  final afterStatus = body['afterStatus']?.toString() ??
      extractedAfter['status']?.toString() ??
      status ??
      query['afterStatus'];

  final authId = ceAuthId ?? body['authId']?.toString() ?? query['authId'];
  final title = body['title']?.toString() ??
      extractedData['title']?.toString() ??
      extractedAfter['title']?.toString() ??
      query['title'];

  final eventType = body['action']?.toString() ??
      body['eventType']?.toString() ??
      ceType ??
      query['action'];

  return NotificationPayload(
    sectionId: sectionId,
    eventId: eventId,
    registrationId: registrationId,
    userId: userId,
    status: status,
    beforeStatus: beforeStatus,
    afterStatus: afterStatus,
    authId: authId,
    title: title,
    eventType: eventType,
    data: extractedData,
    beforeData: extractedBefore,
    afterData: extractedAfter,
  );
}

Response _jsonOk(Map<String, dynamic> data) => Response.ok(
      jsonEncode(data),
      headers: {'content-type': 'application/json'},
    );

Response _jsonError(String message, {int statusCode = 400}) => Response(
      statusCode,
      body: jsonEncode({'error': message}),
      headers: {'content-type': 'application/json'},
    );

// ─────────────────────────────────────────────────────────────────────────────
// Dedicated HTTPS Handlers
// ─────────────────────────────────────────────────────────────────────────────

/// HTTPS endpoint for New Event Created notifications.
///
/// Triggered via POST request from Eventarc or an HTTPS client.
Future<Response> handleEventCreatedHttp(Request request, Firebase firebase) async {
  if (request.method.toUpperCase() == 'GET') {
    return _jsonOk({'endpoint': 'eventCreatedHttp', 'status': 'ready'});
  }

  final rejected = verifyNotificationRequest(request);
  if (rejected != null) return rejected;

  return _processEventCreated(await parseNotificationRequest(request), firebase);
}

/// Core event-created processing, shared by the dedicated endpoint and the
/// unified dispatcher. The payload is parsed once by the caller.
Future<Response> _processEventCreated(NotificationPayload payload, Firebase firebase) async {
  final sectionId = payload.sectionId;
  final eventId = payload.eventId;

  if (sectionId == null || sectionId.isEmpty || eventId == null || eventId.isEmpty) {
    return _jsonError('Missing required sectionId or eventId');
  }

  try {
    await handleNewEventCreated(
      firebase: firebase,
      sectionId: sectionId,
      eventId: eventId,
      title: payload.title,
      status: payload.status,
      eventData: payload.data,
    );
    return _jsonOk({
      'status': 'success',
      'action': 'event_created',
      'sectionId': sectionId,
      'eventId': eventId,
    });
  } catch (error) {
    logger.info('Error handling eventCreatedHttp: $error');
    return _jsonError('Failed to process event creation: $error', statusCode: 500);
  }
}

/// HTTPS endpoint for Event Updated notifications.
///
/// Triggered via POST request from Eventarc or an HTTPS client.
Future<Response> handleEventUpdatedHttp(Request request, Firebase firebase) async {
  if (request.method.toUpperCase() == 'GET') {
    return _jsonOk({'endpoint': 'eventUpdatedHttp', 'status': 'ready'});
  }

  final rejected = verifyNotificationRequest(request);
  if (rejected != null) return rejected;

  return _processEventUpdated(await parseNotificationRequest(request), firebase);
}

/// Core event-updated processing, shared by the dedicated endpoint and the
/// unified dispatcher. The payload is parsed once by the caller.
Future<Response> _processEventUpdated(NotificationPayload payload, Firebase firebase) async {
  final sectionId = payload.sectionId;
  final eventId = payload.eventId;

  if (sectionId == null || sectionId.isEmpty || eventId == null || eventId.isEmpty) {
    return _jsonError('Missing required sectionId or eventId');
  }

  try {
    await handleEventUpdated(
      firebase: firebase,
      sectionId: sectionId,
      eventId: eventId,
      beforeStatus: payload.beforeStatus,
      afterStatus: payload.afterStatus,
      title: payload.title,
      beforeData: payload.beforeData,
      afterData: payload.afterData,
    );
    return _jsonOk({
      'status': 'success',
      'action': 'event_updated',
      'sectionId': sectionId,
      'eventId': eventId,
    });
  } catch (error) {
    logger.info('Error handling eventUpdatedHttp: $error');
    return _jsonError('Failed to process event update: $error', statusCode: 500);
  }
}

/// HTTPS endpoint for Registration Created notifications.
///
/// Triggered via POST request from Eventarc or an HTTPS client.
Future<Response> handleRegistrationCreatedHttp(Request request, Firebase firebase) async {
  if (request.method.toUpperCase() == 'GET') {
    return _jsonOk({'endpoint': 'registrationCreatedHttp', 'status': 'ready'});
  }

  final rejected = verifyNotificationRequest(request);
  if (rejected != null) return rejected;

  return _processRegistrationCreated(await parseNotificationRequest(request), firebase);
}

/// Core registration-created processing, shared by the dedicated endpoint and
/// the unified dispatcher. The payload is parsed once by the caller.
Future<Response> _processRegistrationCreated(NotificationPayload payload, Firebase firebase) async {
  final sectionId = payload.sectionId;
  final eventId = payload.eventId;
  final registrationId = payload.registrationId;

  if (sectionId == null ||
      sectionId.isEmpty ||
      eventId == null ||
      eventId.isEmpty ||
      registrationId == null ||
      registrationId.isEmpty) {
    return _jsonError('Missing required sectionId, eventId, or registrationId');
  }

  try {
    await handleRegistrationCreated(
      firebase: firebase,
      sectionId: sectionId,
      eventId: eventId,
      registrationId: registrationId,
      userId: payload.userId,
      status: payload.status,
      authId: payload.authId,
      regData: payload.data,
    );
    return _jsonOk({
      'status': 'success',
      'action': 'registration_created',
      'sectionId': sectionId,
      'eventId': eventId,
      'registrationId': registrationId,
    });
  } catch (error) {
    logger.info('Error handling registrationCreatedHttp: $error');
    return _jsonError('Failed to process registration creation: $error', statusCode: 500);
  }
}

/// HTTPS endpoint for Registration Updated notifications.
///
/// Triggered via POST request from Eventarc or an HTTPS client.
Future<Response> handleRegistrationUpdatedHttp(Request request, Firebase firebase) async {
  if (request.method.toUpperCase() == 'GET') {
    return _jsonOk({'endpoint': 'registrationUpdatedHttp', 'status': 'ready'});
  }

  final rejected = verifyNotificationRequest(request);
  if (rejected != null) return rejected;

  return _processRegistrationUpdated(await parseNotificationRequest(request), firebase);
}

/// Core registration-updated processing, shared by the dedicated endpoint and
/// the unified dispatcher. The payload is parsed once by the caller.
Future<Response> _processRegistrationUpdated(NotificationPayload payload, Firebase firebase) async {
  final sectionId = payload.sectionId;
  final eventId = payload.eventId;
  final registrationId = payload.registrationId;

  if (sectionId == null ||
      sectionId.isEmpty ||
      eventId == null ||
      eventId.isEmpty ||
      registrationId == null ||
      registrationId.isEmpty) {
    return _jsonError('Missing required sectionId, eventId, or registrationId');
  }

  try {
    await handleRegistrationUpdated(
      firebase: firebase,
      sectionId: sectionId,
      eventId: eventId,
      registrationId: registrationId,
      userId: payload.userId,
      beforeStatus: payload.beforeStatus,
      afterStatus: payload.afterStatus,
      authId: payload.authId,
      beforeData: payload.beforeData,
      afterData: payload.afterData,
    );
    return _jsonOk({
      'status': 'success',
      'action': 'registration_updated',
      'sectionId': sectionId,
      'eventId': eventId,
      'registrationId': registrationId,
    });
  } catch (error) {
    logger.info('Error handling registrationUpdatedHttp: $error');
    return _jsonError('Failed to process registration update: $error', statusCode: 500);
  }
}

/// HTTPS endpoint for Registration Deleted notifications.
///
/// Triggered via POST request from Eventarc or an HTTPS client.
Future<Response> handleRegistrationDeletedHttp(Request request, Firebase firebase) async {
  if (request.method.toUpperCase() == 'GET') {
    return _jsonOk({'endpoint': 'registrationDeletedHttp', 'status': 'ready'});
  }

  final rejected = verifyNotificationRequest(request);
  if (rejected != null) return rejected;

  return _processRegistrationDeleted(await parseNotificationRequest(request), firebase);
}

/// Core registration-deleted processing, shared by the dedicated endpoint and
/// the unified dispatcher. The payload is parsed once by the caller.
Future<Response> _processRegistrationDeleted(NotificationPayload payload, Firebase firebase) async {
  final sectionId = payload.sectionId;
  final eventId = payload.eventId;
  final registrationId = payload.registrationId;

  if (sectionId == null ||
      sectionId.isEmpty ||
      eventId == null ||
      eventId.isEmpty ||
      registrationId == null ||
      registrationId.isEmpty) {
    return _jsonError('Missing required sectionId, eventId, or registrationId');
  }

  try {
    await handleRegistrationDeleted(
      firebase: firebase,
      sectionId: sectionId,
      eventId: eventId,
      registrationId: registrationId,
      userId: payload.userId,
      status: payload.status,
      authId: payload.authId,
      regData: payload.data,
    );
    return _jsonOk({
      'status': 'success',
      'action': 'registration_deleted',
      'sectionId': sectionId,
      'eventId': eventId,
      'registrationId': registrationId,
    });
  } catch (error) {
    logger.info('Error handling registrationDeletedHttp: $error');
    return _jsonError('Failed to process registration deletion: $error', statusCode: 500);
  }
}

/// Unified HTTPS Dispatcher Endpoint for Eventarc & webhooks.
///
/// Accepts any notification trigger event and routes it to the corresponding
/// handler based on the event type, subject path, or payload structure.
Future<Response> handleNotificationTriggerHttp(Request request, Firebase firebase) async {
  if (request.method.toUpperCase() == 'GET') {
    return _jsonOk({'endpoint': 'notificationTriggerHttp', 'status': 'ready'});
  }

  final rejected = verifyNotificationRequest(request);
  if (rejected != null) return rejected;

  final payload = await parseNotificationRequest(request);
  final eventType = payload.eventType?.toLowerCase() ?? '';
  final hasRegistration = payload.registrationId != null && payload.registrationId!.isNotEmpty;

  // 1. Explicit event type matching
  if (eventType.contains('created') || eventType == 'event_created') {
    if (hasRegistration || eventType.contains('registration')) {
      return _processRegistrationCreated(payload, firebase);
    }
    return _processEventCreated(payload, firebase);
  }

  if (eventType.contains('updated') || eventType == 'event_updated') {
    if (hasRegistration || eventType.contains('registration')) {
      return _processRegistrationUpdated(payload, firebase);
    }
    return _processEventUpdated(payload, firebase);
  }

  if (eventType.contains('deleted') || eventType == 'registration_deleted') {
    return _processRegistrationDeleted(payload, firebase);
  }

  // 2. Infer from presence of IDs and parameters
  if (hasRegistration) {
    if (payload.beforeStatus != null && payload.afterStatus != null) {
      return _processRegistrationUpdated(payload, firebase);
    }
    return _processRegistrationCreated(payload, firebase);
  }

  if (payload.eventId != null && payload.eventId!.isNotEmpty) {
    if (payload.beforeStatus != null && payload.afterStatus != null) {
      return _processEventUpdated(payload, firebase);
    }
    return _processEventCreated(payload, firebase);
  }

  return _jsonError(
    'Could not determine event type from request payload or headers. '
    'Specify action/type or include sectionId and eventId.',
  );
}
