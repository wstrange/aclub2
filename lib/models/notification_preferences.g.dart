// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_preferences.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NotificationPreferences _$NotificationPreferencesFromJson(
  Map<String, dynamic> json,
) => _NotificationPreferences(
  pushEnabled: json['pushEnabled'] as bool? ?? true,
  emailEnabled: json['emailEnabled'] as bool? ?? true,
  inAppEnabled: json['inAppEnabled'] as bool? ?? true,
  frequency:
      $enumDecodeNullable(_$NotificationFrequencyEnumMap, json['frequency']) ??
      NotificationFrequency.immediate,
);

Map<String, dynamic> _$NotificationPreferencesToJson(
  _NotificationPreferences instance,
) => <String, dynamic>{
  'pushEnabled': instance.pushEnabled,
  'emailEnabled': instance.emailEnabled,
  'inAppEnabled': instance.inAppEnabled,
  'frequency': _$NotificationFrequencyEnumMap[instance.frequency]!,
};

const _$NotificationFrequencyEnumMap = {
  NotificationFrequency.immediate: 'immediate',
  NotificationFrequency.daily: 'daily',
  NotificationFrequency.weekly: 'weekly',
};

// **************************************************************************
// ModelBuilderGenerator
// **************************************************************************

Map<String, dynamic>? NotificationPreferencesToJson(
  NotificationPreferences? instance,
) => instance == null
    ? null
    : {
        'pushEnabled': instance.pushEnabled,
        'emailEnabled': instance.emailEnabled,
        'inAppEnabled': instance.inAppEnabled,
        'frequency': _$NotificationPreferencesNotificationFrequencyToJson(
          instance.frequency,
        ),
      };
NotificationPreferences NotificationPreferencesFromJson(
  Map<String, dynamic> json,
) => NotificationPreferences(
  pushEnabled: (json['pushEnabled'] as bool),
  emailEnabled: (json['emailEnabled'] as bool),
  inAppEnabled: (json['inAppEnabled'] as bool),
  frequency: _$NotificationPreferencesNotificationFrequencyFromJson(
    json['frequency'],
  ),
);
Object? _$NotificationPreferencesNotificationFrequencyToJson(
  NotificationFrequency? value,
) => value == null
    ? null
    : {
        NotificationFrequency.immediate: 'immediate',
        NotificationFrequency.daily: 'daily',
        NotificationFrequency.weekly: 'weekly',
      }[value];
NotificationFrequency _$NotificationPreferencesNotificationFrequencyFromJson(
  Object? value,
) {
  return switch (value) {
    'immediate' => NotificationFrequency.immediate,
    'daily' => NotificationFrequency.daily,
    'weekly' => NotificationFrequency.weekly,
    _ => throw ArgumentError("Unknown enum value for NotificationFrequency"),
  };
}

class NotificationPreferencesPatchBuilder
    extends PatchBuilder<NotificationPreferences> {
  /// Creates a patch builder for `NotificationPreferences`.
  NotificationPreferencesPatchBuilder();

  /// Patch handle for `pushEnabled` (document field `pushEnabled`).
  late final FieldUpdate<bool> pushEnabled = FieldUpdate(
    field: const FieldNode(components: ['pushEnabled']),
    toJson: (value) {
      return value;
    },
  );

  /// Patch handle for `emailEnabled` (document field `emailEnabled`).
  late final FieldUpdate<bool> emailEnabled = FieldUpdate(
    field: const FieldNode(components: ['emailEnabled']),
    toJson: (value) {
      return value;
    },
  );

  /// Patch handle for `inAppEnabled` (document field `inAppEnabled`).
  late final FieldUpdate<bool> inAppEnabled = FieldUpdate(
    field: const FieldNode(components: ['inAppEnabled']),
    toJson: (value) {
      return value;
    },
  );

  /// Patch handle for `frequency` (document field `frequency`).
  late final FieldUpdate<NotificationFrequency> frequency = FieldUpdate(
    field: const FieldNode(components: ['frequency']),
    toJson: (value) {
      return _$NotificationPreferencesNotificationFrequencyToJson(value);
    },
  );
}

class NotificationPreferencesFilterBuilder extends FilterBuilderRoot {
  NotificationPreferencesFilterBuilder({super.field});

  /// Selector for `pushEnabled`.
  late final FilterField<bool, bool> pushEnabled = FilterField<bool, bool>(
    field: append('pushEnabled'),
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `emailEnabled`.
  late final FilterField<bool, bool> emailEnabled = FilterField<bool, bool>(
    field: append('emailEnabled'),
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `inAppEnabled`.
  late final FilterField<bool, bool> inAppEnabled = FilterField<bool, bool>(
    field: append('inAppEnabled'),
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `frequency`.
  late final FilterField<NotificationFrequency, NotificationFrequency>
  frequency = FilterField<NotificationFrequency, NotificationFrequency>(
    field: append('frequency'),
    toJson: (value) {
      return _$NotificationPreferencesNotificationFrequencyToJson(value);
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

class NotificationPreferencesOrderByBuilder extends OrderByBuilderRoot {
  NotificationPreferencesOrderByBuilder({
    super.field,
    required OrderByContext context,
  }) : _context = context;

  final OrderByContext _context;

  /// Selector for `pushEnabled`.
  late final OrderByField<bool> pushEnabled = OrderByField(
    field: append('pushEnabled'),
    context: _context,
  );

  /// Selector for `emailEnabled`.
  late final OrderByField<bool> emailEnabled = OrderByField(
    field: append('emailEnabled'),
    context: _context,
  );

  /// Selector for `inAppEnabled`.
  late final OrderByField<bool> inAppEnabled = OrderByField(
    field: append('inAppEnabled'),
    context: _context,
  );

  /// Selector for `frequency`.
  late final OrderByField<NotificationFrequency> frequency = OrderByField(
    field: append('frequency'),
    context: _context,
    defaultValue: NotificationFrequency.values.first,
  );

  /// The document ID pseudo-field.
  late final OrderByField<String> documentId = OrderByField(
    field: const DocumentIdNode(),
    context: _context,
  );
}

class NotificationPreferencesAggregateBuilder extends AggregateBuilderRoot {
  NotificationPreferencesAggregateBuilder({
    super.field,
    required AggregateContext context,
  }) : _context = context;

  final AggregateContext _context;

  @override
  int count() => _context.resolve(const CountOperation('count'));
}

class NotificationPreferencesPipelineSelector extends PipelineFieldNode {
  NotificationPreferencesPipelineSelector({super.components, super.context});

  /// Selector for `pushEnabled`.
  late final PipelineField<bool> pushEnabled = PipelineField(
    components: [...components, 'pushEnabled'],
    context: $ctx,
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `emailEnabled`.
  late final PipelineField<bool> emailEnabled = PipelineField(
    components: [...components, 'emailEnabled'],
    context: $ctx,
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `inAppEnabled`.
  late final PipelineField<bool> inAppEnabled = PipelineField(
    components: [...components, 'inAppEnabled'],
    context: $ctx,
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `frequency`.
  late final PipelineField<NotificationFrequency> frequency = PipelineField(
    components: [...components, 'frequency'],
    context: $ctx,
    toJson: (value) {
      return _$NotificationPreferencesNotificationFrequencyToJson(value);
    },
  );
}

extension NotificationPreferencesPipelineExtension<S extends FirestoreSchema>
    on
        FirestoreCollection<
          S,
          NotificationPreferences,
          NotificationPreferencesPatchBuilder,
          NotificationPreferencesFilterBuilder,
          NotificationPreferencesOrderByBuilder,
          NotificationPreferencesAggregateBuilder
        > {
  TypedPipeline<
    NotificationPreferences,
    NotificationPreferencesPipelineSelector
  >
  pipeline() => TypedPipeline(
    ref.firestore.pipeline().collection(ref.path),
    NotificationPreferencesFromJson,
    null,
    (context) => NotificationPreferencesPipelineSelector(context: context),
  );
}
