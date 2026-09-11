import 'package:test/test.dart';
import 'package:shared_models/shared_models.dart';
import 'package:aclub_admin/admin_repo.dart';

void main() {
  group('Admin Models & Sample Data', () {
    test('defaultSampleSections contains valid section data', () {
      final sections = defaultSampleSections;
      expect(sections.isNotEmpty, isTrue);
      expect(sections.any((s) => s.id == 'national'), isTrue);
      expect(sections.any((s) => s.id == 'calgary'), isTrue);
    });

    test('defaultSampleEvents contains valid Freezed event models', () {
      final events = defaultSampleEvents;
      expect(events.isNotEmpty, isTrue);
      for (final event in events) {
        expect(event.id.isNotEmpty, isTrue);
        expect(event.sectionId.isNotEmpty, isTrue);
        expect(event.title.isNotEmpty, isTrue);
        expect(event.startDate.isBefore(event.endDate) || event.startDate.isAtSameMomentAs(event.endDate), isTrue);

        final json = event.toJson();
        final reconstructed = Event.fromJson(json);
        expect(reconstructed.id, equals(event.id));
        expect(reconstructed.title, equals(event.title));
      }
    });
  });
}
