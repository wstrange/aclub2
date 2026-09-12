import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_models/shared_models.dart';
import 'package:logging/logging.dart';

final _log = Logger("Repository");

const String defaultSectionId = "national";

final repository = AlpineRepository();

class AlpineRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
    return _firestore.collection('sections').doc(sectionId).collection('events').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Event.fromJson({...doc.data(), 'id': doc.id})).toList();
    });
  }

  Future<List<Event>> getSectionEvents(String sectionId) async {
    final snapshot = await _firestore.collection('sections').doc(sectionId).collection('events').get();
    return snapshot.docs.map((doc) => Event.fromJson({...doc.data(), 'id': doc.id})).toList();
  }

  Future<Event?> getEvent(String sectionId, String eventId) async {
    final doc = await _firestore.collection('sections').doc(sectionId).collection('events').doc(eventId).get();
    if (!doc.exists || doc.data() == null) return null;
    return Event.fromJson({...doc.data()!, 'id': doc.id});
  }

  Stream<Event?> streamEvent(String sectionId, String eventId) {
    return _firestore
        .collection('sections')
        .doc(sectionId)
        .collection('events')
        .doc(eventId)
        .snapshots()
        .map((doc) {
          if (!doc.exists || doc.data() == null) return null;
          return Event.fromJson({...doc.data()!, 'id': doc.id});
        });
  }

  Future<String> createEvent(String sectionId, Event event) async {
    _log.fine('Creating event $event');
    if (event.id.isNotEmpty) {
      await _firestore.collection('sections').doc(sectionId).collection('events').doc(event.id).set(event.toJson());
      return event.id;
    }
    final docRef = await _firestore.collection('sections').doc(sectionId).collection('events').add(event.toJson());
    return docRef.id;
  }

  Future<void> updateEvent(String sectionId, Event event) async {
    _log.fine('Updating event $event');
    await _firestore.collection('sections').doc(sectionId).collection('events').doc(event.id).set(event.toJson());
  }

  Future<void> deleteEvent(String sectionId, String eventId) async {
    await _firestore.collection('sections').doc(sectionId).collection('events').doc(eventId).delete();
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

  Stream<List<Registration>> streamEventRegistrations(String sectionId, String eventId) {
    return _firestore.collection('sections').doc(sectionId).collection('events').doc(eventId).collection('registrations').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Registration.fromJson({...doc.data(), 'id': doc.id})).toList();
    });
  }

  Future<List<Registration>> getEventRegistrations(String sectionId, String eventId) async {
    final snapshot = await _firestore
        .collection('sections')
        .doc(sectionId)
        .collection('events')
        .doc(eventId)
        .collection('registrations')
        .get();
    return snapshot.docs.map((doc) => Registration.fromJson({...doc.data(), 'id': doc.id})).toList();
  }

  Future<void> registerForEvent(String sectionId, String eventId, Registration registration) async {
    await _firestore
        .collection('sections')
        .doc(sectionId)
        .collection('events')
        .doc(eventId)
        .collection('registrations')
        .doc(registration.userId)
        .set(registration.toJson());
  }

  Future<void> updateRegistrationStatus(String sectionId, String eventId, String userId, String newStatus) async {
    await _firestore
        .collection('sections')
        .doc(sectionId)
        .collection('events')
        .doc(eventId)
        .collection('registrations')
        .doc(userId)
        .update({'status': newStatus});
  }

  /// Templates
  Stream<List<Template>> streamTemplates() {
    return _firestore.collection('templates').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Template.fromJson({...doc.data(), 'id': doc.id})).toList();
    });
  }

  Future<void> createTemplate(Template template) async {
    await _firestore.collection('templates').doc(template.id).set(template.toJson());
  }

  Future<void> updateTemplate(Template template) async {
    await _firestore.collection('templates').doc(template.id).set(template.toJson());
  }

  Future<void> deleteTemplate(Template template) async {
    await _firestore.collection('templates').doc(template.id).delete();
  }

  // todo: this looks dodgy agy
  UserProfile? _cachedProfile;

  /// User profile
  ///
  Future<UserProfile?> getUser(String uid) async {
    return await getUserProfile(uid);
  }

  Future<void> createUserProfile(UserProfile u) async {
    await _firestore.collection('users').doc(u.id).set(u.toJson());
    _cachedProfile = u;
  }

  Future<void> updateUserProfile(UserProfile u) async {
    await _firestore.collection('users').doc(u.id).set(u.toJson());
    _cachedProfile = u;
  }

  Future<String> createSection(Section section) async {
    if (section.id.isNotEmpty) {
      await _firestore.collection('sections').doc(section.id).set(section.toJson());
      return section.id;
    }
    final ref = await _firestore.collection('sections').add(section.toJson());
    return ref.id;
  }

  Future<void> updateSection(Section section) async {
    await _firestore.collection('sections').doc(section.id).set(section.toJson());
  }

  Future<List<Section>> getSections() async {
    final snapshot = await _firestore.collection('sections').get();
    return snapshot.docs.map((doc) => Section.fromJson({...doc.data(), 'id': doc.id})).toList();
  }

  Future<Section?> getSection(String sectionId) async {
    final doc = await _firestore.collection('sections').doc(sectionId).get();
    if (!doc.exists) return null;
    return Section.fromJson({...doc.data()!, 'id': doc.id});
  }

  Future<void> deleteSection(Section section) async {
    await _firestore.collection('sections').doc(section.id).delete();
  }

  Future<UserProfile?> getUserProfile(String uid, {bool reload = false}) async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid != uid) {
      _cachedProfile = null;
    }
    if (!reload && _cachedProfile != null && _cachedProfile!.id == uid) {
      return _cachedProfile;
    }
    final doc = await _firestore.collection('users').doc(uid).get();
    _cachedProfile = doc.exists ? UserProfile.fromJson({...doc.data()!, 'id': doc.id}) : null;
    return _cachedProfile;
  }

  void clearProfileCache() {
    _cachedProfile = null;
  }

  // Add to section
  Future<void> addMemberToSection({
    required String sectionId,
    required String userId,
    SectionRole sectionRole = SectionRole.member,
  }) async {
    _log.info("Adding user $userId to section $sectionId");
    var s = SectionMember(sectionId: sectionId, id: userId, sectionRole: sectionRole, joinedAt: DateTime.now());
    await _firestore.collection('sections').doc(sectionId).collection('members').doc(userId).set(s.toJson());
  }

  // Remove from section
  Future<void> removeMemberFromSection({required String sectionId, required String userId}) async {
    _log.info("Removing user $userId from section $sectionId");
    await _firestore.collection('sections').doc(sectionId).collection('members').doc(userId).delete();
  }

  // Set user's chosen sections, syncing both SectionMember subcollections and UserProfile.sectionIds
  Future<void> setUserSections({required String userId, required List<String> sectionIds}) async {
    final profile = await getUserProfile(userId, reload: true);
    final currentSectionIds = profile?.sectionIds ?? const [];

    for (final sectionId in sectionIds) {
      if (!currentSectionIds.contains(sectionId)) {
        await addMemberToSection(sectionId: sectionId, userId: userId);
      }
    }

    for (final currentId in currentSectionIds) {
      if (!sectionIds.contains(currentId)) {
        await removeMemberFromSection(sectionId: currentId, userId: userId);
      }
    }

    if (profile != null) {
      final updated = profile.copyWith(sectionIds: sectionIds, updatedAt: DateTime.now());
      await updateUserProfile(updated);
    }
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
        email: userInfo.email,
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

      _log.info("Created stub profile for ${userInfo.email}");
    }
  }
}
