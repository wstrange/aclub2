import 'dart:io';
import 'package:dart_firebase_admin/dart_firebase_admin.dart';
import 'package:dart_firebase_admin/firestore.dart';
import 'package:shared_models/shared_models.dart';

import 'sample_data.dart';

/// Administrative repository for executing batch operations, data migrations,
/// and management tasks against Cloud Firestore.
///
/// Works against both the Firebase Firestore Emulator (`localhost:8080`) and
/// Google Cloud Platform (GCP).
class AdminRepository {
  late final FirebaseAdminApp adminApp;
  late final Firestore firestore;

  AdminRepository({
    FirebaseAdminApp? app,
    String projectId = 'aclub2',
    bool? useEmulator,
  }) {
    if (app != null) {
      adminApp = app;
    } else {
      final effectiveProjectId = Platform.environment['GCLOUD_PROJECT'] ??
          Platform.environment['FIREBASE_CONFIG_PROJECT_ID'] ??
          projectId;

      adminApp = FirebaseAdminApp.initializeApp(
        effectiveProjectId,
        Credential.fromApplicationDefaultCredentials(),
      );

      final shouldEmulate = useEmulator ??
          Platform.environment.containsKey('FIRESTORE_EMULATOR_HOST');
      if (shouldEmulate) {
        adminApp.useEmulator();
      }
    }
    firestore = Firestore(adminApp);
  }

  // ── Sections ─────────────────────────────────────────────────────────────

  Future<void> createSection(Section section) async {
    await firestore.collection('sections').doc(section.id).set(section.toJson());
  }

  Future<List<Section>> listSections() async {
    final snapshot = await firestore.collection('sections').get();
    return snapshot.docs.map((doc) => Section.fromJson({...doc.data(), 'id': doc.id})).toList();
  }

  // ── Events ───────────────────────────────────────────────────────────────

  Future<void> createEvent(String sectionId, Event event) async {
    await firestore
        .collection('sections')
        .doc(sectionId)
        .collection('events')
        .doc(event.id)
        .set(event.toJson());
  }

  Future<List<Event>> listEvents(String sectionId) async {
    final snapshot = await firestore
        .collection('sections')
        .doc(sectionId)
        .collection('events')
        .get();
    return snapshot.docs.map((doc) => Event.fromJson({...doc.data(), 'id': doc.id})).toList();
  }

  // ── Users & Members ──────────────────────────────────────────────────────

  Future<void> createUserProfile(UserProfile profile) async {
    await firestore.collection('users').doc(profile.id).set(profile.toJson());
  }

  Future<void> addSectionMember(String sectionId, SectionMember member) async {
    await firestore
        .collection('sections')
        .doc(sectionId)
        .collection('members')
        .doc(member.id)
        .set(member.toJson());
  }

  // ── Templates ────────────────────────────────────────────────────────────

  Future<void> createTemplate(Template template) async {
    await firestore.collection('templates').doc(template.id).set(template.toJson());
  }

  // ── Batch Operations & Seeding ───────────────────────────────────────────

  /// Seeds all default sections and sample events.
  Future<Map<String, int>> seedAll({List<Section>? sections, List<Event>? events}) async {
    final seedSections = sections ?? defaultSampleSections;
    final seedEvents = events ?? defaultSampleEvents;

    int sectionCount = 0;
    for (final s in seedSections) {
      await createSection(s);
      sectionCount++;
    }

    int eventCount = 0;
    for (final e in seedEvents) {
      await createEvent(e.sectionId, e);
      eventCount++;
    }

    return {
      'sections': sectionCount,
      'events': eventCount,
    };
  }

  /// Clears sections, events, and templates. Primarily intended for emulator environments.
  Future<void> resetAll() async {
    final sectionsSnap = await firestore.collection('sections').get();
    for (final secDoc in sectionsSnap.docs) {
      final eventsSnap = await secDoc.ref.collection('events').get();
      for (final evDoc in eventsSnap.docs) {
        await evDoc.ref.delete();
      }
      final membersSnap = await secDoc.ref.collection('members').get();
      for (final memDoc in membersSnap.docs) {
        await memDoc.ref.delete();
      }
      await secDoc.ref.delete();
    }

    final templatesSnap = await firestore.collection('templates').get();
    for (final tDoc in templatesSnap.docs) {
      await tDoc.ref.delete();
    }
  }

  /// Returns collection statistics.
  Future<Map<String, dynamic>> getStats() async {
    final sectionsSnap = await firestore.collection('sections').get();
    int totalEvents = 0;
    int totalMembers = 0;
    for (final secDoc in sectionsSnap.docs) {
      final eventsSnap = await secDoc.ref.collection('events').get();
      totalEvents += eventsSnap.docs.length;
      final membersSnap = await secDoc.ref.collection('members').get();
      totalMembers += membersSnap.docs.length;
    }
    final usersSnap = await firestore.collection('users').get();
    return {
      'sections': sectionsSnap.docs.length,
      'events': totalEvents,
      'members': totalMembers,
      'users': usersSnap.docs.length,
    };
  }

  Future<void> close() async {
    await adminApp.close();
  }
}
