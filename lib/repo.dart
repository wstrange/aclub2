import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firestore_odm/firestore_odm.dart';

import 'models/models.dart';
import 'app_schema.dart';

import 'package:logging/logging.dart';

final _log = Logger("Repository");

const String defaultSectionId = "national";

final repository = AlpineRepository();

class AlpineRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final db = FirestoreODM(appSchema, firestore: FirebaseFirestore.instance);

  Stream<List<Section>> streamSections() {
    return _firestore.collection('sections').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Section.fromJson({...doc.data(), 'id': doc.id})).toList();
    });
  }

  // Listen for updates for a user in a section
  Stream<SectionMember?> streamMember(String sectionId, String uid) {
    return _firestore.collection('sections').doc(sectionId).collection('members').doc(uid).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return SectionMember.fromJson({...?doc.data(), 'id': doc.id});
    });
  }

  Stream<List<Event>> streamPublicEvents() {
    return _firestore
        .collection('events')
        .where('status', isEqualTo: 'published')
        .where('visibility', isEqualTo: 'public')
        .orderBy('startDateTime')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Event.fromJson({...doc.data(), 'id': doc.id})).toList();
        });
  }

  Stream<List<Event>> streamSectionEvents(String sectionId) {
    return _firestore
        .collection('events')
        .where('sectionId', isEqualTo: sectionId)
        .where('status', isEqualTo: 'published')
        .orderBy('startDateTime')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Event.fromJson({...doc.data(), 'id': doc.id})).toList();
        });
  }

  Stream<List<Event>> streamLeaderDrafts(String userUid) {
    return _firestore
        .collection('events')
        .where('tripLeaders', arrayContains: userUid)
        .where('status', isEqualTo: 'draft')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Event.fromJson({...doc.data(), 'id': doc.id})).toList();
        });
  }

  Stream<List<Registration>> streamEventRegistrations(String eventId) {
    return _firestore.collection('events').doc(eventId).collection('registrations').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Registration.fromJson({...doc.data(), 'id': doc.id})).toList();
    });
  }

  Future<void> registerForEvent(String eventId, Registration registration) async {
    await _firestore
        .collection('events')
        .doc(eventId)
        .collection('registrations')
        .doc(registration.userId)
        .set(registration.toJson());
  }

  Future<void> updateRegistrationStatus(String eventId, String userId, String newStatus, String newAttendance) async {
    await _firestore.collection('events').doc(eventId).collection('registrations').doc(userId).update({
      'status': newStatus,
      'attendance': newAttendance,
    });
  }

  /// Templates
  Stream<List<Template>> streamTemplates() {
    return _firestore.collection('templates').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Template.fromJson({...doc.data(), 'id': doc.id})).toList();
    });
  }

  Future<void> createTemplate(Template template) async {
    await db.templates.create(template);
  }

  Future<void> updateTemplate(Template template) async {
    await db.templates.set(template);
  }

  Future<void> deleteTemplate(Template template) async {
    await _firestore.collection('templates').doc(template.id).delete();
  }

  /// User profile
  ///
  Future<UserProfile?> getUser(String uid) async {
    return await db.users(uid).get();
  }

  Future<void> createUserProfile(UserProfile u) async {
    await db.users.set(u);
  }

  Future<void> updateUserProfile(UserProfile u) async {
    await db.users.set(u);
  }

  Future<String> createSection(Section section) async {
    if (section.id.isNotEmpty) {
      await db.sections.set(section);
      return section.id;
    }
    return await db.sections.create(section);
  }

  Future<void> updateSection(Section section) async {
    await db.sections.set(section);
  }

  Future<List<Section>> getSections() async {
    return await db.sections.get();
  }

  Future<Section?> getSection(String sectionId) async {
    return await db.sections(sectionId).get();
  }

  Future<void> deleteSection(Section section) async {
    await db.sections.delete(section.id);
  }

  Future<UserProfile?> getUserProfile(String uid) async {
    return await db.users(uid).get();
  }

  // Add to section
  Future<void> addMemberToSection({required String sectionId, required String userId}) async {
    _log.info("Adding user $userId to section $sectionId");
    var s = SectionMember(
      sectionId: sectionId,
      id: userId,
      sectionRole: SectionRole.tripLeader,
      joinedAt: DateTime.now(),
    );
    await db.sectionsMembers(sectionId).set(s);
  }

  // Called on login. Checks to see if the user has a complated profile.
  // if not, creates a stub profile for them.

  Future<void> checkProfile(User userInfo) async {
    final up = await getUserProfile(userInfo.uid);

    if (up == null) {
      _log.info("Creating stub profile for ${userInfo.email}");

      final user = UserProfile(
        id: userInfo.uid,
        firstName: '',
        lastName: '',
        phone: '555-1212',
        emergencyContactName: '',
        emergencyContactPhone: '',
        notificationPreferences: NotificationPreferences(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        complatedProfile: false,
        signedWaiver: false,
      );

      await createUserProfile(user);

      await addMemberToSection(sectionId: defaultSectionId, userId: user.id);

      _log.info("Created stub profile for ${userInfo.email}");
    }
  }
}
