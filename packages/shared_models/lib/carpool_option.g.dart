// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'carpool_option.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CarpoolOption _$CarpoolOptionFromJson(Map<String, dynamic> json) =>
    _CarpoolOption(
      meetTime: const TimestampConverter().fromJson(json['meetTime'] as Object),
      meetPlace: json['meetPlace'] as String,
      mapUrl: json['mapUrl'] as String?,
    );

Map<String, dynamic> _$CarpoolOptionToJson(_CarpoolOption instance) =>
    <String, dynamic>{
      'meetTime': const TimestampConverter().toJson(instance.meetTime),
      'meetPlace': instance.meetPlace,
      'mapUrl': instance.mapUrl,
    };

// **************************************************************************
// ModelBuilderGenerator
// **************************************************************************

Map<String, dynamic>? CarpoolOptionToJson(CarpoolOption? instance) =>
    instance == null
    ? null
    : {
        'meetTime': instance.meetTime == null
            ? null
            : const TimestampConverter().toJson(instance.meetTime),
        'meetPlace': instance.meetPlace,
        'mapUrl': instance.mapUrl,
      };
CarpoolOption CarpoolOptionFromJson(Map<String, dynamic> json) => CarpoolOption(
  meetTime: const TimestampConverter().fromJson(json['meetTime']),
  meetPlace: (json['meetPlace'] as String),
  mapUrl: json['mapUrl'] == null ? null : (json['mapUrl'] as String?),
);

class CarpoolOptionPatchBuilder extends PatchBuilder<CarpoolOption> {
  /// Creates a patch builder for `CarpoolOption`.
  CarpoolOptionPatchBuilder();

  /// Patch handle for `meetTime` (document field `meetTime`).
  late final DateTimeFieldUpdate meetTime = DateTimeFieldUpdate(
    field: const FieldNode(components: ['meetTime']),
    toJson: (value) {
      return value == null ? null : const TimestampConverter().toJson(value);
    },
  );

  /// Patch handle for `meetPlace` (document field `meetPlace`).
  late final FieldUpdate<String> meetPlace = FieldUpdate(
    field: const FieldNode(components: ['meetPlace']),
    toJson: (value) {
      return value;
    },
  );

  /// Patch handle for `mapUrl` (document field `mapUrl`).
  late final FieldUpdate<String?> mapUrl = FieldUpdate(
    field: const FieldNode(components: ['mapUrl']),
    toJson: (value) {
      return value;
    },
  );
}

class CarpoolOptionFilterBuilder extends FilterBuilderRoot {
  CarpoolOptionFilterBuilder({super.field});

  /// Selector for `meetTime`.
  late final FilterField<DateTime, DateTime> meetTime =
      FilterField<DateTime, DateTime>(
        field: append('meetTime'),
        toJson: (value) {
          return value == null
              ? null
              : const TimestampConverter().toJson(value);
        },
      );

  /// Selector for `meetPlace`.
  late final FilterField<String, String> meetPlace =
      FilterField<String, String>(
        field: append('meetPlace'),
        toJson: (value) {
          return value;
        },
      );

  /// Selector for `mapUrl`.
  late final FilterField<String?, String?> mapUrl =
      FilterField<String?, String?>(
        field: append('mapUrl'),
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

class CarpoolOptionOrderByBuilder extends OrderByBuilderRoot {
  CarpoolOptionOrderByBuilder({super.field, required OrderByContext context})
    : _context = context;

  final OrderByContext _context;

  /// Selector for `meetTime`.
  late final OrderByField<DateTime> meetTime = OrderByField(
    field: append('meetTime'),
    context: _context,
  );

  /// Selector for `meetPlace`.
  late final OrderByField<String> meetPlace = OrderByField(
    field: append('meetPlace'),
    context: _context,
  );

  /// Selector for `mapUrl`.
  late final OrderByField<String?> mapUrl = OrderByField(
    field: append('mapUrl'),
    context: _context,
  );

  /// The document ID pseudo-field.
  late final OrderByField<String> documentId = OrderByField(
    field: const DocumentIdNode(),
    context: _context,
  );
}

class CarpoolOptionAggregateBuilder extends AggregateBuilderRoot {
  CarpoolOptionAggregateBuilder({
    super.field,
    required AggregateContext context,
  }) : _context = context;

  final AggregateContext _context;

  @override
  int count() => _context.resolve(const CountOperation('count'));
}

class CarpoolOptionPipelineSelector extends PipelineFieldNode {
  CarpoolOptionPipelineSelector({super.components, super.context});

  /// Selector for `meetTime`.
  late final PipelineField<DateTime> meetTime = PipelineField(
    components: [...components, 'meetTime'],
    context: $ctx,
    toJson: (value) {
      return value == null ? null : const TimestampConverter().toJson(value);
    },
  );

  /// Selector for `meetPlace`.
  late final PipelineField<String> meetPlace = PipelineField(
    components: [...components, 'meetPlace'],
    context: $ctx,
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `mapUrl`.
  late final PipelineField<String?> mapUrl = PipelineField(
    components: [...components, 'mapUrl'],
    context: $ctx,
    toJson: (value) {
      return value;
    },
  );
}

extension CarpoolOptionPipelineExtension<S extends FirestoreSchema>
    on
        FirestoreCollection<
          S,
          CarpoolOption,
          CarpoolOptionPatchBuilder,
          CarpoolOptionFilterBuilder,
          CarpoolOptionOrderByBuilder,
          CarpoolOptionAggregateBuilder
        > {
  TypedPipeline<CarpoolOption, CarpoolOptionPipelineSelector> pipeline() =>
      TypedPipeline(
        ref.firestore.pipeline().collection(ref.path),
        CarpoolOptionFromJson,
        null,
        (context) => CarpoolOptionPipelineSelector(context: context),
      );
}
