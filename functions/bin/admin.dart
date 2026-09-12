import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:aclub_admin/admin_repo.dart';

void main(List<String> args) async {
  final runner = CommandRunner<void>(
    'admin',
    'Administrative CLI tool for aclub database management and Cloud operations.',
  )
    ..addCommand(SeedCommand())
    ..addCommand(ResetCommand())
    ..addCommand(StatsCommand())
    ..addCommand(ListSectionsCommand())
    ..addCommand(ListEventsCommand());

  runner.argParser
    ..addOption('project', abbr: 'p', help: 'Target Firebase/GCP Project ID', defaultsTo: 'aclub2')
    ..addOption('emulator', abbr: 'e', help: 'Firestore emulator host (e.g. localhost:8080)', defaultsTo: Platform.environment['FIRESTORE_EMULATOR_HOST'] ?? 'localhost:8080')
    ..addFlag('use-emulator', help: 'Whether to connect to local emulator', defaultsTo: true);

  try {
    await runner.run(args);
  } catch (error) {
    stderr.writeln('❌ Error: $error');
    exit(1);
  }
}

abstract class BaseAdminCommand extends Command<void> {
  AdminRepository createRepo() {
    final useEmulator = globalResults?['use-emulator'] as bool? ?? true;
    final emulatorHost = globalResults?['emulator'] as String?;
    final projectId = globalResults?['project'] as String? ?? 'aclub2';

    if (useEmulator && emulatorHost != null && emulatorHost.isNotEmpty) {
      stdout.writeln('🔌 Connecting to Firestore Emulator at $emulatorHost (Project: $projectId)...');
      return AdminRepository(
        projectId: projectId,
        useEmulator: true,
        emulatorHost: emulatorHost,
      );
    } else {
      stdout.writeln('☁️ Connecting to GCP Project $projectId...');
      return AdminRepository(
        projectId: projectId,
        useEmulator: false,
      );
    }
  }
}

class SeedCommand extends BaseAdminCommand {
  @override
  final name = 'seed';
  @override
  final description = 'Seeds sample sections and events into Cloud Firestore.';

  SeedCommand() {
    argParser.addFlag('reset', abbr: 'r', help: 'Clear existing data before seeding', defaultsTo: false);
  }

  @override
  Future<void> run() async {
    final repo = createRepo();
    try {
      if (argResults?['reset'] == true) {
        stdout.writeln('🧹 Clearing existing data...');
        await repo.resetAll();
      }

      stdout.writeln('🌱 Seeding database...');
      final result = await repo.seedAll();
      stdout.writeln('✅ Successfully seeded: ${result['sections']} sections, ${result['events']} events, '
          '${result['users']} users, ${result['members']} section members.');
    } finally {
      await repo.close();
    }
  }
}

class ResetCommand extends BaseAdminCommand {
  @override
  final name = 'reset';
  @override
  final description = 'Clears all sections, events, and templates (primarily for testing/emulator).';

  @override
  Future<void> run() async {
    final repo = createRepo();
    try {
      stdout.writeln('⚠️ Resetting database collections...');
      await repo.resetAll();
      stdout.writeln('✅ Reset complete.');
    } finally {
      await repo.close();
    }
  }
}

class StatsCommand extends BaseAdminCommand {
  @override
  final name = 'stats';
  @override
  final description = 'Displays collection statistics and document counts.';

  @override
  Future<void> run() async {
    final repo = createRepo();
    try {
      stdout.writeln('📊 Fetching stats...');
      final stats = await repo.getStats();
      stdout.writeln('----------------------------------------');
      stdout.writeln('Sections:      ${stats['sections']}');
      stdout.writeln('Events:        ${stats['events']}');
      stdout.writeln('Members:       ${stats['members']}');
      stdout.writeln('Users:         ${stats['users']}');
      stdout.writeln('----------------------------------------');
    } finally {
      await repo.close();
    }
  }
}

class ListSectionsCommand extends BaseAdminCommand {
  @override
  final name = 'list-sections';
  @override
  final description = 'Lists all sections.';

  @override
  Future<void> run() async {
    final repo = createRepo();
    try {
      final sections = await repo.listSections();
      stdout.writeln('📋 Sections (${sections.length}):');
      for (final s in sections) {
        stdout.writeln('  • [${s.id}] ${s.name} - ${s.description ?? ""}');
      }
    } finally {
      await repo.close();
    }
  }
}

class ListEventsCommand extends BaseAdminCommand {
  @override
  final name = 'list-events';
  @override
  final description = 'Lists events for a given section.';

  ListEventsCommand() {
    argParser.addOption('section', abbr: 's', help: 'Section ID', defaultsTo: 'national');
  }

  @override
  Future<void> run() async {
    final sectionId = argResults?['section'] as String? ?? 'national';
    final repo = createRepo();
    try {
      final events = await repo.listEvents(sectionId);
      stdout.writeln('📅 Events for section "$sectionId" (${events.length}):');
      for (final e in events) {
        stdout.writeln('  • [${e.id}] ${e.title} (${e.type.name}) - ${e.startDate.toIso8601String()}');
      }
    } finally {
      await repo.close();
    }
  }
}
