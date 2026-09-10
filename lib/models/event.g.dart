// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Event _$EventFromJson(Map<String, dynamic> json) => _Event(
  id: json['id'] as String,
  sectionId: json['sectionId'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  type: $enumDecode(_$EventTypeEnumMap, json['type']),
  status:
      $enumDecodeNullable(_$EventStatusEnumMap, json['status']) ??
      EventStatus.draft,
  startDate: const TimestampConverter().fromJson(
    json['startDate'] as Timestamp,
  ),
  endDate: const TimestampConverter().fromJson(json['endDate'] as Timestamp),
  location: json['location'] == null
      ? null
      : EventLocation.fromJson(json['location'] as Map<String, dynamic>),
  carpoolOption: json['carpoolOption'] == null
      ? null
      : CarpoolOption.fromJson(json['carpoolOption'] as Map<String, dynamic>),
  minParticipants: (json['minParticipants'] as num?)?.toInt() ?? 0,
  maxParticipants: (json['maxParticipants'] as num).toInt(),
  difficulty:
      $enumDecodeNullable(_$DifficultyEnumMap, json['difficulty']) ??
      Difficulty.moderate,
  requiresApproval: json['requiresApproval'] as bool? ?? false,
  requiredEquipment:
      (json['requiredEquipment'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  prerequisites:
      (json['prerequisites'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  creatorId: json['creatorId'] as String,
  tripLeaderIds:
      (json['tripLeaderIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  createdAt: const TimestampConverter().fromJson(
    json['createdAt'] as Timestamp,
  ),
  updatedAt: const TimestampConverter().fromJson(
    json['updatedAt'] as Timestamp,
  ),
);

Map<String, dynamic> _$EventToJson(_Event instance) => <String, dynamic>{
  'id': instance.id,
  'sectionId': instance.sectionId,
  'title': instance.title,
  'description': instance.description,
  'type': _$EventTypeEnumMap[instance.type]!,
  'status': _$EventStatusEnumMap[instance.status]!,
  'startDate': const TimestampConverter().toJson(instance.startDate),
  'endDate': const TimestampConverter().toJson(instance.endDate),
  'location': instance.location?.toJson(),
  'carpoolOption': instance.carpoolOption?.toJson(),
  'minParticipants': instance.minParticipants,
  'maxParticipants': instance.maxParticipants,
  'difficulty': _$DifficultyEnumMap[instance.difficulty]!,
  'requiresApproval': instance.requiresApproval,
  'requiredEquipment': instance.requiredEquipment,
  'prerequisites': instance.prerequisites,
  'creatorId': instance.creatorId,
  'tripLeaderIds': instance.tripLeaderIds,
  'createdAt': const TimestampConverter().toJson(instance.createdAt),
  'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
};

const _$EventTypeEnumMap = {
  EventType.rock: 'rock',
  EventType.trailRun: 'trailRun',
  EventType.hike: 'hike',
  EventType.climb: 'climb',
  EventType.alpineSki: 'alpineSki',
  EventType.skiMountaineering: 'skiMountaineering',
  EventType.snowshoe: 'snowshoe',
  EventType.social: 'social',
  EventType.presentation: 'presentation',
};

const _$EventStatusEnumMap = {
  EventStatus.draft: 'draft',
  EventStatus.published: 'published',
};

const _$DifficultyEnumMap = {
  Difficulty.easy: 'easy',
  Difficulty.moderate: 'moderate',
  Difficulty.hard: 'hard',
};

// **************************************************************************
// ModelBuilderGenerator
// **************************************************************************

Map<String, dynamic>? EventToJson(Event? instance) => instance == null
    ? null
    : {
        'id': instance.id,
        'sectionId': instance.sectionId,
        'title': instance.title,
        'description': instance.description,
        'type': _$EventEventTypeToJson(instance.type),
        'status': _$EventEventStatusToJson(instance.status),
        'startDate': instance.startDate == null
            ? null
            : const TimestampConverter().toJson(instance.startDate),
        'endDate': instance.endDate == null
            ? null
            : const TimestampConverter().toJson(instance.endDate),
        'location': EventLocationToJson(instance.location),
        'carpoolOption': CarpoolOptionToJson(instance.carpoolOption),
        'minParticipants': instance.minParticipants,
        'maxParticipants': instance.maxParticipants,
        'difficulty': _$EventDifficultyToJson(instance.difficulty),
        'requiresApproval': instance.requiresApproval,
        'requiredEquipment': instance.requiredEquipment,
        'prerequisites': instance.prerequisites,
        'creatorId': instance.creatorId,
        'tripLeaderIds': instance.tripLeaderIds,
        'createdAt': instance.createdAt == null
            ? null
            : const TimestampConverter().toJson(instance.createdAt),
        'updatedAt': instance.updatedAt == null
            ? null
            : const TimestampConverter().toJson(instance.updatedAt),
      };
Event EventFromJson(Map<String, dynamic> json) => Event(
  id: (json['id'] as String),
  sectionId: (json['sectionId'] as String),
  title: (json['title'] as String),
  description: json['description'] == null
      ? null
      : (json['description'] as String?),
  type: _$EventEventTypeFromJson(json['type']),
  status: _$EventEventStatusFromJson(json['status']),
  startDate: const TimestampConverter().fromJson(json['startDate']),
  endDate: const TimestampConverter().fromJson(json['endDate']),
  location: json['location'] == null
      ? null
      : EventLocation.fromJson((json['location'] as Map<String, dynamic>)),
  carpoolOption: json['carpoolOption'] == null
      ? null
      : CarpoolOption.fromJson((json['carpoolOption'] as Map<String, dynamic>)),
  minParticipants: (json['minParticipants'] as int),
  maxParticipants: (json['maxParticipants'] as int),
  difficulty: _$EventDifficultyFromJson(json['difficulty']),
  requiresApproval: (json['requiresApproval'] as bool),
  requiredEquipment: (json['requiredEquipment'] as List<dynamic>)
      .cast<String>(),
  prerequisites: (json['prerequisites'] as List<dynamic>).cast<String>(),
  creatorId: (json['creatorId'] as String),
  tripLeaderIds: (json['tripLeaderIds'] as List<dynamic>).cast<String>(),
  createdAt: const TimestampConverter().fromJson(json['createdAt']),
  updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
);
Object? _$EventEventTypeToJson(EventType? value) => value == null
    ? null
    : {
        EventType.rock: 'rock',
        EventType.trailRun: 'trailRun',
        EventType.hike: 'hike',
        EventType.climb: 'climb',
        EventType.alpineSki: 'alpineSki',
        EventType.skiMountaineering: 'skiMountaineering',
        EventType.snowshoe: 'snowshoe',
        EventType.social: 'social',
        EventType.presentation: 'presentation',
      }[value];
EventType _$EventEventTypeFromJson(Object? value) {
  return switch (value) {
    'rock' => EventType.rock,
    'trailRun' => EventType.trailRun,
    'hike' => EventType.hike,
    'climb' => EventType.climb,
    'alpineSki' => EventType.alpineSki,
    'skiMountaineering' => EventType.skiMountaineering,
    'snowshoe' => EventType.snowshoe,
    'social' => EventType.social,
    'presentation' => EventType.presentation,
    _ => throw ArgumentError("Unknown enum value for EventType"),
  };
}

Object? _$EventEventStatusToJson(EventStatus? value) => value == null
    ? null
    : {EventStatus.draft: 'draft', EventStatus.published: 'published'}[value];
EventStatus _$EventEventStatusFromJson(Object? value) {
  return switch (value) {
    'draft' => EventStatus.draft,
    'published' => EventStatus.published,
    _ => throw ArgumentError("Unknown enum value for EventStatus"),
  };
}

Object? _$EventDifficultyToJson(Difficulty? value) => value == null
    ? null
    : {
        Difficulty.easy: 'easy',
        Difficulty.moderate: 'moderate',
        Difficulty.hard: 'hard',
      }[value];
Difficulty _$EventDifficultyFromJson(Object? value) {
  return switch (value) {
    'easy' => Difficulty.easy,
    'moderate' => Difficulty.moderate,
    'hard' => Difficulty.hard,
    _ => throw ArgumentError("Unknown enum value for Difficulty"),
  };
}

class EventPatchBuilder extends PatchBuilder<Event> {
  /// Creates a patch builder for `Event`.
  EventPatchBuilder();

  /// Patch handle for `sectionId` (document field `sectionId`).
  late final FieldUpdate<String> sectionId = FieldUpdate(
    field: const FieldNode(components: ['sectionId']),
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

  /// Patch handle for `description` (document field `description`).
  late final FieldUpdate<String?> description = FieldUpdate(
    field: const FieldNode(components: ['description']),
    toJson: (value) {
      return value;
    },
  );

  /// Patch handle for `type` (document field `type`).
  late final FieldUpdate<EventType> type = FieldUpdate(
    field: const FieldNode(components: ['type']),
    toJson: (value) {
      return _$EventEventTypeToJson(value);
    },
  );

  /// Patch handle for `status` (document field `status`).
  late final FieldUpdate<EventStatus> status = FieldUpdate(
    field: const FieldNode(components: ['status']),
    toJson: (value) {
      return _$EventEventStatusToJson(value);
    },
  );

  /// Patch handle for `startDate` (document field `startDate`).
  late final DateTimeFieldUpdate startDate = DateTimeFieldUpdate(
    field: const FieldNode(components: ['startDate']),
    toJson: (value) {
      return value == null ? null : const TimestampConverter().toJson(value);
    },
  );

  /// Patch handle for `endDate` (document field `endDate`).
  late final DateTimeFieldUpdate endDate = DateTimeFieldUpdate(
    field: const FieldNode(components: ['endDate']),
    toJson: (value) {
      return value == null ? null : const TimestampConverter().toJson(value);
    },
  );

  /// Patch handle for `location` (document field `location`).
  late final FieldUpdate<EventLocation?> location = FieldUpdate(
    field: const FieldNode(components: ['location']),
    toJson: (value) {
      return EventLocationToJson(value);
    },
  );

  /// Patch handle for `carpoolOption` (document field `carpoolOption`).
  late final FieldUpdate<CarpoolOption?> carpoolOption = FieldUpdate(
    field: const FieldNode(components: ['carpoolOption']),
    toJson: (value) {
      return CarpoolOptionToJson(value);
    },
  );

  /// Patch handle for `minParticipants` (document field `minParticipants`).
  late final NumericFieldUpdate<int> minParticipants = NumericFieldUpdate(
    field: const FieldNode(components: ['minParticipants']),
    toJson: (value) {
      return value;
    },
  );

  /// Patch handle for `maxParticipants` (document field `maxParticipants`).
  late final NumericFieldUpdate<int> maxParticipants = NumericFieldUpdate(
    field: const FieldNode(components: ['maxParticipants']),
    toJson: (value) {
      return value;
    },
  );

  /// Patch handle for `difficulty` (document field `difficulty`).
  late final FieldUpdate<Difficulty> difficulty = FieldUpdate(
    field: const FieldNode(components: ['difficulty']),
    toJson: (value) {
      return _$EventDifficultyToJson(value);
    },
  );

  /// Patch handle for `requiresApproval` (document field `requiresApproval`).
  late final FieldUpdate<bool> requiresApproval = FieldUpdate(
    field: const FieldNode(components: ['requiresApproval']),
    toJson: (value) {
      return value;
    },
  );

  /// Patch handle for `requiredEquipment` (document field `requiredEquipment`).
  late final ListFieldUpdate<String> requiredEquipment = ListFieldUpdate(
    field: const FieldNode(components: ['requiredEquipment']),
    toJson: (value) {
      return value;
    },
    elementToJson: (value) {
      return value;
    },
  );

  /// Patch handle for `prerequisites` (document field `prerequisites`).
  late final ListFieldUpdate<String> prerequisites = ListFieldUpdate(
    field: const FieldNode(components: ['prerequisites']),
    toJson: (value) {
      return value;
    },
    elementToJson: (value) {
      return value;
    },
  );

  /// Patch handle for `creatorId` (document field `creatorId`).
  late final FieldUpdate<String> creatorId = FieldUpdate(
    field: const FieldNode(components: ['creatorId']),
    toJson: (value) {
      return value;
    },
  );

  /// Patch handle for `tripLeaderIds` (document field `tripLeaderIds`).
  late final ListFieldUpdate<String> tripLeaderIds = ListFieldUpdate(
    field: const FieldNode(components: ['tripLeaderIds']),
    toJson: (value) {
      return value;
    },
    elementToJson: (value) {
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

class EventFilterBuilder extends FilterBuilderRoot {
  EventFilterBuilder({super.field});

  /// Selector for `id`.
  late final FilterField<String, String> id = FilterField<String, String>(
    field: append('id'),
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

  /// Selector for `title`.
  late final FilterField<String, String> title = FilterField<String, String>(
    field: append('title'),
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

  /// Selector for `type`.
  late final FilterField<EventType, EventType> type =
      FilterField<EventType, EventType>(
        field: append('type'),
        toJson: (value) {
          return _$EventEventTypeToJson(value);
        },
      );

  /// Selector for `status`.
  late final FilterField<EventStatus, EventStatus> status =
      FilterField<EventStatus, EventStatus>(
        field: append('status'),
        toJson: (value) {
          return _$EventEventStatusToJson(value);
        },
      );

  /// Selector for `startDate`.
  late final FilterField<DateTime, DateTime> startDate =
      FilterField<DateTime, DateTime>(
        field: append('startDate'),
        toJson: (value) {
          return value == null
              ? null
              : const TimestampConverter().toJson(value);
        },
      );

  /// Selector for `endDate`.
  late final FilterField<DateTime, DateTime> endDate =
      FilterField<DateTime, DateTime>(
        field: append('endDate'),
        toJson: (value) {
          return value == null
              ? null
              : const TimestampConverter().toJson(value);
        },
      );

  /// Nested selector for `location`.
  late final EventLocationFilterBuilder location = EventLocationFilterBuilder(
    field: append('location'),
  );

  /// Nested selector for `carpoolOption`.
  late final CarpoolOptionFilterBuilder carpoolOption =
      CarpoolOptionFilterBuilder(field: append('carpoolOption'));

  /// Selector for `minParticipants`.
  late final FilterField<int, int> minParticipants = FilterField<int, int>(
    field: append('minParticipants'),
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `maxParticipants`.
  late final FilterField<int, int> maxParticipants = FilterField<int, int>(
    field: append('maxParticipants'),
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `difficulty`.
  late final FilterField<Difficulty, Difficulty> difficulty =
      FilterField<Difficulty, Difficulty>(
        field: append('difficulty'),
        toJson: (value) {
          return _$EventDifficultyToJson(value);
        },
      );

  /// Selector for `requiresApproval`.
  late final FilterField<bool, bool> requiresApproval = FilterField<bool, bool>(
    field: append('requiresApproval'),
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `requiredEquipment`.
  late final FilterField<List<String>, String> requiredEquipment =
      FilterField<List<String>, String>(
        field: append('requiredEquipment'),
        toJson: (value) {
          return value;
        },
        elementToJson: (value) {
          return value;
        },
      );

  /// Selector for `prerequisites`.
  late final FilterField<List<String>, String> prerequisites =
      FilterField<List<String>, String>(
        field: append('prerequisites'),
        toJson: (value) {
          return value;
        },
        elementToJson: (value) {
          return value;
        },
      );

  /// Selector for `creatorId`.
  late final FilterField<String, String> creatorId =
      FilterField<String, String>(
        field: append('creatorId'),
        toJson: (value) {
          return value;
        },
      );

  /// Selector for `tripLeaderIds`.
  late final FilterField<List<String>, String> tripLeaderIds =
      FilterField<List<String>, String>(
        field: append('tripLeaderIds'),
        toJson: (value) {
          return value;
        },
        elementToJson: (value) {
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

class EventOrderByBuilder extends OrderByBuilderRoot {
  EventOrderByBuilder({super.field, required OrderByContext context})
    : _context = context;

  final OrderByContext _context;

  /// Selector for `id`.
  late final OrderByField<String> id = OrderByField(
    field: append('id'),
    context: _context,
  );

  /// Selector for `sectionId`.
  late final OrderByField<String> sectionId = OrderByField(
    field: append('sectionId'),
    context: _context,
  );

  /// Selector for `title`.
  late final OrderByField<String> title = OrderByField(
    field: append('title'),
    context: _context,
  );

  /// Selector for `description`.
  late final OrderByField<String?> description = OrderByField(
    field: append('description'),
    context: _context,
  );

  /// Selector for `type`.
  late final OrderByField<EventType> type = OrderByField(
    field: append('type'),
    context: _context,
    defaultValue: EventType.values.first,
  );

  /// Selector for `status`.
  late final OrderByField<EventStatus> status = OrderByField(
    field: append('status'),
    context: _context,
    defaultValue: EventStatus.values.first,
  );

  /// Selector for `startDate`.
  late final OrderByField<DateTime> startDate = OrderByField(
    field: append('startDate'),
    context: _context,
  );

  /// Selector for `endDate`.
  late final OrderByField<DateTime> endDate = OrderByField(
    field: append('endDate'),
    context: _context,
  );

  /// Nested selector for `location`.
  late final EventLocationOrderByBuilder location = EventLocationOrderByBuilder(
    field: append('location'),
    context: _context,
  );

  /// Nested selector for `carpoolOption`.
  late final CarpoolOptionOrderByBuilder carpoolOption =
      CarpoolOptionOrderByBuilder(
        field: append('carpoolOption'),
        context: _context,
      );

  /// Selector for `minParticipants`.
  late final OrderByField<int> minParticipants = OrderByField(
    field: append('minParticipants'),
    context: _context,
  );

  /// Selector for `maxParticipants`.
  late final OrderByField<int> maxParticipants = OrderByField(
    field: append('maxParticipants'),
    context: _context,
  );

  /// Selector for `difficulty`.
  late final OrderByField<Difficulty> difficulty = OrderByField(
    field: append('difficulty'),
    context: _context,
    defaultValue: Difficulty.values.first,
  );

  /// Selector for `requiresApproval`.
  late final OrderByField<bool> requiresApproval = OrderByField(
    field: append('requiresApproval'),
    context: _context,
  );

  /// Selector for `requiredEquipment`.
  late final OrderByField<List<String>> requiredEquipment = OrderByField(
    field: append('requiredEquipment'),
    context: _context,
  );

  /// Selector for `prerequisites`.
  late final OrderByField<List<String>> prerequisites = OrderByField(
    field: append('prerequisites'),
    context: _context,
  );

  /// Selector for `creatorId`.
  late final OrderByField<String> creatorId = OrderByField(
    field: append('creatorId'),
    context: _context,
  );

  /// Selector for `tripLeaderIds`.
  late final OrderByField<List<String>> tripLeaderIds = OrderByField(
    field: append('tripLeaderIds'),
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

class EventAggregateBuilder extends AggregateBuilderRoot {
  EventAggregateBuilder({super.field, required AggregateContext context})
    : _context = context;

  final AggregateContext _context;

  /// Nested selector for `location`.
  late final EventLocationAggregateBuilder location =
      EventLocationAggregateBuilder(
        field: append('location'),
        context: _context,
      );

  /// Nested selector for `carpoolOption`.
  late final CarpoolOptionAggregateBuilder carpoolOption =
      CarpoolOptionAggregateBuilder(
        field: append('carpoolOption'),
        context: _context,
      );

  /// Selector for `minParticipants`.
  late final AggregateField<int> minParticipants = AggregateField(
    field: append('minParticipants'),
    context: _context,
  );

  /// Selector for `maxParticipants`.
  late final AggregateField<int> maxParticipants = AggregateField(
    field: append('maxParticipants'),
    context: _context,
  );

  @override
  int count() => _context.resolve(const CountOperation('count'));
}

class EventPipelineSelector extends PipelineFieldNode {
  EventPipelineSelector({super.components, super.context});

  /// Selector for `id`.
  late final PipelineField<String> id = PipelineField(
    components: [...components, 'id'],
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

  /// Selector for `title`.
  late final PipelineField<String> title = PipelineField(
    components: [...components, 'title'],
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

  /// Selector for `type`.
  late final PipelineField<EventType> type = PipelineField(
    components: [...components, 'type'],
    context: $ctx,
    toJson: (value) {
      return _$EventEventTypeToJson(value);
    },
  );

  /// Selector for `status`.
  late final PipelineField<EventStatus> status = PipelineField(
    components: [...components, 'status'],
    context: $ctx,
    toJson: (value) {
      return _$EventEventStatusToJson(value);
    },
  );

  /// Selector for `startDate`.
  late final PipelineField<DateTime> startDate = PipelineField(
    components: [...components, 'startDate'],
    context: $ctx,
    toJson: (value) {
      return value == null ? null : const TimestampConverter().toJson(value);
    },
  );

  /// Selector for `endDate`.
  late final PipelineField<DateTime> endDate = PipelineField(
    components: [...components, 'endDate'],
    context: $ctx,
    toJson: (value) {
      return value == null ? null : const TimestampConverter().toJson(value);
    },
  );

  /// Nested selector for `location`.
  late final EventLocationPipelineSelector location =
      EventLocationPipelineSelector(
        components: [...components, 'location'],
        context: $ctx,
      );

  /// Nested selector for `carpoolOption`.
  late final CarpoolOptionPipelineSelector carpoolOption =
      CarpoolOptionPipelineSelector(
        components: [...components, 'carpoolOption'],
        context: $ctx,
      );

  /// Selector for `minParticipants`.
  late final PipelineField<int> minParticipants = PipelineField(
    components: [...components, 'minParticipants'],
    context: $ctx,
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `maxParticipants`.
  late final PipelineField<int> maxParticipants = PipelineField(
    components: [...components, 'maxParticipants'],
    context: $ctx,
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `difficulty`.
  late final PipelineField<Difficulty> difficulty = PipelineField(
    components: [...components, 'difficulty'],
    context: $ctx,
    toJson: (value) {
      return _$EventDifficultyToJson(value);
    },
  );

  /// Selector for `requiresApproval`.
  late final PipelineField<bool> requiresApproval = PipelineField(
    components: [...components, 'requiresApproval'],
    context: $ctx,
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `requiredEquipment`.
  late final PipelineField<List<String>> requiredEquipment = PipelineField(
    components: [...components, 'requiredEquipment'],
    context: $ctx,
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `prerequisites`.
  late final PipelineField<List<String>> prerequisites = PipelineField(
    components: [...components, 'prerequisites'],
    context: $ctx,
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `creatorId`.
  late final PipelineField<String> creatorId = PipelineField(
    components: [...components, 'creatorId'],
    context: $ctx,
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `tripLeaderIds`.
  late final PipelineField<List<String>> tripLeaderIds = PipelineField(
    components: [...components, 'tripLeaderIds'],
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

extension EventPipelineExtension<S extends FirestoreSchema>
    on
        FirestoreCollection<
          S,
          Event,
          EventPatchBuilder,
          EventFilterBuilder,
          EventOrderByBuilder,
          EventAggregateBuilder
        > {
  TypedPipeline<Event, EventPipelineSelector> pipeline() => TypedPipeline(
    ref.firestore.pipeline().collection(ref.path),
    EventFromJson,
    'id',
    (context) => EventPipelineSelector(context: context),
  );
}
