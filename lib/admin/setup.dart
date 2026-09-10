import 'package:aclub2/repo.dart';

import '../models/models.dart';

final repo = AlpineRepository();

Future<void> createSections() async {
  await repo.createSection(Section(id: 'national', name: 'National', description: 'National section description'));
  await repo.createSection(Section(id: 'calgary', name: 'Calgary', description: 'Calgary section description'));
}

Future<void> doAdminSetup() async {
  await createSections();
}
