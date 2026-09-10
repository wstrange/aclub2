// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_schema.dart';

// **************************************************************************
// Generator: SchemaGenerator2
// **************************************************************************

extension AppSchemaFirestoreODMExtension on FirestoreODM<AppSchema> {
  FirestoreCollection<
    AppSchema,
    UserModel,
    UserModelPatchBuilder,
    UserModelFilterBuilder,
    UserModelOrderByBuilder,
    UserModelAggregateBuilder
  >
  get users => FirestoreCollection(
    ref: firestore.collection('users'),
    toJson: (UserModel value) {
      return UserModelToJson(value) ?? const <String, dynamic>{};
    },
    fromJson: UserModelFromJson,
    documentIdField: 'id',
    patchBuilderFactory: () => UserModelPatchBuilder(),
    filterBuilder: UserModelFilterBuilder(),
    orderByBuilderFunc: (context) => UserModelOrderByBuilder(context: context),
    aggregateBuilderFunc: (context) =>
        UserModelAggregateBuilder(context: context),
  );

  FirestoreCollection<
    AppSchema,
    Section,
    SectionPatchBuilder,
    SectionFilterBuilder,
    SectionOrderByBuilder,
    SectionAggregateBuilder
  >
  get sections => FirestoreCollection(
    ref: firestore.collection('sections'),
    toJson: (Section value) {
      return SectionToJson(value) ?? const <String, dynamic>{};
    },
    fromJson: SectionFromJson,
    documentIdField: 'id',
    patchBuilderFactory: () => SectionPatchBuilder(),
    filterBuilder: SectionFilterBuilder(),
    orderByBuilderFunc: (context) => SectionOrderByBuilder(context: context),
    aggregateBuilderFunc: (context) =>
        SectionAggregateBuilder(context: context),
  );

  FirestoreCollection<
    AppSchema,
    SectionMember,
    SectionMemberPatchBuilder,
    SectionMemberFilterBuilder,
    SectionMemberOrderByBuilder,
    SectionMemberAggregateBuilder
  >
  sectionsMembers([String? p1]) => FirestoreCollection(
    ref: firestore.collection("sections/${p1}/members"),
    toJson: (SectionMember value) {
      return SectionMemberToJson(value) ?? const <String, dynamic>{};
    },
    fromJson: SectionMemberFromJson,
    documentIdField: null,
    patchBuilderFactory: () => SectionMemberPatchBuilder(),
    filterBuilder: SectionMemberFilterBuilder(),
    orderByBuilderFunc: (context) =>
        SectionMemberOrderByBuilder(context: context),
    aggregateBuilderFunc: (context) =>
        SectionMemberAggregateBuilder(context: context),
  );

  FirestoreCollection<
    AppSchema,
    Event,
    EventPatchBuilder,
    EventFilterBuilder,
    EventOrderByBuilder,
    EventAggregateBuilder
  >
  sectionsEvents([String? p1]) => FirestoreCollection(
    ref: firestore.collection("sections/${p1}/events"),
    toJson: (Event value) {
      return EventToJson(value) ?? const <String, dynamic>{};
    },
    fromJson: EventFromJson,
    documentIdField: 'id',
    patchBuilderFactory: () => EventPatchBuilder(),
    filterBuilder: EventFilterBuilder(),
    orderByBuilderFunc: (context) => EventOrderByBuilder(context: context),
    aggregateBuilderFunc: (context) => EventAggregateBuilder(context: context),
  );

  FirestoreCollection<
    AppSchema,
    Registration,
    RegistrationPatchBuilder,
    RegistrationFilterBuilder,
    RegistrationOrderByBuilder,
    RegistrationAggregateBuilder
  >
  sectionsEventsRegistrations([String? p1, String? p2]) => FirestoreCollection(
    ref: firestore.collection("sections/${p1}/events/${p2}/registrations"),
    toJson: (Registration value) {
      return RegistrationToJson(value) ?? const <String, dynamic>{};
    },
    fromJson: RegistrationFromJson,
    documentIdField: 'id',
    patchBuilderFactory: () => RegistrationPatchBuilder(),
    filterBuilder: RegistrationFilterBuilder(),
    orderByBuilderFunc: (context) =>
        RegistrationOrderByBuilder(context: context),
    aggregateBuilderFunc: (context) =>
        RegistrationAggregateBuilder(context: context),
  );

  FirestoreCollection<
    AppSchema,
    NotificationModel,
    NotificationModelPatchBuilder,
    NotificationModelFilterBuilder,
    NotificationModelOrderByBuilder,
    NotificationModelAggregateBuilder
  >
  get notifications => FirestoreCollection(
    ref: firestore.collection('notifications'),
    toJson: (NotificationModel value) {
      return NotificationModelToJson(value) ?? const <String, dynamic>{};
    },
    fromJson: NotificationModelFromJson,
    documentIdField: 'id',
    patchBuilderFactory: () => NotificationModelPatchBuilder(),
    filterBuilder: NotificationModelFilterBuilder(),
    orderByBuilderFunc: (context) =>
        NotificationModelOrderByBuilder(context: context),
    aggregateBuilderFunc: (context) =>
        NotificationModelAggregateBuilder(context: context),
  );

  FirestoreCollection<
    AppSchema,
    Template,
    TemplatePatchBuilder,
    TemplateFilterBuilder,
    TemplateOrderByBuilder,
    TemplateAggregateBuilder
  >
  get templates => FirestoreCollection(
    ref: firestore.collection('templates'),
    toJson: (Template value) {
      return TemplateToJson(value) ?? const <String, dynamic>{};
    },
    fromJson: TemplateFromJson,
    documentIdField: 'id',
    patchBuilderFactory: () => TemplatePatchBuilder(),
    filterBuilder: TemplateFilterBuilder(),
    orderByBuilderFunc: (context) => TemplateOrderByBuilder(context: context),
    aggregateBuilderFunc: (context) =>
        TemplateAggregateBuilder(context: context),
  );
}
