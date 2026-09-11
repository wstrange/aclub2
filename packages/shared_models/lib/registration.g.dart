// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'registration.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Registration _$RegistrationFromJson(Map<String, dynamic> json) =>
    _Registration(
      id: json['id'] as String,
      userId: json['userId'] as String,
      guestName: json['guestName'] as String?,
      status:
          $enumDecodeNullable(_$RegistrationStatusEnumMap, json['status']) ??
          RegistrationStatus.pending,
      isDriver: json['isDriver'] as bool?,
      needsRide: json['needsRide'] as bool?,
      registeredAt: const TimestampConverter().fromJson(
        json['registeredAt'] as Object,
      ),
      updatedAt: const TimestampConverter().fromJson(
        json['updatedAt'] as Object,
      ),
    );

Map<String, dynamic> _$RegistrationToJson(_Registration instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'guestName': instance.guestName,
      'status': _$RegistrationStatusEnumMap[instance.status]!,
      'isDriver': instance.isDriver,
      'needsRide': instance.needsRide,
      'registeredAt': const TimestampConverter().toJson(instance.registeredAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
    };

const _$RegistrationStatusEnumMap = {
  RegistrationStatus.pending: 'pending',
  RegistrationStatus.approved: 'approved',
  RegistrationStatus.waitlisted: 'waitlisted',
  RegistrationStatus.rejected: 'rejected',
  RegistrationStatus.attended: 'attended',
  RegistrationStatus.absent: 'absent',
};

// **************************************************************************
// ModelBuilderGenerator
// **************************************************************************

Map<String, dynamic>? RegistrationToJson(Registration? instance) =>
    instance == null
    ? null
    : {
        'id': instance.id,
        'userId': instance.userId,
        'guestName': instance.guestName,
        'status': _$RegistrationRegistrationStatusToJson(instance.status),
        'isDriver': instance.isDriver,
        'needsRide': instance.needsRide,
        'registeredAt': instance.registeredAt == null
            ? null
            : const TimestampConverter().toJson(instance.registeredAt),
        'updatedAt': instance.updatedAt == null
            ? null
            : const TimestampConverter().toJson(instance.updatedAt),
      };
Registration RegistrationFromJson(Map<String, dynamic> json) => Registration(
  id: (json['id'] as String),
  userId: (json['userId'] as String),
  guestName: json['guestName'] == null ? null : (json['guestName'] as String?),
  status: _$RegistrationRegistrationStatusFromJson(json['status']),
  isDriver: json['isDriver'] == null ? null : (json['isDriver'] as bool?),
  needsRide: json['needsRide'] == null ? null : (json['needsRide'] as bool?),
  registeredAt: const TimestampConverter().fromJson(json['registeredAt']),
  updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
);
Object? _$RegistrationRegistrationStatusToJson(RegistrationStatus? value) =>
    value == null
    ? null
    : {
        RegistrationStatus.pending: 'pending',
        RegistrationStatus.approved: 'approved',
        RegistrationStatus.waitlisted: 'waitlisted',
        RegistrationStatus.rejected: 'rejected',
        RegistrationStatus.attended: 'attended',
        RegistrationStatus.absent: 'absent',
      }[value];
RegistrationStatus _$RegistrationRegistrationStatusFromJson(Object? value) {
  return switch (value) {
    'pending' => RegistrationStatus.pending,
    'approved' => RegistrationStatus.approved,
    'waitlisted' => RegistrationStatus.waitlisted,
    'rejected' => RegistrationStatus.rejected,
    'attended' => RegistrationStatus.attended,
    'absent' => RegistrationStatus.absent,
    _ => throw ArgumentError("Unknown enum value for RegistrationStatus"),
  };
}

class RegistrationPatchBuilder extends PatchBuilder<Registration> {
  /// Creates a patch builder for `Registration`.
  RegistrationPatchBuilder();

  /// Patch handle for `userId` (document field `userId`).
  late final FieldUpdate<String> userId = FieldUpdate(
    field: const FieldNode(components: ['userId']),
    toJson: (value) {
      return value;
    },
  );

  /// Patch handle for `guestName` (document field `guestName`).
  late final FieldUpdate<String?> guestName = FieldUpdate(
    field: const FieldNode(components: ['guestName']),
    toJson: (value) {
      return value;
    },
  );

  /// Patch handle for `status` (document field `status`).
  late final FieldUpdate<RegistrationStatus> status = FieldUpdate(
    field: const FieldNode(components: ['status']),
    toJson: (value) {
      return _$RegistrationRegistrationStatusToJson(value);
    },
  );

  /// Patch handle for `isDriver` (document field `isDriver`).
  late final FieldUpdate<bool?> isDriver = FieldUpdate(
    field: const FieldNode(components: ['isDriver']),
    toJson: (value) {
      return value;
    },
  );

  /// Patch handle for `needsRide` (document field `needsRide`).
  late final FieldUpdate<bool?> needsRide = FieldUpdate(
    field: const FieldNode(components: ['needsRide']),
    toJson: (value) {
      return value;
    },
  );

  /// Patch handle for `registeredAt` (document field `registeredAt`).
  late final DateTimeFieldUpdate registeredAt = DateTimeFieldUpdate(
    field: const FieldNode(components: ['registeredAt']),
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

class RegistrationFilterBuilder extends FilterBuilderRoot {
  RegistrationFilterBuilder({super.field});

  /// Selector for `id`.
  late final FilterField<String, String> id = FilterField<String, String>(
    field: append('id'),
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `userId`.
  late final FilterField<String, String> userId = FilterField<String, String>(
    field: append('userId'),
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `guestName`.
  late final FilterField<String?, String?> guestName =
      FilterField<String?, String?>(
        field: append('guestName'),
        toJson: (value) {
          return value;
        },
      );

  /// Selector for `status`.
  late final FilterField<RegistrationStatus, RegistrationStatus> status =
      FilterField<RegistrationStatus, RegistrationStatus>(
        field: append('status'),
        toJson: (value) {
          return _$RegistrationRegistrationStatusToJson(value);
        },
      );

  /// Selector for `isDriver`.
  late final FilterField<bool?, bool?> isDriver = FilterField<bool?, bool?>(
    field: append('isDriver'),
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `needsRide`.
  late final FilterField<bool?, bool?> needsRide = FilterField<bool?, bool?>(
    field: append('needsRide'),
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `registeredAt`.
  late final FilterField<DateTime, DateTime> registeredAt =
      FilterField<DateTime, DateTime>(
        field: append('registeredAt'),
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

class RegistrationOrderByBuilder extends OrderByBuilderRoot {
  RegistrationOrderByBuilder({super.field, required OrderByContext context})
    : _context = context;

  final OrderByContext _context;

  /// Selector for `id`.
  late final OrderByField<String> id = OrderByField(
    field: append('id'),
    context: _context,
  );

  /// Selector for `userId`.
  late final OrderByField<String> userId = OrderByField(
    field: append('userId'),
    context: _context,
  );

  /// Selector for `guestName`.
  late final OrderByField<String?> guestName = OrderByField(
    field: append('guestName'),
    context: _context,
  );

  /// Selector for `status`.
  late final OrderByField<RegistrationStatus> status = OrderByField(
    field: append('status'),
    context: _context,
    defaultValue: RegistrationStatus.values.first,
  );

  /// Selector for `isDriver`.
  late final OrderByField<bool?> isDriver = OrderByField(
    field: append('isDriver'),
    context: _context,
  );

  /// Selector for `needsRide`.
  late final OrderByField<bool?> needsRide = OrderByField(
    field: append('needsRide'),
    context: _context,
  );

  /// Selector for `registeredAt`.
  late final OrderByField<DateTime> registeredAt = OrderByField(
    field: append('registeredAt'),
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

class RegistrationAggregateBuilder extends AggregateBuilderRoot {
  RegistrationAggregateBuilder({super.field, required AggregateContext context})
    : _context = context;

  final AggregateContext _context;

  @override
  int count() => _context.resolve(const CountOperation('count'));
}

class RegistrationPipelineSelector extends PipelineFieldNode {
  RegistrationPipelineSelector({super.components, super.context});

  /// Selector for `id`.
  late final PipelineField<String> id = PipelineField(
    components: [...components, 'id'],
    context: $ctx,
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `userId`.
  late final PipelineField<String> userId = PipelineField(
    components: [...components, 'userId'],
    context: $ctx,
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `guestName`.
  late final PipelineField<String?> guestName = PipelineField(
    components: [...components, 'guestName'],
    context: $ctx,
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `status`.
  late final PipelineField<RegistrationStatus> status = PipelineField(
    components: [...components, 'status'],
    context: $ctx,
    toJson: (value) {
      return _$RegistrationRegistrationStatusToJson(value);
    },
  );

  /// Selector for `isDriver`.
  late final PipelineField<bool?> isDriver = PipelineField(
    components: [...components, 'isDriver'],
    context: $ctx,
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `needsRide`.
  late final PipelineField<bool?> needsRide = PipelineField(
    components: [...components, 'needsRide'],
    context: $ctx,
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `registeredAt`.
  late final PipelineField<DateTime> registeredAt = PipelineField(
    components: [...components, 'registeredAt'],
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

extension RegistrationPipelineExtension<S extends FirestoreSchema>
    on
        FirestoreCollection<
          S,
          Registration,
          RegistrationPatchBuilder,
          RegistrationFilterBuilder,
          RegistrationOrderByBuilder,
          RegistrationAggregateBuilder
        > {
  TypedPipeline<Registration, RegistrationPipelineSelector> pipeline() =>
      TypedPipeline(
        ref.firestore.pipeline().collection(ref.path),
        RegistrationFromJson,
        'id',
        (context) => RegistrationPipelineSelector(context: context),
      );
}
