import 'package:flutter_test/flutter_test.dart';
import 'package:shared_models/shared_models.dart';

void main() {
  group('NotificationModel and Notifications Logic', () {
    test('creates and serializes NotificationModel correctly', () {
      final now = DateTime(2026, 9, 16, 12, 0);
      final notification = NotificationModel(
        id: 'notif-1',
        recipientId: 'user-abc',
        title: 'Event Reminder',
        message: 'Your hike starts tomorrow.',
        link: '/events/hike-123',
        channels: const ['inApp', 'push'],
        isRead: false,
        relatedEventId: 'hike-123',
        relatedSectionId: 'calgary',
        createdAt: now,
      );

      expect(notification.id, equals('notif-1'));
      expect(notification.recipientId, equals('user-abc'));
      expect(notification.title, equals('Event Reminder'));
      expect(notification.message, equals('Your hike starts tomorrow.'));
      expect(notification.link, equals('/events/hike-123'));
      expect(notification.channels, containsAll(['inApp', 'push']));
      expect(notification.isRead, isFalse);
      expect(notification.relatedEventId, equals('hike-123'));
      expect(notification.relatedSectionId, equals('calgary'));
      expect(notification.createdAt, equals(now));

      final json = notification.toJson();
      expect(json['recipientId'], equals('user-abc'));
      expect(json['isRead'], isFalse);

      final fromJson = NotificationModel.fromJson(json);
      expect(fromJson.id, equals('notif-1'));
      expect(fromJson.recipientId, equals('user-abc'));
      expect(fromJson.createdAt, equals(now));
    });

    test('sorts notifications newest first', () {
      final t1 = DateTime(2026, 9, 14, 10, 0);
      final t2 = DateTime(2026, 9, 15, 10, 0);
      final t3 = DateTime(2026, 9, 16, 10, 0);

      final n1 = NotificationModel(
        id: '1',
        recipientId: 'u1',
        title: 'Old',
        message: 'm',
        createdAt: t1,
      );
      final n2 = NotificationModel(
        id: '2',
        recipientId: 'u1',
        title: 'Mid',
        message: 'm',
        createdAt: t2,
      );
      final n3 = NotificationModel(
        id: '3',
        recipientId: 'u1',
        title: 'Newest',
        message: 'm',
        createdAt: t3,
      );

      final list = [n1, n3, n2];
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      expect(list.map((n) => n.id).toList(), equals(['3', '2', '1']));
    });

    test('marks notification as read using copyWith', () {
      final now = DateTime.now();
      final original = NotificationModel(
        id: 'notif-unread',
        recipientId: 'user-1',
        title: 'Title',
        message: 'Msg',
        isRead: false,
        createdAt: now,
      );

      final read = original.copyWith(isRead: true);
      expect(original.isRead, isFalse);
      expect(read.isRead, isTrue);
    });
  });
}
