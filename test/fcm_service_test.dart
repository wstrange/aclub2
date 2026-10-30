import 'package:aclub2/services/fcm_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FCM Service & Topic Conventions', () {
    test('sanitizeTopicName replaces invalid characters with underscore', () {
      expect(sanitizeTopicName('calgary'), equals('calgary'));
      expect(sanitizeTopicName('Calgary Section'), equals('Calgary_Section'));
      expect(sanitizeTopicName('rockies/banff&canmore!'), equals('rockies_banff_canmore_'));
    });

    test('sectionEventsTopic produces valid FCM topic name matching regex', () {
      final validRegex = RegExp(r'^[a-zA-Z0-9-_.~%]{1,900}$');

      final calgaryTopic = sectionEventsTopic('calgary');
      expect(calgaryTopic, equals('section_calgary_events'));
      expect(validRegex.hasMatch(calgaryTopic), isTrue);

      final complexTopic = sectionEventsTopic('Vancouver Island 2026 #1');
      expect(complexTopic, equals('section_Vancouver_Island_2026__1_events'));
      expect(validRegex.hasMatch(complexTopic), isTrue);
    });
  });
}

