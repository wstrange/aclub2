import 'dart:convert';
import 'package:aclub_functions/src/https_handlers.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

void main() {
  group('HTTPS Handlers and Payload Parsing', () {
    test('unwrapFirestoreValue unwraps various Firestore REST types', () {
      expect(unwrapFirestoreValue({'stringValue': 'Kayak Trip'}), equals('Kayak Trip'));
      expect(unwrapFirestoreValue({'integerValue': '42'}), equals(42));
      expect(unwrapFirestoreValue({'booleanValue': true}), equals(true));
      expect(
        unwrapFirestoreValue({
          'arrayValue': {
            'values': [
              {'stringValue': 'first'},
              {'stringValue': 'second'},
            ],
          },
        }),
        equals(['first', 'second']),
      );
    });

    test('unwrapFirestoreFields unwraps a full document field map', () {
      final raw = {
        'title': {'stringValue': 'Whitewater Kayaking'},
        'status': {'stringValue': 'published'},
        'capacity': {'integerValue': '12'},
      };
      final unwrapped = unwrapFirestoreFields(raw);
      expect(unwrapped['title'], equals('Whitewater Kayaking'));
      expect(unwrapped['status'], equals('published'));
      expect(unwrapped['capacity'], equals(12));
    });

    test('parseNotificationRequest parses direct JSON body correctly', () async {
      final body = jsonEncode({
        'sectionId': 'sec-1',
        'eventId': 'evt-2',
        'registrationId': 'reg-3',
        'userId': 'usr-4',
        'status': 'published',
        'title': 'Test Title',
      });
      final req = Request('POST', Uri.parse('https://example.com/eventCreatedHttp'), body: body);

      final payload = await parseNotificationRequest(req);
      expect(payload.sectionId, equals('sec-1'));
      expect(payload.eventId, equals('evt-2'));
      expect(payload.registrationId, equals('reg-3'));
      expect(payload.userId, equals('usr-4'));
      expect(payload.status, equals('published'));
      expect(payload.title, equals('Test Title'));
    });

    test('parseNotificationRequest extracts IDs from CloudEvent ce-subject header', () async {
      final req = Request(
        'POST',
        Uri.parse('https://example.com/notificationTriggerHttp'),
        headers: {
          'ce-type': 'google.cloud.firestore.document.v1.created',
          'ce-subject': 'documents/sections/paddling/events/trip-2026/registrations/reg-abc',
          'ce-authid': 'leader-123',
        },
        body: jsonEncode({'status': 'approved'}),
      );

      final payload = await parseNotificationRequest(req);
      expect(payload.sectionId, equals('paddling'));
      expect(payload.eventId, equals('trip-2026'));
      expect(payload.registrationId, equals('reg-abc'));
      expect(payload.authId, equals('leader-123'));
      expect(payload.status, equals('approved'));
      expect(payload.eventType, equals('google.cloud.firestore.document.v1.created'));
    });

    test('parseNotificationRequest extracts IDs from CloudEvent structured body', () async {
      final req = Request(
        'POST',
        Uri.parse('https://example.com/notificationTriggerHttp'),
        headers: {'content-type': 'application/cloudevents+json'},
        body: jsonEncode({
          'type': 'google.cloud.firestore.document.v1.updated',
          'subject': 'documents/sections/hiking/events/summit-climb',
          'data': {
            'value': {
              'fields': {
                'title': {'stringValue': 'Summit Climb'},
                'status': {'stringValue': 'published'},
              },
            },
            'oldValue': {
              'fields': {
                'title': {'stringValue': 'Summit Climb'},
                'status': {'stringValue': 'draft'},
              },
            },
          },
        }),
      );

      final payload = await parseNotificationRequest(req);
      expect(payload.sectionId, equals('hiking'));
      expect(payload.eventId, equals('summit-climb'));
      expect(payload.title, equals('Summit Climb'));
      expect(payload.afterStatus, equals('published'));
      expect(payload.beforeStatus, equals('draft'));
    });

    test('GET request to endpoints returns ready status', () async {
      final req = Request('GET', Uri.parse('https://example.com/eventCreatedHttp'));
      // We pass an arbitrary object or test helper since GET returns immediately
      final payload = await parseNotificationRequest(req);
      expect(payload.sectionId, isNull);
    });
  });

  group('verifyNotificationRequest', () {
    test('allows the GET readiness probe', () {
      final req = Request('GET', Uri.parse('https://example.com/eventCreatedHttp'));
      expect(verifyNotificationRequest(req), isNull);
    });

    test('rejects non-POST methods', () {
      final req = Request('PUT', Uri.parse('https://example.com/eventCreatedHttp'), body: '{}');
      expect(verifyNotificationRequest(req)?.statusCode, equals(405));
    });

    test('requires a bearer token when running on Cloud Run', () {
      final anonymous = Request('POST', Uri.parse('https://example.com/eventCreatedHttp'), body: '{}');
      expect(verifyNotificationRequest(anonymous, isCloudRun: true)?.statusCode, equals(401));

      final authorized = Request(
        'POST',
        Uri.parse('https://example.com/eventCreatedHttp'),
        headers: {
          'authorization': 'Bearer oidc-token',
          'ce-specversion': '1.0',
          'ce-source': '//firestore.googleapis.com/projects/p/databases/(default)',
          'ce-type': 'google.cloud.firestore.document.v1.created',
        },
        body: '{}',
      );
      expect(verifyNotificationRequest(authorized, isCloudRun: true), isNull);
    });

    test('rejects direct JSON calls on Cloud Run without a webhook secret', () {
      final req = Request(
        'POST',
        Uri.parse('https://example.com/eventCreatedHttp'),
        headers: {'authorization': 'Bearer oidc-token'},
        body: '{}',
      );
      expect(verifyNotificationRequest(req, isCloudRun: true)?.statusCode, equals(403));

      final withSecret = Request(
        'POST',
        Uri.parse('https://example.com/eventCreatedHttp'),
        headers: {'authorization': 'Bearer oidc-token', 'x-notification-secret': 's3cret'},
        body: '{}',
      );
      expect(
        verifyNotificationRequest(withSecret, isCloudRun: true, webhookSecret: 's3cret'),
        isNull,
      );
    });

    test('rejects CloudEvents that did not originate from Firestore', () {
      final badSource = Request(
        'POST',
        Uri.parse('https://example.com/eventCreatedHttp'),
        headers: {
          'ce-specversion': '1.0',
          'ce-source': '//pubsub.googleapis.com/projects/p/topics/t',
          'ce-type': 'google.cloud.firestore.document.v1.created',
        },
        body: '{}',
      );
      expect(verifyNotificationRequest(badSource)?.statusCode, equals(403));

      final badType = Request(
        'POST',
        Uri.parse('https://example.com/eventCreatedHttp'),
        headers: {
          'ce-specversion': '1.0',
          'ce-source': '//firestore.googleapis.com/projects/p/databases/(default)',
          'ce-type': 'google.cloud.pubsub.topic.v1.messagePublished',
        },
        body: '{}',
      );
      expect(verifyNotificationRequest(badType)?.statusCode, equals(403));
    });

    test('accepts a Firestore document CloudEvent', () {
      final req = Request(
        'POST',
        Uri.parse('https://example.com/eventCreatedHttp'),
        headers: {
          'ce-specversion': '1.0',
          'ce-source': '//firestore.googleapis.com/projects/p/databases/(default)',
          'ce-type': 'google.cloud.firestore.document.v1.created',
        },
        body: '{}',
      );
      expect(verifyNotificationRequest(req), isNull);
    });

    test('enforces the optional webhook secret for non-CloudEvent callers', () {
      final missing = Request('POST', Uri.parse('https://example.com/eventCreatedHttp'), body: '{}');
      expect(verifyNotificationRequest(missing, webhookSecret: 's3cret')?.statusCode, equals(401));

      final valid = Request(
        'POST',
        Uri.parse('https://example.com/eventCreatedHttp'),
        headers: {'x-notification-secret': 's3cret'},
        body: '{}',
      );
      expect(verifyNotificationRequest(valid, webhookSecret: 's3cret'), isNull);
    });
  });
}
