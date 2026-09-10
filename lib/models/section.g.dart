// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'section.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Section _$SectionFromJson(Map<String, dynamic> json) => _Section(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  location: json['location'] as String?,
  contactEmail: json['contactEmail'] as String?,
  contactPhone: json['contactPhone'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$SectionToJson(_Section instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'location': instance.location,
  'contactEmail': instance.contactEmail,
  'contactPhone': instance.contactPhone,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

// **************************************************************************
// ModelBuilderGenerator
// **************************************************************************

Map<String, dynamic>? SectionToJson(Section? instance) => instance == null
    ? null
    : {
        'id': instance.id,
        'name': instance.name,
        'description': instance.description,
        'location': instance.location,
        'contactEmail': instance.contactEmail,
        'contactPhone': instance.contactPhone,
        'createdAt': instance.createdAt,
        'updatedAt': instance.updatedAt,
      };
Section SectionFromJson(Map<String, dynamic> json) => Section(
  id: (json['id'] as String),
  name: (json['name'] as String),
  description: json['description'] == null
      ? null
      : (json['description'] as String?),
  location: json['location'] == null ? null : (json['location'] as String?),
  contactEmail: json['contactEmail'] == null
      ? null
      : (json['contactEmail'] as String?),
  contactPhone: json['contactPhone'] == null
      ? null
      : (json['contactPhone'] as String?),
  createdAt: json['createdAt'] == null
      ? null
      : dateTimeFromJson(json['createdAt']),
  updatedAt: json['updatedAt'] == null
      ? null
      : dateTimeFromJson(json['updatedAt']),
);

class SectionPatchBuilder extends PatchBuilder<Section> {
  /// Creates a patch builder for `Section`.
  SectionPatchBuilder();

  /// Patch handle for `name` (document field `name`).
  late final FieldUpdate<String> name = FieldUpdate(
    field: const FieldNode(components: ['name']),
    toJson: (value) {
      return value;
    },
  );

  /// Patch handle for `description` (document field `description`).
  late final FieldUpdate<String?> description = FieldUpdate(
    field: const FieldNode(components: ['description']),
    toJson: (value) {
      return value;
    },
  );

  /// Patch handle for `location` (document field `location`).
  late final FieldUpdate<String?> location = FieldUpdate(
    field: const FieldNode(components: ['location']),
    toJson: (value) {
      return value;
    },
  );

  /// Patch handle for `contactEmail` (document field `contactEmail`).
  late final FieldUpdate<String?> contactEmail = FieldUpdate(
    field: const FieldNode(components: ['contactEmail']),
    toJson: (value) {
      return value;
    },
  );

  /// Patch handle for `contactPhone` (document field `contactPhone`).
  late final FieldUpdate<String?> contactPhone = FieldUpdate(
    field: const FieldNode(components: ['contactPhone']),
    toJson: (value) {
      return value;
    },
  );

  /// Patch handle for `createdAt` (document field `createdAt`).
  late final DateTimeFieldUpdate createdAt = DateTimeFieldUpdate(
    field: const FieldNode(components: ['createdAt']),
    toJson: (value) {
      return value;
    },
  );

  /// Patch handle for `updatedAt` (document field `updatedAt`).
  late final DateTimeFieldUpdate updatedAt = DateTimeFieldUpdate(
    field: const FieldNode(components: ['updatedAt']),
    toJson: (value) {
      return value;
    },
  );
}

class SectionFilterBuilder extends FilterBuilderRoot {
  SectionFilterBuilder({super.field});

  /// Selector for `id`.
  late final FilterField<String, String> id = FilterField<String, String>(
    field: append('id'),
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `name`.
  late final FilterField<String, String> name = FilterField<String, String>(
    field: append('name'),
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `description`.
  late final FilterField<String?, String?> description =
      FilterField<String?, String?>(
        field: append('description'),
        toJson: (value) {
          return value;
        },
      );

  /// Selector for `location`.
  late final FilterField<String?, String?> location =
      FilterField<String?, String?>(
        field: append('location'),
        toJson: (value) {
          return value;
        },
      );

  /// Selector for `contactEmail`.
  late final FilterField<String?, String?> contactEmail =
      FilterField<String?, String?>(
        field: append('contactEmail'),
        toJson: (value) {
          return value;
        },
      );

  /// Selector for `contactPhone`.
  late final FilterField<String?, String?> contactPhone =
      FilterField<String?, String?>(
        field: append('contactPhone'),
        toJson: (value) {
          return value;
        },
      );

  /// Selector for `createdAt`.
  late final FilterField<DateTime?, DateTime?> createdAt =
      FilterField<DateTime?, DateTime?>(
        field: append('createdAt'),
        toJson: (value) {
          return value;
        },
      );

  /// Selector for `updatedAt`.
  late final FilterField<DateTime?, DateTime?> updatedAt =
      FilterField<DateTime?, DateTime?>(
        field: append('updatedAt'),
        toJson: (value) {
          return value;
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

class SectionOrderByBuilder extends OrderByBuilderRoot {
  SectionOrderByBuilder({super.field, required OrderByContext context})
    : _context = context;

  final OrderByContext _context;

  /// Selector for `id`.
  late final OrderByField<String> id = OrderByField(
    field: append('id'),
    context: _context,
  );

  /// Selector for `name`.
  late final OrderByField<String> name = OrderByField(
    field: append('name'),
    context: _context,
  );

  /// Selector for `description`.
  late final OrderByField<String?> description = OrderByField(
    field: append('description'),
    context: _context,
  );

  /// Selector for `location`.
  late final OrderByField<String?> location = OrderByField(
    field: append('location'),
    context: _context,
  );

  /// Selector for `contactEmail`.
  late final OrderByField<String?> contactEmail = OrderByField(
    field: append('contactEmail'),
    context: _context,
  );

  /// Selector for `contactPhone`.
  late final OrderByField<String?> contactPhone = OrderByField(
    field: append('contactPhone'),
    context: _context,
  );

  /// Selector for `createdAt`.
  late final OrderByField<DateTime?> createdAt = OrderByField(
    field: append('createdAt'),
    context: _context,
  );

  /// Selector for `updatedAt`.
  late final OrderByField<DateTime?> updatedAt = OrderByField(
    field: append('updatedAt'),
    context: _context,
  );

  /// The document ID pseudo-field.
  late final OrderByField<String> documentId = OrderByField(
    field: const DocumentIdNode(),
    context: _context,
  );
}

class SectionAggregateBuilder extends AggregateBuilderRoot {
  SectionAggregateBuilder({super.field, required AggregateContext context})
    : _context = context;

  final AggregateContext _context;

  @override
  int count() => _context.resolve(const CountOperation('count'));
}

class SectionPipelineSelector extends PipelineFieldNode {
  SectionPipelineSelector({super.components, super.context});

  /// Selector for `id`.
  late final PipelineField<String> id = PipelineField(
    components: [...components, 'id'],
    context: $ctx,
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `name`.
  late final PipelineField<String> name = PipelineField(
    components: [...components, 'name'],
    context: $ctx,
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `description`.
  late final PipelineField<String?> description = PipelineField(
    components: [...components, 'description'],
    context: $ctx,
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `location`.
  late final PipelineField<String?> location = PipelineField(
    components: [...components, 'location'],
    context: $ctx,
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `contactEmail`.
  late final PipelineField<String?> contactEmail = PipelineField(
    components: [...components, 'contactEmail'],
    context: $ctx,
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `contactPhone`.
  late final PipelineField<String?> contactPhone = PipelineField(
    components: [...components, 'contactPhone'],
    context: $ctx,
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `createdAt`.
  late final PipelineField<DateTime?> createdAt = PipelineField(
    components: [...components, 'createdAt'],
    context: $ctx,
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `updatedAt`.
  late final PipelineField<DateTime?> updatedAt = PipelineField(
    components: [...components, 'updatedAt'],
    context: $ctx,
    toJson: (value) {
      return value;
    },
  );
}

extension SectionPipelineExtension<S extends FirestoreSchema>
    on
        FirestoreCollection<
          S,
          Section,
          SectionPatchBuilder,
          SectionFilterBuilder,
          SectionOrderByBuilder,
          SectionAggregateBuilder
        > {
  TypedPipeline<Section, SectionPipelineSelector> pipeline() => TypedPipeline(
    ref.firestore.pipeline().collection(ref.path),
    SectionFromJson,
    'id',
    (context) => SectionPipelineSelector(context: context),
  );
}
