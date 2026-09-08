import 'package:cloud_firestore/cloud_firestore.dart';

import 'models/models.dart';

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
    await _firestore.collection('templates').add(template.toJson());
  }

  Future<void> updateTemplate(Template template) async {
    await _firestore.collection('templates').doc(template.id).update(template.toJson());
  }

  Future<void> deleteTemplate(Template template) async {
    await _firestore.collection('templates').doc(template.id).delete();
  }

  /// User profile
  ///
  Future<UserModel?> getUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return UserModel.fromJson({...?doc.data(), 'id': doc.id});
  }

  Future<void> createUser(UserModel u) async {
    await _firestore.collection('users').doc(u.id).set(u.toJson());
  }

  Future<void> updateUser(UserModel u) async {
    await _firestore.collection('users').doc(u.id).update(u.toJson());
  }
}
