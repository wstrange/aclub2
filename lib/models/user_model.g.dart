// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserModel _$UserModelFromJson(Map<String, dynamic> json) => _UserModel(
  id: json['id'] as String,
  displayName: json['displayName'] as String,
  email: json['email'] as String,
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  photoUrl: json['photoUrl'] as String?,
  phone: json['phone'] as String?,
  emergencyContactName: json['emergencyContactName'] as String,
  emergencyContactPhone: json['emergencyContactPhone'] as String,
  emergencyContactRelation: json['emergencyContactRelation'] as String?,
  medicalConditions: json['medicalConditions'] as String?,
  certifications:
      (json['certifications'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  sectionIds:
      (json['sectionIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  isAdmin: json['isAdmin'] as bool? ?? false,
  notificationPreferences: NotificationPreferences.fromJson(
    json['notificationPreferences'] as Map<String, dynamic>,
  ),
  createdAt: const TimestampConverter().fromJson(
    json['createdAt'] as Timestamp,
  ),
  updatedAt: const TimestampConverter().fromJson(
    json['updatedAt'] as Timestamp,
  ),
);

Map<String, dynamic> _$UserModelToJson(_UserModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'displayName': instance.displayName,
      'email': instance.email,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'photoUrl': instance.photoUrl,
      'phone': instance.phone,
      'emergencyContactName': instance.emergencyContactName,
      'emergencyContactPhone': instance.emergencyContactPhone,
      'emergencyContactRelation': instance.emergencyContactRelation,
      'medicalConditions': instance.medicalConditions,
      'certifications': instance.certifications,
      'sectionIds': instance.sectionIds,
      'isAdmin': instance.isAdmin,
      'notificationPreferences': instance.notificationPreferences.toJson(),
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
    };

// **************************************************************************
// ModelBuilderGenerator
// **************************************************************************

Map<String, dynamic>? UserModelToJson(UserModel? instance) => instance == null
    ? null
    : {
        'id': instance.id,
        'displayName': instance.displayName,
        'email': instance.email,
        'firstName': instance.firstName,
        'lastName': instance.lastName,
        'photoUrl': instance.photoUrl,
        'phone': instance.phone,
        'emergencyContactName': instance.emergencyContactName,
        'emergencyContactPhone': instance.emergencyContactPhone,
        'emergencyContactRelation': instance.emergencyContactRelation,
        'medicalConditions': instance.medicalConditions,
        'certifications': instance.certifications,
        'sectionIds': instance.sectionIds,
        'isAdmin': instance.isAdmin,
        'notificationPreferences': NotificationPreferencesToJson(
          instance.notificationPreferences,
        ),
        'createdAt': instance.createdAt == null
            ? null
            : const TimestampConverter().toJson(instance.createdAt),
        'updatedAt': instance.updatedAt == null
            ? null
            : const TimestampConverter().toJson(instance.updatedAt),
      };
UserModel UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: (json['id'] as String),
  displayName: (json['displayName'] as String),
  email: (json['email'] as String),
  firstName: (json['firstName'] as String),
  lastName: (json['lastName'] as String),
  photoUrl: json['photoUrl'] == null ? null : (json['photoUrl'] as String?),
  phone: json['phone'] == null ? null : (json['phone'] as String?),
  emergencyContactName: (json['emergencyContactName'] as String),
  emergencyContactPhone: (json['emergencyContactPhone'] as String),
  emergencyContactRelation: json['emergencyContactRelation'] == null
      ? null
      : (json['emergencyContactRelation'] as String?),
  medicalConditions: json['medicalConditions'] == null
      ? null
      : (json['medicalConditions'] as String?),
  certifications: (json['certifications'] as List<dynamic>).cast<String>(),
  sectionIds: (json['sectionIds'] as List<dynamic>).cast<String>(),
  isAdmin: (json['isAdmin'] as bool),
  notificationPreferences: NotificationPreferences.fromJson(
    (json['notificationPreferences'] as Map<String, dynamic>),
  ),
  createdAt: const TimestampConverter().fromJson(json['createdAt']),
  updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
);

class UserModelPatchBuilder extends PatchBuilder<UserModel> {
  /// Creates a patch builder for `UserModel`.
  UserModelPatchBuilder();

  /// Patch handle for `displayName` (document field `displayName`).
  late final FieldUpdate<String> displayName = FieldUpdate(
    field: const FieldNode(components: ['displayName']),
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

  /// Patch handle for `firstName` (document field `firstName`).
  late final FieldUpdate<String> firstName = FieldUpdate(
    field: const FieldNode(components: ['firstName']),
    toJson: (value) {
      return value;
    },
  );

  /// Patch handle for `lastName` (document field `lastName`).
  late final FieldUpdate<String> lastName = FieldUpdate(
    field: const FieldNode(components: ['lastName']),
    toJson: (value) {
      return value;
    },
  );

  /// Patch handle for `photoUrl` (document field `photoUrl`).
  late final FieldUpdate<String?> photoUrl = FieldUpdate(
    field: const FieldNode(components: ['photoUrl']),
    toJson: (value) {
      return value;
    },
  );

  /// Patch handle for `phone` (document field `phone`).
  late final FieldUpdate<String?> phone = FieldUpdate(
    field: const FieldNode(components: ['phone']),
    toJson: (value) {
      return value;
    },
  );

  /// Patch handle for `emergencyContactName` (document field `emergencyContactName`).
  late final FieldUpdate<String> emergencyContactName = FieldUpdate(
    field: const FieldNode(components: ['emergencyContactName']),
    toJson: (value) {
      return value;
    },
  );

  /// Patch handle for `emergencyContactPhone` (document field `emergencyContactPhone`).
  late final FieldUpdate<String> emergencyContactPhone = FieldUpdate(
    field: const FieldNode(components: ['emergencyContactPhone']),
    toJson: (value) {
      return value;
    },
  );

  /// Patch handle for `emergencyContactRelation` (document field `emergencyContactRelation`).
  late final FieldUpdate<String?> emergencyContactRelation = FieldUpdate(
    field: const FieldNode(components: ['emergencyContactRelation']),
    toJson: (value) {
      return value;
    },
  );

  /// Patch handle for `medicalConditions` (document field `medicalConditions`).
  late final FieldUpdate<String?> medicalConditions = FieldUpdate(
    field: const FieldNode(components: ['medicalConditions']),
    toJson: (value) {
      return value;
    },
  );

  /// Patch handle for `certifications` (document field `certifications`).
  late final ListFieldUpdate<String> certifications = ListFieldUpdate(
    field: const FieldNode(components: ['certifications']),
    toJson: (value) {
      return value;
    },
    elementToJson: (value) {
      return value;
    },
  );

  /// Patch handle for `sectionIds` (document field `sectionIds`).
  late final ListFieldUpdate<String> sectionIds = ListFieldUpdate(
    field: const FieldNode(components: ['sectionIds']),
    toJson: (value) {
      return value;
    },
    elementToJson: (value) {
      return value;
    },
  );

  /// Patch handle for `isAdmin` (document field `isAdmin`).
  late final FieldUpdate<bool> isAdmin = FieldUpdate(
    field: const FieldNode(components: ['isAdmin']),
    toJson: (value) {
      return value;
    },
  );

  /// Patch handle for `notificationPreferences` (document field `notificationPreferences`).
  late final FieldUpdate<NotificationPreferences> notificationPreferences =
      FieldUpdate(
        field: const FieldNode(components: ['notificationPreferences']),
        toJson: (value) {
          return NotificationPreferencesToJson(value);
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

class UserModelFilterBuilder extends FilterBuilderRoot {
  UserModelFilterBuilder({super.field});

  /// Selector for `id`.
  late final FilterField<String, String> id = FilterField<String, String>(
    field: append('id'),
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `displayName`.
  late final FilterField<String, String> displayName =
      FilterField<String, String>(
        field: append('displayName'),
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

  /// Selector for `firstName`.
  late final FilterField<String, String> firstName =
      FilterField<String, String>(
        field: append('firstName'),
        toJson: (value) {
          return value;
        },
      );

  /// Selector for `lastName`.
  late final FilterField<String, String> lastName = FilterField<String, String>(
    field: append('lastName'),
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `photoUrl`.
  late final FilterField<String?, String?> photoUrl =
      FilterField<String?, String?>(
        field: append('photoUrl'),
        toJson: (value) {
          return value;
        },
      );

  /// Selector for `phone`.
  late final FilterField<String?, String?> phone =
      FilterField<String?, String?>(
        field: append('phone'),
        toJson: (value) {
          return value;
        },
      );

  /// Selector for `emergencyContactName`.
  late final FilterField<String, String> emergencyContactName =
      FilterField<String, String>(
        field: append('emergencyContactName'),
        toJson: (value) {
          return value;
        },
      );

  /// Selector for `emergencyContactPhone`.
  late final FilterField<String, String> emergencyContactPhone =
      FilterField<String, String>(
        field: append('emergencyContactPhone'),
        toJson: (value) {
          return value;
        },
      );

  /// Selector for `emergencyContactRelation`.
  late final FilterField<String?, String?> emergencyContactRelation =
      FilterField<String?, String?>(
        field: append('emergencyContactRelation'),
        toJson: (value) {
          return value;
        },
      );

  /// Selector for `medicalConditions`.
  late final FilterField<String?, String?> medicalConditions =
      FilterField<String?, String?>(
        field: append('medicalConditions'),
        toJson: (value) {
          return value;
        },
      );

  /// Selector for `certifications`.
  late final FilterField<List<String>, String> certifications =
      FilterField<List<String>, String>(
        field: append('certifications'),
        toJson: (value) {
          return value;
        },
        elementToJson: (value) {
          return value;
        },
      );

  /// Selector for `sectionIds`.
  late final FilterField<List<String>, String> sectionIds =
      FilterField<List<String>, String>(
        field: append('sectionIds'),
        toJson: (value) {
          return value;
        },
        elementToJson: (value) {
          return value;
        },
      );

  /// Selector for `isAdmin`.
  late final FilterField<bool, bool> isAdmin = FilterField<bool, bool>(
    field: append('isAdmin'),
    toJson: (value) {
      return value;
    },
  );

  /// Nested selector for `notificationPreferences`.
  late final NotificationPreferencesFilterBuilder notificationPreferences =
      NotificationPreferencesFilterBuilder(
        field: append('notificationPreferences'),
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

class UserModelOrderByBuilder extends OrderByBuilderRoot {
  UserModelOrderByBuilder({super.field, required OrderByContext context})
    : _context = context;

  final OrderByContext _context;

  /// Selector for `id`.
  late final OrderByField<String> id = OrderByField(
    field: append('id'),
    context: _context,
  );

  /// Selector for `displayName`.
  late final OrderByField<String> displayName = OrderByField(
    field: append('displayName'),
    context: _context,
  );

  /// Selector for `email`.
  late final OrderByField<String> email = OrderByField(
    field: append('email'),
    context: _context,
  );

  /// Selector for `firstName`.
  late final OrderByField<String> firstName = OrderByField(
    field: append('firstName'),
    context: _context,
  );

  /// Selector for `lastName`.
  late final OrderByField<String> lastName = OrderByField(
    field: append('lastName'),
    context: _context,
  );

  /// Selector for `photoUrl`.
  late final OrderByField<String?> photoUrl = OrderByField(
    field: append('photoUrl'),
    context: _context,
  );

  /// Selector for `phone`.
  late final OrderByField<String?> phone = OrderByField(
    field: append('phone'),
    context: _context,
  );

  /// Selector for `emergencyContactName`.
  late final OrderByField<String> emergencyContactName = OrderByField(
    field: append('emergencyContactName'),
    context: _context,
  );

  /// Selector for `emergencyContactPhone`.
  late final OrderByField<String> emergencyContactPhone = OrderByField(
    field: append('emergencyContactPhone'),
    context: _context,
  );

  /// Selector for `emergencyContactRelation`.
  late final OrderByField<String?> emergencyContactRelation = OrderByField(
    field: append('emergencyContactRelation'),
    context: _context,
  );

  /// Selector for `medicalConditions`.
  late final OrderByField<String?> medicalConditions = OrderByField(
    field: append('medicalConditions'),
    context: _context,
  );

  /// Selector for `certifications`.
  late final OrderByField<List<String>> certifications = OrderByField(
    field: append('certifications'),
    context: _context,
  );

  /// Selector for `sectionIds`.
  late final OrderByField<List<String>> sectionIds = OrderByField(
    field: append('sectionIds'),
    context: _context,
  );

  /// Selector for `isAdmin`.
  late final OrderByField<bool> isAdmin = OrderByField(
    field: append('isAdmin'),
    context: _context,
  );

  /// Nested selector for `notificationPreferences`.
  late final NotificationPreferencesOrderByBuilder notificationPreferences =
      NotificationPreferencesOrderByBuilder(
        field: append('notificationPreferences'),
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

class UserModelAggregateBuilder extends AggregateBuilderRoot {
  UserModelAggregateBuilder({super.field, required AggregateContext context})
    : _context = context;

  final AggregateContext _context;

  /// Nested selector for `notificationPreferences`.
  late final NotificationPreferencesAggregateBuilder notificationPreferences =
      NotificationPreferencesAggregateBuilder(
        field: append('notificationPreferences'),
        context: _context,
      );

  @override
  int count() => _context.resolve(const CountOperation('count'));
}

class UserModelPipelineSelector extends PipelineFieldNode {
  UserModelPipelineSelector({super.components, super.context});

  /// Selector for `id`.
  late final PipelineField<String> id = PipelineField(
    components: [...components, 'id'],
    context: $ctx,
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `displayName`.
  late final PipelineField<String> displayName = PipelineField(
    components: [...components, 'displayName'],
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

  /// Selector for `firstName`.
  late final PipelineField<String> firstName = PipelineField(
    components: [...components, 'firstName'],
    context: $ctx,
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `lastName`.
  late final PipelineField<String> lastName = PipelineField(
    components: [...components, 'lastName'],
    context: $ctx,
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `photoUrl`.
  late final PipelineField<String?> photoUrl = PipelineField(
    components: [...components, 'photoUrl'],
    context: $ctx,
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `phone`.
  late final PipelineField<String?> phone = PipelineField(
    components: [...components, 'phone'],
    context: $ctx,
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `emergencyContactName`.
  late final PipelineField<String> emergencyContactName = PipelineField(
    components: [...components, 'emergencyContactName'],
    context: $ctx,
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `emergencyContactPhone`.
  late final PipelineField<String> emergencyContactPhone = PipelineField(
    components: [...components, 'emergencyContactPhone'],
    context: $ctx,
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `emergencyContactRelation`.
  late final PipelineField<String?> emergencyContactRelation = PipelineField(
    components: [...components, 'emergencyContactRelation'],
    context: $ctx,
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `medicalConditions`.
  late final PipelineField<String?> medicalConditions = PipelineField(
    components: [...components, 'medicalConditions'],
    context: $ctx,
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `certifications`.
  late final PipelineField<List<String>> certifications = PipelineField(
    components: [...components, 'certifications'],
    context: $ctx,
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `sectionIds`.
  late final PipelineField<List<String>> sectionIds = PipelineField(
    components: [...components, 'sectionIds'],
    context: $ctx,
    toJson: (value) {
      return value;
    },
  );

  /// Selector for `isAdmin`.
  late final PipelineField<bool> isAdmin = PipelineField(
    components: [...components, 'isAdmin'],
    context: $ctx,
    toJson: (value) {
      return value;
    },
  );

  /// Nested selector for `notificationPreferences`.
  late final NotificationPreferencesPipelineSelector notificationPreferences =
      NotificationPreferencesPipelineSelector(
        components: [...components, 'notificationPreferences'],
        context: $ctx,
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

extension UserModelPipelineExtension<S extends FirestoreSchema>
    on
        FirestoreCollection<
          S,
          UserModel,
          UserModelPatchBuilder,
          UserModelFilterBuilder,
          UserModelOrderByBuilder,
          UserModelAggregateBuilder
        > {
  TypedPipeline<UserModel, UserModelPipelineSelector> pipeline() =>
      TypedPipeline(
        ref.firestore.pipeline().collection(ref.path),
        UserModelFromJson,
        'id',
        (context) => UserModelPipelineSelector(context: context),
      );
}
