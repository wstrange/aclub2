import 'dart:io';

import 'package:shared_models/shared_models.dart';
import 'package:yaml/yaml.dart';

/// Languages the template picker offers (see `event_edit_page.dart`).
const supportedTemplateLanguages = <String>{'en', 'fr'};

/// Firestore document IDs this tool is willing to create: lowercase slugs.
final _validTemplateId = RegExp(r'^[a-z0-9][a-z0-9-]*$');

/// YAML front matter delimited by `---` lines at the very start of a file.
final _frontMatterPattern = RegExp(r'^---[ \t]*\n(.*?)\n---[ \t]*(?:\n|$)', dotAll: true);

/// A template parsed from a markdown file, before timestamps and authorship
/// are decided (see [planTemplateImport]).
class TemplateSource {
  const TemplateSource({
    required this.path,
    required this.id,
    required this.title,
    required this.language,
    required this.markdownText,
  });

  /// File the template came from, used in error and progress messages.
  final String path;
  final String id;
  final String title;
  final String language;
  final String markdownText;

  Template toTemplate({required String createdBy, required DateTime createdAt, required DateTime updatedAt}) {
    return Template(
      id: id,
      language: language,
      title: title,
      markdownText: markdownText,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

/// Parses one template markdown file.
///
/// Front matter supplies the template metadata; `title` is always required.
/// `id` and `language` may be omitted when the file lives in a language folder
/// (e.g. `content/templates/en/what-to-bring.md`):
///
/// ```markdown
/// ---
/// title: "Trip Warm-Up: What to Bring"
/// id: what-to-bring-en          # optional
/// language: en                  # optional, defaults to the folder name
/// ---
/// # What to Bring
/// ...
/// ```
TemplateSource parseTemplateMarkdown(
  String contents, {
  required String path,
  String? fallbackId,
  String? fallbackLanguage,
}) {
  final normalized = contents.replaceAll('\r\n', '\n');
  final frontMatter = _frontMatterPattern.firstMatch(normalized);

  String? title;
  String? id;
  String? language;
  var body = normalized;

  if (frontMatter != null) {
    body = normalized.substring(frontMatter.end);
    final Object? metadata;
    try {
      metadata = loadYaml(frontMatter.group(1) ?? '');
    } on YamlException catch (e) {
      throw FormatException('$path: invalid front matter: ${e.message}');
    }
    if (metadata != null && metadata is! Map) {
      throw FormatException('$path: front matter must be a YAML map');
    }
    if (metadata is Map) {
      title = _stringValue(metadata['title']);
      id = _stringValue(metadata['id']);
      language = _stringValue(metadata['language'])?.toLowerCase();
    }
  }

  if (title == null) {
    throw FormatException('$path: add a "title" to the front matter');
  }

  language ??= fallbackLanguage;
  if (language == null) {
    throw FormatException('$path: set "language" in the front matter or place the file in an en/ or fr/ folder');
  }
  if (!supportedTemplateLanguages.contains(language)) {
    throw FormatException(
      '$path: unsupported language "$language" (expected ${supportedTemplateLanguages.join(' or ')})',
    );
  }

  id ??= fallbackId;
  if (id == null || id.isEmpty) {
    throw FormatException('$path: missing template id');
  }
  if (!_validTemplateId.hasMatch(id)) {
    throw FormatException('$path: invalid id "$id" (use lowercase letters, digits and dashes)');
  }

  final markdownText = body.trim();
  if (markdownText.isEmpty) {
    throw FormatException('$path: the markdown body is empty');
  }

  return TemplateSource(path: path, id: id, title: title, language: language, markdownText: markdownText);
}

/// Loads every `*.md` file under [directory] (recursively), sorted by path so
/// runs are deterministic. Throws [FormatException] on invalid or duplicate
/// templates.
List<TemplateSource> loadTemplateFiles(Directory directory) {
  if (!directory.existsSync()) {
    throw FormatException('Templates directory not found: ${directory.path}');
  }

  final files =
      directory
          .listSync(recursive: true, followLinks: false)
          .whereType<File>()
          .where((file) => file.path.toLowerCase().endsWith('.md'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  if (files.isEmpty) {
    throw FormatException('No .md template files found in ${directory.path}');
  }

  final sources = <TemplateSource>[];
  final seenIds = <String, String>{};
  for (final file in files) {
    final language = _languageFromPath(file);
    final slug = slugify(_fileNameWithoutExtension(file.path));
    final source = parseTemplateMarkdown(
      file.readAsStringSync(),
      path: file.path,
      fallbackLanguage: language,
      fallbackId: language == null ? slug : '$slug-$language',
    );

    final duplicateOf = seenIds[source.id];
    if (duplicateOf != null) {
      throw FormatException('Duplicate template id "${source.id}" in ${source.path} and $duplicateOf');
    }
    seenIds[source.id] = source.path;
    sources.add(source);
  }
  return sources;
}

/// What to do when a template already exists in Firestore.
enum TemplateImportMode {
  /// Overwrite the stored template (files win). Unchanged templates are left
  /// untouched so `updatedAt` does not churn.
  update,

  /// Leave the stored template alone.
  skip,

  /// Abort the whole import.
  fail,
}

enum TemplateChangeAction { create, update }

/// A single create/update to apply.
class TemplateChange {
  const TemplateChange({required this.action, required this.template});

  final TemplateChangeAction action;
  final Template template;
}

/// The outcome of diffing markdown files against Firestore.
class TemplateImportPlan {
  const TemplateImportPlan({
    required this.changes,
    required this.unchanged,
    required this.skipped,
    required this.staleIds,
  });

  /// Documents to write (creates and updates).
  final List<TemplateChange> changes;

  /// Existing templates identical to their file; not written.
  final List<Template> unchanged;

  /// Existing templates left alone because of [TemplateImportMode.skip].
  final List<Template> skipped;

  /// Existing IDs with no matching file, candidates for `--prune`.
  final List<String> staleIds;

  int get createdCount => changes.where((c) => c.action == TemplateChangeAction.create).length;
  int get updatedCount => changes.where((c) => c.action == TemplateChangeAction.update).length;
}

/// Diffs [sources] against [existing].
///
/// New templates get [authorId] and [now] for both timestamps. Updates keep the
/// original `createdAt`/`createdBy` and only bump `updatedAt`.
TemplateImportPlan planTemplateImport({
  required List<TemplateSource> sources,
  required List<Template> existing,
  required String authorId,
  required DateTime now,
  TemplateImportMode mode = TemplateImportMode.update,
}) {
  final existingById = {for (final template in existing) template.id: template};
  final changes = <TemplateChange>[];
  final unchanged = <Template>[];
  final skipped = <Template>[];
  final sourceIds = <String>{};

  for (final source in sources) {
    sourceIds.add(source.id);
    final current = existingById[source.id];

    if (current == null) {
      changes.add(
        TemplateChange(
          action: TemplateChangeAction.create,
          template: source.toTemplate(createdBy: authorId, createdAt: now, updatedAt: now),
        ),
      );
      continue;
    }

    switch (mode) {
      case TemplateImportMode.fail:
        throw FormatException(
          'Template "${source.id}" already exists (${source.path}). '
          'Use --if-exists update or --if-exists skip.',
        );
      case TemplateImportMode.skip:
        skipped.add(current);
      case TemplateImportMode.update:
        final isSame =
            current.title == source.title &&
            current.language == source.language &&
            current.markdownText == source.markdownText;
        if (isSame) {
          unchanged.add(current);
        } else {
          changes.add(
            TemplateChange(
              action: TemplateChangeAction.update,
              template: source.toTemplate(
                createdBy: current.createdBy,
                createdAt: current.createdAt,
                updatedAt: now,
              ),
            ),
          );
        }
    }
  }

  final staleIds = existingById.keys.where((id) => !sourceIds.contains(id)).toList()..sort();
  return TemplateImportPlan(changes: changes, unchanged: unchanged, skipped: skipped, staleIds: staleIds);
}

/// Serializes [template] back to the markdown file format used by [loadTemplateFiles].
String templateToMarkdown(Template template) {
  return [
    '---',
    'title: ${_yamlString(template.title)}',
    'id: ${template.id}',
    'language: ${template.language}',
    '---',
    '',
    template.markdownText,
    '',
  ].join('\n');
}

/// Finds the repository's `content/templates` directory, walking up from the
/// current directory. Pass [path] to override.
Directory resolveTemplatesDirectory([String? path]) {
  if (path != null && path.trim().isNotEmpty) {
    return Directory(path.trim());
  }

  var directory = Directory.current.absolute;
  while (true) {
    final candidate = Directory(
      [directory.path, 'content', 'templates'].join(Platform.pathSeparator),
    );
    if (candidate.existsSync()) return candidate;

    final parent = directory.parent;
    if (parent.path == directory.path) break;
    directory = parent;
  }

  throw FormatException(
    'Could not find content/templates from ${Directory.current.path}. '
    'Run from the repository or pass a directory explicitly.',
  );
}

/// Lowercase, dash-separated slug: "What to Bring!" → "what-to-bring".
String slugify(String value) {
  return value
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
}

String? _stringValue(Object? value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

String? _languageFromPath(File file) {
  final segments = file.parent.uri.pathSegments.where((segment) => segment.isNotEmpty);
  if (segments.isEmpty) return null;
  final parent = segments.last.toLowerCase();
  return supportedTemplateLanguages.contains(parent) ? parent : null;
}

String _fileNameWithoutExtension(String path) {
  final name = path.split(Platform.pathSeparator).last;
  final dot = name.lastIndexOf('.');
  return dot <= 0 ? name : name.substring(0, dot);
}

/// Quotes a value for YAML so titles with colons, quotes or hashes round-trip.
String _yamlString(String value) {
  final escaped = value
      .replaceAll(r'\', r'\\')
      .replaceAll('"', r'\"')
      .replaceAll('\n', r'\n')
      .replaceAll('\r', r'\r');
  return '"$escaped"';
}
