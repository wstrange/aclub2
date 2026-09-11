// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NotificationModel _$NotificationModelFromJson(
  Map<String, dynamic> json,
) => _NotificationModel(
  id: json['id'] as String,
  recipientId: json['recipientId'] as String,
  title: json['title'] as String,
  message: json['message'] as String,
  link: json['link'] as String?,
  channels:
      (json['channels'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  isRead: json['isRead'] as bool? ?? false,
  relatedEventId: json['relatedEventId'] as String?,
  relatedSectionId: json['relatedSectionId'] as String?,
  createdAt: const TimestampConverter().fromJson(json['createdAt'] as Object),
);

Map<String, dynamic> _$NotificationModelToJson(_NotificationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'recipientId': instance.recipientId,
      'title': instance.title,
      'message': instance.message,
      'link': instance.link,
      'channels': instance.channels,
      'isRead': instance.isRead,
      'relatedEventId': instance.relatedEventId,
      'relatedSectionId': instance.relatedSectionId,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
    };

// **************************************************************************
// ModelBuilderGenerator
// **************************************************************************

Map<String, dynamic>? NotificationModelToJson(NotificationModel? instance) =>
    instance == null
    ? null
    : {
        'id': instance.id,
        'recipientId': instance.recipientId,
        'title': instance.title,
        'message': instance.message,
        'link': instance.link,
        'channels': instance.channels,
        'isRead': instance.isRead,
        'relatedEventId': instance.relatedEventId,
        'relatedSectionId': instance.relatedSectionId,
        'createdAt': instance.createdAt == null
            ? null
            : const TimestampConverter().toJson(instance.createdAt),
      };
NotificationModel NotificationModelFromJson(Map<String, dynamic> json) =>
    NotificationModel(
      id: (json['id'] as String),
      recipientId: (json['recipientId'] as String),
      title: (json['title'] as String),
      message: (json['message'] as String),
      link: json['link'] == null ? null : (json['link'] as String?),
      channels: (json['channels'] as List<dynamic>).cast<String>(),
      isRead: (json['isRead'] as bool),
      relatedEventId: json['relatedEventId'] == null
          ? null
          : (json['relatedEventId'] as String?),
      relatedSectionId: json['relatedSectionId'] == null
          ? null
          : (json['relatedSectionId'] as String?),
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
    );

class NotificationModelPatchBuilder extends PatchBuilder<NotificationModel> {
  /// Creates a patch builder for `NotificationModel`.
  NotificationModelPatchBuilder();

  /// Patch handle for `recipientId` (document field `recipientId`).
  late final FieldUpdate<String> recipientId = FieldUpdate(
    field: const FieldNode(components: ['recipientId']),
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

  /// Patch handle for `message` (document field `message`).
  late final FieldUpdate<String> message = FieldUpdate(
    field: const FieldNode(components: ['message']),
    toJson: (value) {
      return value;
    },
  );

  /// Patch handle for `link` (document field `link`).
  late final FieldUpdate<String?> link = FieldUpdate(
    field: const FieldNode(components: ['link']),
    toJson: (value) {
      return value;
    },
  );

  /// Patch handle for `channels` (document field `channels`).
  late final ListFieldUpdate<String> channels = ListFieldUpdate(
    field: const FieldNode(components: ['channels']),
    toJson: (value) {
      return value;
    },
    elementToJson: (value) {
      return value;
    },
  );

  /// Patch handle for `isRead` (document field `isRead`).
  late final FieldUpdate<bool> isRead = FieldUpdate(
    field: const FieldNode(components: ['isRead']),
    toJson: (value) {
      return value;
    },
  );

  /// Patch handle for `relatedEventId` (document field `relatedEventId`).
  late final FieldUpdate<String?> relatedEventId = FieldUpdate(
    field: const FieldNode(components: ['relatedEventId']),
    toJson: (value) {
      return value;
    },
  );

  /// Patch handle for `relatedSectionId` (document field `relatedSectionId`).
  late final FieldUpdate<String?> relatedSectionId = FieldUpdate(
    field: const FieldNode(components: ['relatedSectionId']),
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
}

class NotificationModelFilterBuilder extends FilterBuilderRoot {
  NotificationModelFilterBuilder({super.field});

  /// Selector for `id`.
  late final FilterField<String, String> id = FilterField<String, String>(
    field: append('id'),
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `recipientId`.
  late final FilterField<String, String> recipientId =
      FilterField<String, String>(
        field: append('recipientId'),
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

  /// Selector for `message`.
  late final FilterField<String, String> message = FilterField<String, String>(
    field: append('message'),
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `link`.
  late final FilterField<String?, String?> link = FilterField<String?, String?>(
    field: append('link'),
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `channels`.
  late final FilterField<List<String>, String> channels =
      FilterField<List<String>, String>(
        field: append('channels'),
        toJson: (value) {
          return value;
        },
        elementToJson: (value) {
          return value;
        },
      );

  /// Selector for `isRead`.
  late final FilterField<bool, bool> isRead = FilterField<bool, bool>(
    field: append('isRead'),
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `relatedEventId`.
  late final FilterField<String?, String?> relatedEventId =
      FilterField<String?, String?>(
        field: append('relatedEventId'),
        toJson: (value) {
          return value;
        },
      );

  /// Selector for `relatedSectionId`.
  late final FilterField<String?, String?> relatedSectionId =
      FilterField<String?, String?>(
        field: append('relatedSectionId'),
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

  /// The document ID pseudo-field.
  late final FilterField<String, String> documentId =
      FilterField<String, String>(
        field: const DocumentIdNode(),
        toJson: (value) {
          return value;
        },
      );
}

class NotificationModelOrderByBuilder extends OrderByBuilderRoot {
  NotificationModelOrderByBuilder({
    super.field,
    required OrderByContext context,
  }) : _context = context;

  final OrderByContext _context;

  /// Selector for `id`.
  late final OrderByField<String> id = OrderByField(
    field: append('id'),
    context: _context,
  );

  /// Selector for `recipientId`.
  late final OrderByField<String> recipientId = OrderByField(
    field: append('recipientId'),
    context: _context,
  );

  /// Selector for `title`.
  late final OrderByField<String> title = OrderByField(
    field: append('title'),
    context: _context,
  );

  /// Selector for `message`.
  late final OrderByField<String> message = OrderByField(
    field: append('message'),
    context: _context,
  );

  /// Selector for `link`.
  late final OrderByField<String?> link = OrderByField(
    field: append('link'),
    context: _context,
  );

  /// Selector for `channels`.
  late final OrderByField<List<String>> channels = OrderByField(
    field: append('channels'),
    context: _context,
  );

  /// Selector for `isRead`.
  late final OrderByField<bool> isRead = OrderByField(
    field: append('isRead'),
    context: _context,
  );

  /// Selector for `relatedEventId`.
  late final OrderByField<String?> relatedEventId = OrderByField(
    field: append('relatedEventId'),
    context: _context,
  );

  /// Selector for `relatedSectionId`.
  late final OrderByField<String?> relatedSectionId = OrderByField(
    field: append('relatedSectionId'),
    context: _context,
  );

  /// Selector for `createdAt`.
  late final OrderByField<DateTime> createdAt = OrderByField(
    field: append('createdAt'),
    context: _context,
  );

  /// The document ID pseudo-field.
  late final OrderByField<String> documentId = OrderByField(
    field: const DocumentIdNode(),
    context: _context,
  );
}

class NotificationModelAggregateBuilder extends AggregateBuilderRoot {
  NotificationModelAggregateBuilder({
    super.field,
    required AggregateContext context,
  }) : _context = context;

  final AggregateContext _context;

  @override
  int count() => _context.resolve(const CountOperation('count'));
}

class NotificationModelPipelineSelector extends PipelineFieldNode {
  NotificationModelPipelineSelector({super.components, super.context});

  /// Selector for `id`.
  late final PipelineField<String> id = PipelineField(
    components: [...components, 'id'],
    context: $ctx,
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `recipientId`.
  late final PipelineField<String> recipientId = PipelineField(
    components: [...components, 'recipientId'],
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

  /// Selector for `message`.
  late final PipelineField<String> message = PipelineField(
    components: [...components, 'message'],
    context: $ctx,
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `link`.
  late final PipelineField<String?> link = PipelineField(
    components: [...components, 'link'],
    context: $ctx,
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `channels`.
  late final PipelineField<List<String>> channels = PipelineField(
    components: [...components, 'channels'],
    context: $ctx,
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `isRead`.
  late final PipelineField<bool> isRead = PipelineField(
    components: [...components, 'isRead'],
    context: $ctx,
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `relatedEventId`.
  late final PipelineField<String?> relatedEventId = PipelineField(
    components: [...components, 'relatedEventId'],
    context: $ctx,
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `relatedSectionId`.
  late final PipelineField<String?> relatedSectionId = PipelineField(
    components: [...components, 'relatedSectionId'],
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
}

extension NotificationModelPipelineExtension<S extends FirestoreSchema>
    on
        FirestoreCollection<
          S,
          NotificationModel,
          NotificationModelPatchBuilder,
          NotificationModelFilterBuilder,
          NotificationModelOrderByBuilder,
          NotificationModelAggregateBuilder
        > {
  TypedPipeline<NotificationModel, NotificationModelPipelineSelector>
  pipeline() => TypedPipeline(
    ref.firestore.pipeline().collection(ref.path),
    NotificationModelFromJson,
    'id',
    (context) => NotificationModelPipelineSelector(context: context),
  );
}
