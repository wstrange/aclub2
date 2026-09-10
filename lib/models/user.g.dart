// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_User _$UserFromJson(Map<String, dynamic> json) => _User(
  id: json['id'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  age: (json['age'] as num).toInt(),
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  scores:
      (json['scores'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const [],
  settings:
      (json['settings'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const {},
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
  rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
  isActive: json['isActive'] as bool? ?? false,
  isPremium: json['isPremium'] as bool? ?? false,
  lastLogin: json['lastLogin'] == null
      ? null
      : DateTime.parse(json['lastLogin'] as String),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$UserToJson(_User instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'age': instance.age,
  'tags': instance.tags,
  'scores': instance.scores,
  'settings': instance.settings,
  'metadata': instance.metadata,
  'rating': instance.rating,
  'isActive': instance.isActive,
  'isPremium': instance.isPremium,
  'lastLogin': instance.lastLogin?.toIso8601String(),
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

// **************************************************************************
// ModelBuilderGenerator
// **************************************************************************

Map<String, dynamic>? UserToJson(User? instance) => instance == null
    ? null
    : {
        'id': instance.id,
        'name': instance.name,
        'email': instance.email,
        'age': instance.age,
        'tags': instance.tags,
        'scores': instance.scores,
        'settings': instance.settings,
        'metadata': instance.metadata,
        'rating': instance.rating,
        'isActive': instance.isActive,
        'isPremium': instance.isPremium,
        'lastLogin': instance.lastLogin,
        'createdAt': instance.createdAt,
        'updatedAt': instance.updatedAt,
      };
User UserFromJson(Map<String, dynamic> json) => User(
  id: (json['id'] as String),
  name: (json['name'] as String),
  email: (json['email'] as String),
  age: (json['age'] as int),
  tags: (json['tags'] as List<dynamic>).cast<String>(),
  scores: (json['scores'] as List<dynamic>).cast<int>(),
  settings: (json['settings'] as Map<String, dynamic>).cast<String, String>(),
  metadata: (json['metadata'] as Map<String, dynamic>).cast<String, dynamic>(),
  rating: (json['rating'] as double),
  isActive: (json['isActive'] as bool),
  isPremium: (json['isPremium'] as bool),
  lastLogin: json['lastLogin'] == null
      ? null
      : dateTimeFromJson(json['lastLogin']),
  createdAt: json['createdAt'] == null
      ? null
      : dateTimeFromJson(json['createdAt']),
  updatedAt: json['updatedAt'] == null
      ? null
      : dateTimeFromJson(json['updatedAt']),
);

class UserPatchBuilder extends PatchBuilder<User> {
  /// Creates a patch builder for `User`.
  UserPatchBuilder();

  /// Patch handle for `name` (document field `name`).
  late final FieldUpdate<String> name = FieldUpdate(
    field: const FieldNode(components: ['name']),
    toJson: (value) {
      return value;
    },
  );

  /// Patch handle for `email` (document field `email`).
  late final FieldUpdate<String> email = FieldUpdate(
    field: const FieldNode(components: ['email']),
    toJson: (value) {
      return value;
    },
  );

  /// Patch handle for `age` (document field `age`).
  late final NumericFieldUpdate<int> age = NumericFieldUpdate(
    field: const FieldNode(components: ['age']),
    toJson: (value) {
      return value;
    },
  );

  /// Patch handle for `tags` (document field `tags`).
  late final ListFieldUpdate<String> tags = ListFieldUpdate(
    field: const FieldNode(components: ['tags']),
    toJson: (value) {
      return value;
    },
    elementToJson: (value) {
      return value;
    },
  );

  /// Patch handle for `scores` (document field `scores`).
  late final ListFieldUpdate<int> scores = ListFieldUpdate(
    field: const FieldNode(components: ['scores']),
    toJson: (value) {
      return value;
    },
    elementToJson: (value) {
      return value;
    },
  );

  /// Patch handle for `settings` (document field `settings`).
  late final FieldUpdate<Map<String, String>> settings = FieldUpdate(
    field: const FieldNode(components: ['settings']),
    toJson: (value) {
      return value;
    },
  );

  /// Patch handle for `metadata` (document field `metadata`).
  late final FieldUpdate<Map<String, dynamic>> metadata = FieldUpdate(
    field: const FieldNode(components: ['metadata']),
    toJson: (value) {
      return value;
    },
  );

  /// Patch handle for `rating` (document field `rating`).
  late final NumericFieldUpdate<double> rating = NumericFieldUpdate(
    field: const FieldNode(components: ['rating']),
    toJson: (value) {
      return value;
    },
  );

  /// Patch handle for `isActive` (document field `isActive`).
  late final FieldUpdate<bool> isActive = FieldUpdate(
    field: const FieldNode(components: ['isActive']),
    toJson: (value) {
      return value;
    },
  );

  /// Patch handle for `isPremium` (document field `isPremium`).
  late final FieldUpdate<bool> isPremium = FieldUpdate(
    field: const FieldNode(components: ['isPremium']),
    toJson: (value) {
      return value;
    },
  );

  /// Patch handle for `lastLogin` (document field `lastLogin`).
  late final DateTimeFieldUpdate lastLogin = DateTimeFieldUpdate(
    field: const FieldNode(components: ['lastLogin']),
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

class UserFilterBuilder extends FilterBuilderRoot {
  UserFilterBuilder({super.field});

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

  /// Selector for `email`.
  late final FilterField<String, String> email = FilterField<String, String>(
    field: append('email'),
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `age`.
  late final FilterField<int, int> age = FilterField<int, int>(
    field: append('age'),
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `tags`.
  late final FilterField<List<String>, String> tags =
      FilterField<List<String>, String>(
        field: append('tags'),
        toJson: (value) {
          return value;
        },
        elementToJson: (value) {
          return value;
        },
      );

  /// Selector for `scores`.
  late final FilterField<List<int>, int> scores = FilterField<List<int>, int>(
    field: append('scores'),
    toJson: (value) {
      return value;
    },
    elementToJson: (value) {
      return value;
    },
  );

  /// Selector for `settings`.
  late final FilterField<Map<String, String>, Map<String, String>> settings =
      FilterField<Map<String, String>, Map<String, String>>(
        field: append('settings'),
        toJson: (value) {
          return value;
        },
      );

  /// Selector for `metadata`.
  late final FilterField<Map<String, dynamic>, Map<String, dynamic>> metadata =
      FilterField<Map<String, dynamic>, Map<String, dynamic>>(
        field: append('metadata'),
        toJson: (value) {
          return value;
        },
      );

  /// Selector for `rating`.
  late final FilterField<double, double> rating = FilterField<double, double>(
    field: append('rating'),
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `isActive`.
  late final FilterField<bool, bool> isActive = FilterField<bool, bool>(
    field: append('isActive'),
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `isPremium`.
  late final FilterField<bool, bool> isPremium = FilterField<bool, bool>(
    field: append('isPremium'),
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `lastLogin`.
  late final FilterField<DateTime?, DateTime?> lastLogin =
      FilterField<DateTime?, DateTime?>(
        field: append('lastLogin'),
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

class UserOrderByBuilder extends OrderByBuilderRoot {
  UserOrderByBuilder({super.field, required OrderByContext context})
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

  /// Selector for `email`.
  late final OrderByField<String> email = OrderByField(
    field: append('email'),
    context: _context,
  );

  /// Selector for `age`.
  late final OrderByField<int> age = OrderByField(
    field: append('age'),
    context: _context,
  );

  /// Selector for `tags`.
  late final OrderByField<List<String>> tags = OrderByField(
    field: append('tags'),
    context: _context,
  );

  /// Selector for `scores`.
  late final OrderByField<List<int>> scores = OrderByField(
    field: append('scores'),
    context: _context,
  );

  /// Selector for `settings`.
  late final OrderByField<Map<String, String>> settings = OrderByField(
    field: append('settings'),
    context: _context,
  );

  /// Selector for `metadata`.
  late final OrderByField<Map<String, dynamic>> metadata = OrderByField(
    field: append('metadata'),
    context: _context,
  );

  /// Selector for `rating`.
  late final OrderByField<double> rating = OrderByField(
    field: append('rating'),
    context: _context,
  );

  /// Selector for `isActive`.
  late final OrderByField<bool> isActive = OrderByField(
    field: append('isActive'),
    context: _context,
  );

  /// Selector for `isPremium`.
  late final OrderByField<bool> isPremium = OrderByField(
    field: append('isPremium'),
    context: _context,
  );

  /// Selector for `lastLogin`.
  late final OrderByField<DateTime?> lastLogin = OrderByField(
    field: append('lastLogin'),
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

class UserAggregateBuilder extends AggregateBuilderRoot {
  UserAggregateBuilder({super.field, required AggregateContext context})
    : _context = context;

  final AggregateContext _context;

  /// Selector for `age`.
  late final AggregateField<int> age = AggregateField(
    field: append('age'),
    context: _context,
  );

  /// Selector for `rating`.
  late final AggregateField<double> rating = AggregateField(
    field: append('rating'),
    context: _context,
  );

  @override
  int count() => _context.resolve(const CountOperation('count'));
}

class UserPipelineSelector extends PipelineFieldNode {
  UserPipelineSelector({super.components, super.context});

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

  /// Selector for `email`.
  late final PipelineField<String> email = PipelineField(
    components: [...components, 'email'],
    context: $ctx,
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `age`.
  late final PipelineField<int> age = PipelineField(
    components: [...components, 'age'],
    context: $ctx,
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `tags`.
  late final PipelineField<List<String>> tags = PipelineField(
    components: [...components, 'tags'],
    context: $ctx,
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `scores`.
  late final PipelineField<List<int>> scores = PipelineField(
    components: [...components, 'scores'],
    context: $ctx,
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `settings`.
  late final PipelineField<Map<String, String>> settings = PipelineField(
    components: [...components, 'settings'],
    context: $ctx,
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `metadata`.
  late final PipelineField<Map<String, dynamic>> metadata = PipelineField(
    components: [...components, 'metadata'],
    context: $ctx,
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `rating`.
  late final PipelineField<double> rating = PipelineField(
    components: [...components, 'rating'],
    context: $ctx,
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `isActive`.
  late final PipelineField<bool> isActive = PipelineField(
    components: [...components, 'isActive'],
    context: $ctx,
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `isPremium`.
  late final PipelineField<bool> isPremium = PipelineField(
    components: [...components, 'isPremium'],
    context: $ctx,
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `lastLogin`.
  late final PipelineField<DateTime?> lastLogin = PipelineField(
    components: [...components, 'lastLogin'],
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

extension UserPipelineExtension<S extends FirestoreSchema>
    on
        FirestoreCollection<
          S,
          User,
          UserPatchBuilder,
          UserFilterBuilder,
          UserOrderByBuilder,
          UserAggregateBuilder
        > {
  TypedPipeline<User, UserPipelineSelector> pipeline() => TypedPipeline(
    ref.firestore.pipeline().collection(ref.path),
    UserFromJson,
    'id',
    (context) => UserPipelineSelector(context: context),
  );
}
