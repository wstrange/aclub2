// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'template.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Template _$TemplateFromJson(Map<String, dynamic> json) => _Template(
  id: json['id'] as String,
  language: json['language'] as String,
  title: json['title'] as String,
  markdownText: json['markdownText'] as String,
  createdBy: json['createdBy'] as String,
  createdAt: const TimestampConverter().fromJson(json['createdAt'] as Object),
  updatedAt: const TimestampConverter().fromJson(json['updatedAt'] as Object),
);

Map<String, dynamic> _$TemplateToJson(_Template instance) => <String, dynamic>{
  'id': instance.id,
  'language': instance.language,
  'title': instance.title,
  'markdownText': instance.markdownText,
  'createdBy': instance.createdBy,
  'createdAt': const TimestampConverter().toJson(instance.createdAt),
  'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
};

// **************************************************************************
// ModelBuilderGenerator
// **************************************************************************

Map<String, dynamic>? TemplateToJson(Template? instance) => instance == null
    ? null
    : {
        'id': instance.id,
        'language': instance.language,
        'title': instance.title,
        'markdownText': instance.markdownText,
        'createdBy': instance.createdBy,
        'createdAt': instance.createdAt == null
            ? null
            : const TimestampConverter().toJson(instance.createdAt),
        'updatedAt': instance.updatedAt == null
            ? null
            : const TimestampConverter().toJson(instance.updatedAt),
      };
Template TemplateFromJson(Map<String, dynamic> json) => Template(
  id: (json['id'] as String),
  language: (json['language'] as String),
  title: (json['title'] as String),
  markdownText: (json['markdownText'] as String),
  createdBy: (json['createdBy'] as String),
  createdAt: const TimestampConverter().fromJson(json['createdAt']),
  updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
);

class TemplatePatchBuilder extends PatchBuilder<Template> {
  /// Creates a patch builder for `Template`.
  TemplatePatchBuilder();

  /// Patch handle for `language` (document field `language`).
  late final FieldUpdate<String> language = FieldUpdate(
    field: const FieldNode(components: ['language']),
    toJson: (value) {
      return value;
    },
  );

  /// Patch handle for `title` (document field `title`).
  late final FieldUpdate<String> title = FieldUpdate(
    field: const FieldNode(components: ['title']),
    toJson: (value) {
      return value;
    },
  );

  /// Patch handle for `markdownText` (document field `markdownText`).
  late final FieldUpdate<String> markdownText = FieldUpdate(
    field: const FieldNode(components: ['markdownText']),
    toJson: (value) {
      return value;
    },
  );

  /// Patch handle for `createdBy` (document field `createdBy`).
  late final FieldUpdate<String> createdBy = FieldUpdate(
    field: const FieldNode(components: ['createdBy']),
    toJson: (value) {
      return value;
    },
  );

  /// Patch handle for `createdAt` (document field `createdAt`).
  late final DateTimeFieldUpdate createdAt = DateTimeFieldUpdate(
    field: const FieldNode(components: ['createdAt']),
    toJson: (value) {
      return value == null ? null : const TimestampConverter().toJson(value);
    },
  );

  /// Patch handle for `updatedAt` (document field `updatedAt`).
  late final DateTimeFieldUpdate updatedAt = DateTimeFieldUpdate(
    field: const FieldNode(components: ['updatedAt']),
    toJson: (value) {
      return value == null ? null : const TimestampConverter().toJson(value);
    },
  );
}

class TemplateFilterBuilder extends FilterBuilderRoot {
  TemplateFilterBuilder({super.field});

  /// Selector for `id`.
  late final FilterField<String, String> id = FilterField<String, String>(
    field: append('id'),
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `language`.
  late final FilterField<String, String> language = FilterField<String, String>(
    field: append('language'),
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `title`.
  late final FilterField<String, String> title = FilterField<String, String>(
    field: append('title'),
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `markdownText`.
  late final FilterField<String, String> markdownText =
      FilterField<String, String>(
        field: append('markdownText'),
        toJson: (value) {
          return value;
        },
      );

  /// Selector for `createdBy`.
  late final FilterField<String, String> createdBy =
      FilterField<String, String>(
        field: append('createdBy'),
        toJson: (value) {
          return value;
        },
      );

  /// Selector for `createdAt`.
  late final FilterField<DateTime, DateTime> createdAt =
      FilterField<DateTime, DateTime>(
        field: append('createdAt'),
        toJson: (value) {
          return value == null
              ? null
              : const TimestampConverter().toJson(value);
        },
      );

  /// Selector for `updatedAt`.
  late final FilterField<DateTime, DateTime> updatedAt =
      FilterField<DateTime, DateTime>(
        field: append('updatedAt'),
        toJson: (value) {
          return value == null
              ? null
              : const TimestampConverter().toJson(value);
        },
      );

  /// The document ID pseudo-field.
  late final FilterField<String, String> documentId =
      FilterField<String, String>(
        field: const DocumentIdNode(),
        toJson: (value) {
          return value;
        },
      );
}

class TemplateOrderByBuilder extends OrderByBuilderRoot {
  TemplateOrderByBuilder({super.field, required OrderByContext context})
    : _context = context;

  final OrderByContext _context;

  /// Selector for `id`.
  late final OrderByField<String> id = OrderByField(
    field: append('id'),
    context: _context,
  );

  /// Selector for `language`.
  late final OrderByField<String> language = OrderByField(
    field: append('language'),
    context: _context,
  );

  /// Selector for `title`.
  late final OrderByField<String> title = OrderByField(
    field: append('title'),
    context: _context,
  );

  /// Selector for `markdownText`.
  late final OrderByField<String> markdownText = OrderByField(
    field: append('markdownText'),
    context: _context,
  );

  /// Selector for `createdBy`.
  late final OrderByField<String> createdBy = OrderByField(
    field: append('createdBy'),
    context: _context,
  );

  /// Selector for `createdAt`.
  late final OrderByField<DateTime> createdAt = OrderByField(
    field: append('createdAt'),
    context: _context,
  );

  /// Selector for `updatedAt`.
  late final OrderByField<DateTime> updatedAt = OrderByField(
    field: append('updatedAt'),
    context: _context,
  );

  /// The document ID pseudo-field.
  late final OrderByField<String> documentId = OrderByField(
    field: const DocumentIdNode(),
    context: _context,
  );
}

class TemplateAggregateBuilder extends AggregateBuilderRoot {
  TemplateAggregateBuilder({super.field, required AggregateContext context})
    : _context = context;

  final AggregateContext _context;

  @override
  int count() => _context.resolve(const CountOperation('count'));
}

class TemplatePipelineSelector extends PipelineFieldNode {
  TemplatePipelineSelector({super.components, super.context});

  /// Selector for `id`.
  late final PipelineField<String> id = PipelineField(
    components: [...components, 'id'],
    context: $ctx,
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `language`.
  late final PipelineField<String> language = PipelineField(
    components: [...components, 'language'],
    context: $ctx,
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `title`.
  late final PipelineField<String> title = PipelineField(
    components: [...components, 'title'],
    context: $ctx,
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `markdownText`.
  late final PipelineField<String> markdownText = PipelineField(
    components: [...components, 'markdownText'],
    context: $ctx,
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `createdBy`.
  late final PipelineField<String> createdBy = PipelineField(
    components: [...components, 'createdBy'],
    context: $ctx,
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `createdAt`.
  late final PipelineField<DateTime> createdAt = PipelineField(
    components: [...components, 'createdAt'],
    context: $ctx,
    toJson: (value) {
      return value == null ? null : const TimestampConverter().toJson(value);
    },
  );

  /// Selector for `updatedAt`.
  late final PipelineField<DateTime> updatedAt = PipelineField(
    components: [...components, 'updatedAt'],
    context: $ctx,
    toJson: (value) {
      return value == null ? null : const TimestampConverter().toJson(value);
    },
  );
}

extension TemplatePipelineExtension<S extends FirestoreSchema>
    on
        FirestoreCollection<
          S,
          Template,
          TemplatePatchBuilder,
          TemplateFilterBuilder,
          TemplateOrderByBuilder,
          TemplateAggregateBuilder
        > {
  TypedPipeline<Template, TemplatePipelineSelector> pipeline() => TypedPipeline(
    ref.firestore.pipeline().collection(ref.path),
    TemplateFromJson,
    'id',
    (context) => TemplatePipelineSelector(context: context),
  );
}
