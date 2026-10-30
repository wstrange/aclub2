import 'dart:io';

import 'package:aclub_admin/template_source.dart';
import 'package:shared_models/shared_models.dart';
import 'package:test/test.dart';

void main() {
  group('parseTemplateMarkdown', () {
    test('parses front matter and body', () {
      final source = parseTemplateMarkdown(
        '''
---
title: "Trip Warm-Up: What to Bring"
id: what-to-bring-en
language: en
---
# What to Bring

- Boots
''',
        path: 'en/what-to-bring.md',
      );

      expect(source.id, 'what-to-bring-en');
      expect(source.title, 'Trip Warm-Up: What to Bring');
      expect(source.language, 'en');
      expect(source.markdownText, '# What to Bring\n\n- Boots');
    });

    test('defaults id and language from the path', () {
      final source = parseTemplateMarkdown(
        '''
---
title: Cancellation Policy
---
# Cancellation Policy
''',
        path: 'fr/annulation.md',
        fallbackId: 'annulation-fr',
        fallbackLanguage: 'fr',
      );

      expect(source.id, 'annulation-fr');
      expect(source.language, 'fr');
    });

    test('handles CRLF line endings', () {
      final source = parseTemplateMarkdown(
        '---\r\ntitle: T\r\n---\r\n# Body\r\n',
        path: 'en/t.md',
        fallbackId: 't-en',
        fallbackLanguage: 'en',
      );

      expect(source.title, 'T');
      expect(source.markdownText, '# Body');
    });

    test('requires a title', () {
      expect(
        () => parseTemplateMarkdown('# Body', path: 'en/x.md', fallbackId: 'x-en', fallbackLanguage: 'en'),
        throwsA(isA<FormatException>().having((e) => e.message, 'message', contains('title'))),
      );
    });

    test('requires a supported language', () {
      expect(
        () => parseTemplateMarkdown(
          '---\ntitle: T\nlanguage: de\n---\nBody',
          path: 'x.md',
          fallbackId: 'x-de',
        ),
        throwsA(isA<FormatException>().having((e) => e.message, 'message', contains('unsupported language'))),
      );
    });

    test('requires a language when the path does not provide one', () {
      expect(
        () => parseTemplateMarkdown('---\ntitle: T\n---\nBody', path: 'x.md', fallbackId: 'x'),
        throwsA(isA<FormatException>().having((e) => e.message, 'message', contains('language'))),
      );
    });

    test('rejects invalid ids', () {
      expect(
        () => parseTemplateMarkdown(
          '---\ntitle: T\nid: "Not A Slug"\nlanguage: en\n---\nBody',
          path: 'x.md',
        ),
        throwsA(isA<FormatException>().having((e) => e.message, 'message', contains('invalid id'))),
      );
    });

    test('rejects an empty body', () {
      expect(
        () => parseTemplateMarkdown(
          '---\ntitle: T\nlanguage: en\n---\n\n',
          path: 'x.md',
          fallbackId: 'x-en',
        ),
        throwsA(isA<FormatException>().having((e) => e.message, 'message', contains('empty'))),
      );
    });
  });

  group('loadTemplateFiles', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('aclub_templates_test');
    });

    tearDown(() {
      if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
    });

    void write(String relativePath, String contents) {
      final file = File([tempDir.path, ...relativePath.split('/')].join(Platform.pathSeparator));
      file.parent.createSync(recursive: true);
      file.writeAsStringSync(contents);
    }

    test('loads files recursively with folder language fallback', () {
      write('en/what-to-bring.md', '---\ntitle: What to Bring\n---\n# Pack\n');
      write('fr/annulation.md', '---\ntitle: Annulation\n---\n# Annulation\n');
      write('README.txt', 'ignored');

      final sources = loadTemplateFiles(tempDir);

      expect(sources.map((s) => s.id), ['what-to-bring-en', 'annulation-fr']);
      expect(sources.map((s) => s.language), ['en', 'fr']);
    });

    test('rejects duplicate ids across files', () {
      write('en/a.md', '---\ntitle: A\nid: same\n---\nBody\n');
      write('fr/b.md', '---\ntitle: B\nid: same\n---\nBody\n');

      expect(
        () => loadTemplateFiles(tempDir),
        throwsA(isA<FormatException>().having((e) => e.message, 'message', contains('Duplicate template id'))),
      );
    });

    test('fails when the directory is missing', () {
      expect(
        () => loadTemplateFiles(Directory([tempDir.path, 'missing'].join(Platform.pathSeparator))),
        throwsA(isA<FormatException>().having((e) => e.message, 'message', contains('not found'))),
      );
    });
  });

  group('planTemplateImport', () {
    final now = DateTime.utc(2026, 10, 29, 12);
    final originalDate = DateTime.utc(2026, 1, 1);

    Template existingTemplate({
      String id = 'a-en',
      String title = 'A',
      String markdown = 'body',
      String createdBy = 'admin',
    }) {
      return Template(
        id: id,
        language: 'en',
        title: title,
        markdownText: markdown,
        createdBy: createdBy,
        createdAt: originalDate,
        updatedAt: originalDate,
      );
    }

    TemplateSource source({
      String id = 'a-en',
      String title = 'A',
      String markdown = 'body',
      String language = 'en',
    }) {
      return TemplateSource(
        path: '$id.md',
        id: id,
        title: title,
        language: language,
        markdownText: markdown,
      );
    }

    test('creates templates that do not exist yet', () {
      final plan = planTemplateImport(
        sources: [source()],
        existing: [],
        authorId: 'cli',
        now: now,
      );

      expect(plan.createdCount, 1);
      expect(plan.updatedCount, 0);
      final template = plan.changes.single.template;
      expect(template.id, 'a-en');
      expect(template.createdBy, 'cli');
      expect(template.createdAt, now);
      expect(template.updatedAt, now);
    });

    test('updates changed templates, preserving createdAt and createdBy', () {
      final plan = planTemplateImport(
        sources: [source(title: 'New title', markdown: 'new body')],
        existing: [existingTemplate()],
        authorId: 'cli',
        now: now,
      );

      expect(plan.updatedCount, 1);
      final template = plan.changes.single.template;
      expect(template.title, 'New title');
      expect(template.markdownText, 'new body');
      expect(template.createdAt, originalDate);
      expect(template.createdBy, 'admin');
      expect(template.updatedAt, now);
    });

    test('leaves identical templates untouched', () {
      final plan = planTemplateImport(
        sources: [source()],
        existing: [existingTemplate()],
        authorId: 'cli',
        now: now,
      );

      expect(plan.changes, isEmpty);
      expect(plan.unchanged, hasLength(1));
    });

    test('skip mode never touches existing templates', () {
      final plan = planTemplateImport(
        sources: [source(markdown: 'changed')],
        existing: [existingTemplate()],
        authorId: 'cli',
        now: now,
        mode: TemplateImportMode.skip,
      );

      expect(plan.changes, isEmpty);
      expect(plan.skipped, hasLength(1));
    });

    test('fail mode aborts when a template already exists', () {
      expect(
        () => planTemplateImport(
          sources: [source()],
          existing: [existingTemplate()],
          authorId: 'cli',
          now: now,
          mode: TemplateImportMode.fail,
        ),
        throwsA(isA<FormatException>().having((e) => e.message, 'message', contains('already exists'))),
      );
    });

    test('reports stale ids for pruning', () {
      final plan = planTemplateImport(
        sources: [source(id: 'keep-en')],
        existing: [existingTemplate(id: 'keep-en'), existingTemplate(id: 'gone-en')],
        authorId: 'cli',
        now: now,
      );

      expect(plan.staleIds, ['gone-en']);
    });
  });

  group('templateToMarkdown', () {
    test('round-trips through parseTemplateMarkdown', () {
      final template = Template(
        id: 'quotes-en',
        language: 'en',
        title: 'Trip: "What" #1',
        markdownText: '# Body\n\n- one\n- two',
        createdBy: 'admin',
        createdAt: DateTime.utc(2026, 1, 1),
        updatedAt: DateTime.utc(2026, 1, 1),
      );

      final parsed = parseTemplateMarkdown(templateToMarkdown(template), path: 'exported.md');

      expect(parsed.id, template.id);
      expect(parsed.title, template.title);
      expect(parsed.language, template.language);
      expect(parsed.markdownText, template.markdownText);
    });
  });

  test('the repository content/templates files are valid', () {
    final directory = resolveTemplatesDirectory();
    final sources = loadTemplateFiles(directory);
    final ids = sources.map((s) => s.id).toSet();

    expect(ids, containsAll({'what-to-bring-en', 'cancellation-policy-en'}));
    for (final source in sources) {
      expect(source.markdownText, isNotEmpty);
      expect(supportedTemplateLanguages, contains(source.language));
    }
  });
}
