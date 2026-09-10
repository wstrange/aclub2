// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'section_member.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SectionMember _$SectionMemberFromJson(Map<String, dynamic> json) =>
    _SectionMember(
      userId: json['userId'] as String,
      sectionId: json['sectionId'] as String,
      sectionRole: $enumDecode(_$SectionRoleEnumMap, json['sectionRole']),
      externalSystemId: json['externalSystemId'] as String?,
      joinedAt: const TimestampConverter().fromJson(
        json['joinedAt'] as Timestamp,
      ),
    );

Map<String, dynamic> _$SectionMemberToJson(_SectionMember instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'sectionId': instance.sectionId,
      'sectionRole': _$SectionRoleEnumMap[instance.sectionRole]!,
      'externalSystemId': instance.externalSystemId,
      'joinedAt': const TimestampConverter().toJson(instance.joinedAt),
    };

const _$SectionRoleEnumMap = {
  SectionRole.sectionManager: 'sectionManager',
  SectionRole.tripLeader: 'tripLeader',
  SectionRole.member: 'member',
};

// **************************************************************************
// ModelBuilderGenerator
// **************************************************************************

Map<String, dynamic>? SectionMemberToJson(SectionMember? instance) =>
    instance == null
    ? null
    : {
        'userId': instance.userId,
        'sectionId': instance.sectionId,
        'sectionRole': _$SectionMemberSectionRoleToJson(instance.sectionRole),
        'externalSystemId': instance.externalSystemId,
        'joinedAt': instance.joinedAt == null
            ? null
            : const TimestampConverter().toJson(instance.joinedAt),
      };
SectionMember SectionMemberFromJson(Map<String, dynamic> json) => SectionMember(
  userId: (json['userId'] as String),
  sectionId: (json['sectionId'] as String),
  sectionRole: _$SectionMemberSectionRoleFromJson(json['sectionRole']),
  externalSystemId: json['externalSystemId'] == null
      ? null
      : (json['externalSystemId'] as String?),
  joinedAt: const TimestampConverter().fromJson(json['joinedAt']),
);
Object? _$SectionMemberSectionRoleToJson(SectionRole? value) => value == null
    ? null
    : {
        SectionRole.sectionManager: 'sectionManager',
        SectionRole.tripLeader: 'tripLeader',
        SectionRole.member: 'member',
      }[value];
SectionRole _$SectionMemberSectionRoleFromJson(Object? value) {
  return switch (value) {
    'sectionManager' => SectionRole.sectionManager,
    'tripLeader' => SectionRole.tripLeader,
    'member' => SectionRole.member,
    _ => throw ArgumentError("Unknown enum value for SectionRole"),
  };
}

class SectionMemberPatchBuilder extends PatchBuilder<SectionMember> {
  /// Creates a patch builder for `SectionMember`.
  SectionMemberPatchBuilder();

  /// Patch handle for `userId` (document field `userId`).
  late final FieldUpdate<String> userId = FieldUpdate(
    field: const FieldNode(components: ['userId']),
    toJson: (value) {
      return value;
    },
  );

  /// Patch handle for `sectionId` (document field `sectionId`).
  late final FieldUpdate<String> sectionId = FieldUpdate(
    field: const FieldNode(components: ['sectionId']),
    toJson: (value) {
      return value;
    },
  );

  /// Patch handle for `sectionRole` (document field `sectionRole`).
  late final FieldUpdate<SectionRole> sectionRole = FieldUpdate(
    field: const FieldNode(components: ['sectionRole']),
    toJson: (value) {
      return _$SectionMemberSectionRoleToJson(value);
    },
  );

  /// Patch handle for `externalSystemId` (document field `externalSystemId`).
  late final FieldUpdate<String?> externalSystemId = FieldUpdate(
    field: const FieldNode(components: ['externalSystemId']),
    toJson: (value) {
      return value;
    },
  );

  /// Patch handle for `joinedAt` (document field `joinedAt`).
  late final DateTimeFieldUpdate joinedAt = DateTimeFieldUpdate(
    field: const FieldNode(components: ['joinedAt']),
    toJson: (value) {
      return value == null ? null : const TimestampConverter().toJson(value);
    },
  );
}

class SectionMemberFilterBuilder extends FilterBuilderRoot {
  SectionMemberFilterBuilder({super.field});

  /// Selector for `userId`.
  late final FilterField<String, String> userId = FilterField<String, String>(
    field: append('userId'),
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `sectionId`.
  late final FilterField<String, String> sectionId =
      FilterField<String, String>(
        field: append('sectionId'),
        toJson: (value) {
          return value;
        },
      );

  /// Selector for `sectionRole`.
  late final FilterField<SectionRole, SectionRole> sectionRole =
      FilterField<SectionRole, SectionRole>(
        field: append('sectionRole'),
        toJson: (value) {
          return _$SectionMemberSectionRoleToJson(value);
        },
      );

  /// Selector for `externalSystemId`.
  late final FilterField<String?, String?> externalSystemId =
      FilterField<String?, String?>(
        field: append('externalSystemId'),
        toJson: (value) {
          return value;
        },
      );

  /// Selector for `joinedAt`.
  late final FilterField<DateTime, DateTime> joinedAt =
      FilterField<DateTime, DateTime>(
        field: append('joinedAt'),
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

class SectionMemberOrderByBuilder extends OrderByBuilderRoot {
  SectionMemberOrderByBuilder({super.field, required OrderByContext context})
    : _context = context;

  final OrderByContext _context;

  /// Selector for `userId`.
  late final OrderByField<String> userId = OrderByField(
    field: append('userId'),
    context: _context,
  );

  /// Selector for `sectionId`.
  late final OrderByField<String> sectionId = OrderByField(
    field: append('sectionId'),
    context: _context,
  );

  /// Selector for `sectionRole`.
  late final OrderByField<SectionRole> sectionRole = OrderByField(
    field: append('sectionRole'),
    context: _context,
    defaultValue: SectionRole.values.first,
  );

  /// Selector for `externalSystemId`.
  late final OrderByField<String?> externalSystemId = OrderByField(
    field: append('externalSystemId'),
    context: _context,
  );

  /// Selector for `joinedAt`.
  late final OrderByField<DateTime> joinedAt = OrderByField(
    field: append('joinedAt'),
    context: _context,
  );

  /// The document ID pseudo-field.
  late final OrderByField<String> documentId = OrderByField(
    field: const DocumentIdNode(),
    context: _context,
  );
}

class SectionMemberAggregateBuilder extends AggregateBuilderRoot {
  SectionMemberAggregateBuilder({
    super.field,
    required AggregateContext context,
  }) : _context = context;

  final AggregateContext _context;

  @override
  int count() => _context.resolve(const CountOperation('count'));
}

class SectionMemberPipelineSelector extends PipelineFieldNode {
  SectionMemberPipelineSelector({super.components, super.context});

  /// Selector for `userId`.
  late final PipelineField<String> userId = PipelineField(
    components: [...components, 'userId'],
    context: $ctx,
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `sectionId`.
  late final PipelineField<String> sectionId = PipelineField(
    components: [...components, 'sectionId'],
    context: $ctx,
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `sectionRole`.
  late final PipelineField<SectionRole> sectionRole = PipelineField(
    components: [...components, 'sectionRole'],
    context: $ctx,
    toJson: (value) {
      return _$SectionMemberSectionRoleToJson(value);
    },
  );

  /// Selector for `externalSystemId`.
  late final PipelineField<String?> externalSystemId = PipelineField(
    components: [...components, 'externalSystemId'],
    context: $ctx,
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `joinedAt`.
  late final PipelineField<DateTime> joinedAt = PipelineField(
    components: [...components, 'joinedAt'],
    context: $ctx,
    toJson: (value) {
      return value == null ? null : const TimestampConverter().toJson(value);
    },
  );
}

extension SectionMemberPipelineExtension<S extends FirestoreSchema>
    on
        FirestoreCollection<
          S,
          SectionMember,
          SectionMemberPatchBuilder,
          SectionMemberFilterBuilder,
          SectionMemberOrderByBuilder,
          SectionMemberAggregateBuilder
        > {
  TypedPipeline<SectionMember, SectionMemberPipelineSelector> pipeline() =>
      TypedPipeline(
        ref.firestore.pipeline().collection(ref.path),
        SectionMemberFromJson,
        null,
        (context) => SectionMemberPipelineSelector(context: context),
      );
}
