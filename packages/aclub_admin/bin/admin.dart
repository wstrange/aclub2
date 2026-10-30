import 'dart:convert';
import 'dart:io';

import 'package:aclub_admin/admin_repo.dart';
import 'package:args/command_runner.dart';

void main(List<String> args) async {
  final runner =
      CommandRunner<void>(
          'admin',
          'Administrative CLI tool for aclub database management and Cloud operations.',
        )
        ..addCommand(SeedCommand())
        ..addCommand(ResetCommand())
        ..addCommand(StatsCommand())
        ..addCommand(ListSectionsCommand())
        ..addCommand(ListEventsCommand())
        ..addCommand(TemplatesCommand());

  runner.argParser
    ..addOption(
      'project',
      abbr: 'p',
      help: 'Target Firebase/GCP Project ID',
      defaultsTo: 'aclub2',
    )
    ..addOption(
      'emulator',
      abbr: 'e',
      help: 'Firestore emulator host (e.g. localhost:8080)',
      defaultsTo:
          Platform.environment['FIRESTORE_EMULATOR_HOST'] ?? 'localhost:8080',
    )
    ..addFlag(
      'use-emulator',
      help: 'Whether to connect to local emulator',
      defaultsTo: true,
    )
    ..addFlag(
      'prod',
      help: 'Target the production GCP project (overrides --use-emulator)',
      negatable: false,
    );

  try {
    await runner.run(args);
  } catch (error) {
    stderr.writeln('❌ Error: $error');
    exit(1);
  }
}

abstract class BaseAdminCommand extends Command<void> {
  AdminRepository createRepo() {
    final prod = globalResults?['prod'] as bool? ?? false;
    final useEmulator =
        !prod && (globalResults?['use-emulator'] as bool? ?? true);
    final emulatorHost = globalResults?['emulator'] as String?;
    final projectId = globalResults?['project'] as String? ?? 'aclub2';

    if (useEmulator && emulatorHost != null && emulatorHost.isNotEmpty) {
      stdout.writeln(
        '🔌 Connecting to Firestore Emulator at $emulatorHost (Project: $projectId)...',
      );
      return AdminRepository(
        projectId: projectId,
        useEmulator: true,
        emulatorHost: emulatorHost,
      );
    } else {
      stdout.writeln('☁️ Connecting to GCP Project $projectId...');
      return AdminRepository(projectId: projectId, useEmulator: false);
    }
  }
}

class SeedCommand extends BaseAdminCommand {
  @override
  final name = 'seed';
  @override
  final description =
      'Seeds sample sections and events, plus templates from content/templates.';

  SeedCommand() {
    argParser.addFlag(
      'reset',
      abbr: 'r',
      help: 'Clear existing data before seeding',
      defaultsTo: false,
    );
    argParser.addOption(
      'users',
      abbr: 'u',
      help: 'Number of sample users to seed per section',
      defaultsTo: '3',
    );
    argParser.addOption(
      'events',
      abbr: 'c',
      help:
          'Number of sample events to seed (spanning from today to one year out)',
      defaultsTo: '12',
    );
    argParser.addOption(
      'templates-dir',
      help:
          'Directory of template markdown files (defaults to content/templates)',
    );
  }

  /// Parses a non-negative integer option, failing the command on bad input.
  int _count(String key) {
    final raw = argResults?[key] as String?;
    final value = int.tryParse(raw ?? '');
    if (value == null || value < 0) {
      stderr.writeln(
        '❌ Invalid value for --$key: "$raw" (expected a non-negative integer)',
      );
      exit(1);
    }
    return value;
  }

  @override
  Future<void> run() async {
    final usersPerSection = _count('users');
    final eventCount = _count('events');

    final templatesDir = resolveTemplatesDirectory(
      argResults?['templates-dir'] as String?,
    );
    final templateSources = loadTemplateFiles(templatesDir);
    final now = DateTime.now();
    final templates = [
      for (final source in templateSources)
        source.toTemplate(createdBy: 'admin', createdAt: now, updatedAt: now),
    ];
    stdout.writeln(
      '📄 Loaded ${templates.length} template(s) from ${templatesDir.path}',
    );

    final repo = createRepo();
    try {
      if (argResults?['reset'] == true) {
        stdout.writeln('🧹 Clearing existing data...');
        await repo.resetAll();
      }

      final sections = defaultSampleSections;
      stdout.writeln(
        '🌱 Seeding database (${sections.length} sections, $usersPerSection users/section, '
        '$eventCount events spanning the next year)...',
      );
      final result = await repo.seedAll(
        sections: sections,
        events: generateSampleEvents(eventCount, sections: sections),
        users: generateSampleUsers(usersPerSection, sections: sections),
        templates: templates,
      );
      stdout.writeln(
        '✅ Successfully seeded: ${result['sections']} sections, ${result['events']} events, '
        '${result['users']} users, ${result['members']} section members, ${result['templates']} templates.',
      );
    } finally {
      await repo.close();
    }
  }
}

class ResetCommand extends BaseAdminCommand {
  @override
  final name = 'reset';
  @override
  final description =
      'Clears all sections, events, and templates (primarily for testing/emulator).';

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
    argParser.addOption(
      'section',
      abbr: 's',
      help: 'Section ID',
      defaultsTo: 'national',
    );
  }

  @override
  Future<void> run() async {
    final sectionId = argResults?['section'] as String? ?? 'national';
    final repo = createRepo();
    try {
      final events = await repo.listEvents(sectionId);
      stdout.writeln('📅 Events for section "$sectionId" (${events.length}):');
      for (final e in events) {
        stdout.writeln(
          '  • [${e.id}] ${e.title} (${e.type.name}) - ${e.startDate.toIso8601String()}',
        );
      }
    } finally {
      await repo.close();
    }
  }
}

/// `templates` command group: list, import, export, delete.
class TemplatesCommand extends Command<void> {
  @override
  final name = 'templates';
  @override
  final description =
      'Manages markdown templates stored in /templates (content/templates in git).';

  TemplatesCommand() {
    addSubcommand(TemplatesListCommand());
    addSubcommand(TemplatesImportCommand());
    addSubcommand(TemplatesExportCommand());
    addSubcommand(TemplatesDeleteCommand());
  }
}

class TemplatesListCommand extends BaseAdminCommand {
  @override
  final name = 'list';
  @override
  final description = 'Lists templates in Firestore.';

  TemplatesListCommand() {
    argParser
      ..addOption('language', abbr: 'l', help: 'Only list this language (en/fr)')
      ..addFlag(
        'json',
        help: 'Print machine-readable JSON',
        negatable: false,
      );
  }

  @override
  Future<void> run() async {
    final language = argResults?['language'] as String?;
    final repo = createRepo();
    try {
      final templates =
          (await repo.listTemplates())
              .where((t) => language == null || t.language == language)
              .toList()
            ..sort((a, b) => a.id.compareTo(b.id));

      if (argResults?['json'] == true) {
        stdout.writeln(
          const JsonEncoder.withIndent('  ').convert([
            for (final t in templates)
              {
                'id': t.id,
                'language': t.language,
                'title': t.title,
                'createdBy': t.createdBy,
                'createdAt': t.createdAt.toIso8601String(),
                'updatedAt': t.updatedAt.toIso8601String(),
                'characters': t.markdownText.length,
              },
          ]),
        );
        return;
      }

      stdout.writeln('📄 Templates (${templates.length}):');
      for (final t in templates) {
        stdout.writeln(
          '  • [${t.id}] (${t.language}) ${t.title} — updated ${t.updatedAt.toIso8601String()}',
        );
      }
    } finally {
      await repo.close();
    }
  }
}

class TemplatesImportCommand extends BaseAdminCommand {
  @override
  final name = 'import';
  @override
  final description =
      'Creates/updates templates from markdown files with YAML front matter.';

  TemplatesImportCommand() {
    argParser
      ..addOption(
        'if-exists',
        allowed: ['update', 'skip', 'fail'],
        defaultsTo: 'update',
        help: 'What to do when a template ID already exists in Firestore',
      )
      ..addOption(
        'as',
        help: 'User ID recorded as createdBy on newly created templates',
        defaultsTo: 'cli',
      )
      ..addFlag(
        'dry-run',
        help: 'Show the changes without writing anything',
        negatable: false,
      )
      ..addFlag(
        'prune',
        help: 'Delete templates that have no matching markdown file',
        negatable: false,
      )
      ..addFlag(
        'yes',
        abbr: 'y',
        help: 'Required with --prune to confirm deletions',
        negatable: false,
      );
  }

  @override
  Future<void> run() async {
    final args = argResults!;
    final prune = args['prune'] == true;
    if (prune && args['yes'] != true) {
      stderr.writeln('❌ --prune deletes templates; re-run with --yes to confirm.');
      exit(1);
    }

    final directory = resolveTemplatesDirectory(
      args.rest.isEmpty ? null : args.rest.first,
    );
    final sources = loadTemplateFiles(directory);
    final mode = TemplateImportMode.values.byName(args['if-exists'] as String);
    final dryRun = args['dry-run'] == true;
    final authorId = args['as'] as String? ?? 'cli';

    stdout.writeln('📂 ${sources.length} template file(s) in ${directory.path}');

    final repo = createRepo();
    try {
      final plan = planTemplateImport(
        sources: sources,
        existing: await repo.listTemplates(),
        authorId: authorId,
        now: DateTime.now(),
        mode: mode,
      );

      for (final change in plan.changes) {
        final verb = change.action == TemplateChangeAction.create
            ? '＋ create'
            : '✎ update';
        stdout.writeln(
          '  $verb [${change.template.id}] ${change.template.title} (${change.template.language})',
        );
      }
      for (final template in plan.unchanged) {
        stdout.writeln('  = unchanged [${template.id}]');
      }
      for (final template in plan.skipped) {
        stdout.writeln('  → skipped [${template.id}] (already exists)');
      }
      if (prune) {
        for (final id in plan.staleIds) {
          stdout.writeln('  － delete [$id]');
        }
      }

      if (dryRun) {
        stdout.writeln('🔍 Dry run: nothing written.');
        return;
      }

      for (final change in plan.changes) {
        await repo.saveTemplate(change.template);
      }
      if (prune) {
        for (final id in plan.staleIds) {
          await repo.deleteTemplate(id);
        }
      }

      stdout.writeln(
        '✅ Import complete: ${plan.createdCount} created, ${plan.updatedCount} updated, '
        '${plan.unchanged.length} unchanged, ${plan.skipped.length} skipped'
        '${prune ? ', ${plan.staleIds.length} deleted' : ''}.',
      );
    } finally {
      await repo.close();
    }
  }
}

class TemplatesExportCommand extends BaseAdminCommand {
  @override
  final name = 'export';
  @override
  final description =
      'Writes templates from Firestore to markdown files (content/templates layout).';

  TemplatesExportCommand() {
    argParser.addOption(
      'language',
      abbr: 'l',
      help: 'Only export this language (en/fr)',
    );
  }

  @override
  Future<void> run() async {
    final args = argResults!;
    final directory = args.rest.isEmpty
        ? resolveTemplatesDirectory()
        : Directory(args.rest.first);
    final language = args['language'] as String?;

    final repo = createRepo();
    try {
      final templates =
          (await repo.listTemplates())
              .where((t) => language == null || t.language == language)
              .toList()
            ..sort((a, b) => a.id.compareTo(b.id));

      if (templates.isEmpty) {
        stdout.writeln('No templates to export.');
        return;
      }

      for (final template in templates) {
        final fileName = _safeFileName(template.id);
        final file = File(
          [
            directory.path,
            template.language,
            '$fileName.md',
          ].join(Platform.pathSeparator),
        );
        file.parent.createSync(recursive: true);
        file.writeAsStringSync(templateToMarkdown(template));
        stdout.writeln('  → ${file.path}');
      }
      stdout.writeln('✅ Exported ${templates.length} template(s) to ${directory.path}');
    } finally {
      await repo.close();
    }
  }
}

class TemplatesDeleteCommand extends BaseAdminCommand {
  @override
  final name = 'delete';
  @override
  final description = 'Deletes a single template by ID.';

  TemplatesDeleteCommand() {
    argParser.addFlag(
      'yes',
      abbr: 'y',
      help: 'Confirm the deletion',
      negatable: false,
    );
  }

  @override
  Future<void> run() async {
    final args = argResults!;
    if (args.rest.isEmpty) {
      stderr.writeln('❌ Usage: admin templates delete <id> --yes');
      exit(1);
    }
    final id = args.rest.first;
    if (args['yes'] != true) {
      stderr.writeln('❌ Refusing to delete "$id" without --yes.');
      exit(1);
    }

    final repo = createRepo();
    try {
      await repo.deleteTemplate(id);
      stdout.writeln('🗑️ Deleted template [$id].');
    } finally {
      await repo.close();
    }
  }
}

/// Keeps exported file names filesystem-safe even for legacy auto-IDs.
String _safeFileName(String id) {
  return id.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '-');
}
