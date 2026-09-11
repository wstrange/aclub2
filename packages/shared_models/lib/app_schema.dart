import 'package:firestore_odm/firestore_odm.dart';
import 'models.dart';

part 'app_schema.g.dart';

class AppSchema extends FirestoreSchema {
  const AppSchema();
}

/// Firestore schema for the aclub2 application.
///
/// Collection hierarchy:
/// ```
/// /users/{userId}
/// /sections/{sectionId}
/// /sections/{sectionId}/members/{userId}
/// /sections/{sectionId}/events/{eventId}
/// /sections/{sectionId}/events/{eventId}/registrations/{registrationId}
/// /notifications/{notificationId}
/// /templates/{templateId}
/// ```
@Schema()
@Collection<UserProfile>('users')
@Collection<Section>('sections')
@Collection<SectionMember>('sections/*/members')
@Collection<Event>('sections/*/events')
@Collection<Registration>('sections/*/events/*/registrations')
@Collection<NotificationModel>('notifications')
@Collection<Template>('templates')
const AppSchema appSchema = AppSchema();
