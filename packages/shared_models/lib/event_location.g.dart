// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_location.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EventLocation _$EventLocationFromJson(Map<String, dynamic> json) =>
    _EventLocation(
      description: json['description'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      mapUrl: json['mapUrl'] as String?,
    );

Map<String, dynamic> _$EventLocationToJson(_EventLocation instance) =>
    <String, dynamic>{
      'description': instance.description,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'mapUrl': instance.mapUrl,
    };

// **************************************************************************
// ModelBuilderGenerator
// **************************************************************************

Map<String, dynamic>? EventLocationToJson(EventLocation? instance) =>
    instance == null
    ? null
    : {
        'description': instance.description,
        'latitude': instance.latitude,
        'longitude': instance.longitude,
        'mapUrl': instance.mapUrl,
      };
EventLocation EventLocationFromJson(Map<String, dynamic> json) => EventLocation(
  description: json['description'] == null
      ? null
      : (json['description'] as String?),
  latitude: json['latitude'] == null ? null : (json['latitude'] as double?),
  longitude: json['longitude'] == null ? null : (json['longitude'] as double?),
  mapUrl: json['mapUrl'] == null ? null : (json['mapUrl'] as String?),
);

class EventLocationPatchBuilder extends PatchBuilder<EventLocation> {
  /// Creates a patch builder for `EventLocation`.
  EventLocationPatchBuilder();

  /// Patch handle for `description` (document field `description`).
  late final FieldUpdate<String?> description = FieldUpdate(
    field: const FieldNode(components: ['description']),
    toJson: (value) {
      return value;
    },
  );

  /// Patch handle for `latitude` (document field `latitude`).
  late final FieldUpdate<double?> latitude = FieldUpdate(
    field: const FieldNode(components: ['latitude']),
    toJson: (value) {
      return value;
    },
  );

  /// Patch handle for `longitude` (document field `longitude`).
  late final FieldUpdate<double?> longitude = FieldUpdate(
    field: const FieldNode(components: ['longitude']),
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

class EventLocationFilterBuilder extends FilterBuilderRoot {
  EventLocationFilterBuilder({super.field});

  /// Selector for `description`.
  late final FilterField<String?, String?> description =
      FilterField<String?, String?>(
        field: append('description'),
        toJson: (value) {
          return value;
        },
      );

  /// Selector for `latitude`.
  late final FilterField<double?, double?> latitude =
      FilterField<double?, double?>(
        field: append('latitude'),
        toJson: (value) {
          return value;
        },
      );

  /// Selector for `longitude`.
  late final FilterField<double?, double?> longitude =
      FilterField<double?, double?>(
        field: append('longitude'),
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

class EventLocationOrderByBuilder extends OrderByBuilderRoot {
  EventLocationOrderByBuilder({super.field, required OrderByContext context})
    : _context = context;

  final OrderByContext _context;

  /// Selector for `description`.
  late final OrderByField<String?> description = OrderByField(
    field: append('description'),
    context: _context,
  );

  /// Selector for `latitude`.
  late final OrderByField<double?> latitude = OrderByField(
    field: append('latitude'),
    context: _context,
  );

  /// Selector for `longitude`.
  late final OrderByField<double?> longitude = OrderByField(
    field: append('longitude'),
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

class EventLocationAggregateBuilder extends AggregateBuilderRoot {
  EventLocationAggregateBuilder({
    super.field,
    required AggregateContext context,
  }) : _context = context;

  final AggregateContext _context;

  /// Selector for `latitude`.
  late final AggregateField<double?> latitude = AggregateField(
    field: append('latitude'),
    context: _context,
  );

  /// Selector for `longitude`.
  late final AggregateField<double?> longitude = AggregateField(
    field: append('longitude'),
    context: _context,
  );

  @override
  int count() => _context.resolve(const CountOperation('count'));
}

class EventLocationPipelineSelector extends PipelineFieldNode {
  EventLocationPipelineSelector({super.components, super.context});

  /// Selector for `description`.
  late final PipelineField<String?> description = PipelineField(
    components: [...components, 'description'],
    context: $ctx,
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `latitude`.
  late final PipelineField<double?> latitude = PipelineField(
    components: [...components, 'latitude'],
    context: $ctx,
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `longitude`.
  late final PipelineField<double?> longitude = PipelineField(
    components: [...components, 'longitude'],
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

extension EventLocationPipelineExtension<S extends FirestoreSchema>
    on
        FirestoreCollection<
          S,
          EventLocation,
          EventLocationPatchBuilder,
          EventLocationFilterBuilder,
          EventLocationOrderByBuilder,
          EventLocationAggregateBuilder
        > {
  TypedPipeline<EventLocation, EventLocationPipelineSelector> pipeline() =>
      TypedPipeline(
        ref.firestore.pipeline().collection(ref.path),
        EventLocationFromJson,
        null,
        (context) => EventLocationPipelineSelector(context: context),
      );
}
