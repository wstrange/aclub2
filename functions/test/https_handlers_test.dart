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
}
