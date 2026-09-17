import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_models/shared_models.dart';
import 'package:logging/logging.dart';

final _log = Logger("Repository");

const String defaultSectionId = "national";

final repository = AlpineRepository();

class AlpineRepository {
  final FirebaseFirestore _firestore;

  AlpineRepository({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<Section>> streamSections() {
    return _firestore.collection('sections').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Section.fromJson({...doc.data(), 'id': doc.id})).toList();
    });
  }

  // Listen for updates for a user in a section
  Stream<SectionMember?> streamMember(String sectionId, String uid) {
    _log.fine('streamMember for section $sectionId, for user $uid');
    return _firestore.collection('sections').doc(sectionId).collection('members').doc(uid).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return SectionMember.fromJson({...?doc.data(), 'id': doc.id});
    });
  }

  Future<List<SectionMember>> getSectionMembers(String sectionId) async {
    final snapshot = await _firestore.collection('sections').doc(sectionId).collection('members').get();
    return snapshot.docs.map((doc) => SectionMember.fromJson({...doc.data(), 'id': doc.id})).toList();
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
    return _firestore.collection('sections').doc(sectionId).collection('events').doc(eventId).snapshots().map((doc) {
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

  /// Creates a new [Event] that is a copy of [source] (see
  /// [Event.copyForDuplicate] for how dates, title, and trip leaders are
  /// handled). When [copyParticipantsAndLeaders] is true, the source's
  /// registrations are also copied to the new event.
  ///
  /// Returns the created event (with its Firestore document ID).
  Future<Event> duplicateEvent(
    String sectionId, {
    required Event source,
    required bool copyParticipantsAndLeaders,
    required String creatorId,
  }) async {
    final copy = source.copyForDuplicate(
      now: DateTime.now(),
      copyParticipantsAndLeaders: copyParticipantsAndLeaders,
      creatorId: creatorId,
    );

    final newId = await createEvent(sectionId, copy);
    final newEvent = copy.copyWith(id: newId);

    if (copyParticipantsAndLeaders) {
      final registrations = await getEventRegistrations(sectionId, source.id);
      for (final registration in registrations) {
        await registerForEvent(sectionId, newId, registration);
      }
    }

    return newEvent;
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
    _log.fine('streamEventRegistrations for section $sectionId, event $eventId');
    return _firestore
        .collection('sections')
        .doc(sectionId)
        .collection('events')
        .doc(eventId)
        .collection('registrations')
        .snapshots()
        .map((snapshot) {
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
    _log.fine(
      'getEventRegistrations for section $sectionId, event $eventId found ${snapshot.docs.length} registrations',
    );
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

  Future<void> removeRegistration(String sectionId, String eventId, String userId) async {
    await _firestore
        .collection('sections')
        .doc(sectionId)
        .collection('events')
        .doc(eventId)
        .collection('registrations')
        .doc(userId)
        .delete();
  }

  /// Templates
  Stream<List<Template>> streamTemplates() {
    return _firestore.collection('templates').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Template.fromJson({...doc.data(), 'id': doc.id})).toList();
    });
  }

  Future<Template?> getTemplate(String templateId) async {
    final doc = await _firestore.collection('templates').doc(templateId).get();
    if (!doc.exists || doc.data() == null) return null;
    return Template.fromJson({...doc.data()!, 'id': doc.id});
  }

  Future<String> createTemplate(Template template) async {
    if (template.id.isNotEmpty) {
      await _firestore.collection('templates').doc(template.id).set(template.toJson());
      return template.id;
    }
    final docRef = await _firestore.collection('templates').add(template.toJson());
    return docRef.id;
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

  /// The sections the user is a member of, sourced from the
  /// `sections/{sectionId}/members/{userId}` subcollection (the source of
  /// truth for membership — the profile does not store section membership).
  ///
  /// Uses per-section point reads, since querying a collection group by
  /// `FieldPath.documentId` with a bare user ID is not supported.
  Future<List<SectionMember>> getUserMemberships(String uid, {List<Section>? sections}) async {
    final allSections = sections ?? await getSections();
    final results = await Future.wait(allSections.map((section) async {
      final doc = await _firestore.collection('sections').doc(section.id).collection('members').doc(uid).get();
      if (!doc.exists || doc.data() == null) return null;
      return SectionMember.fromJson({...doc.data()!, 'id': doc.id, 'sectionId': section.id});
    }));
    return results.whereType<SectionMember>().toList();
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

  // Set user's chosen sections. The authoritative membership record is the
  // members subcollection (`sections/{sectionId}/members/{userId}`); the
  // profile does not store section membership.
  Future<void> setUserSections({required String userId, required List<String> sectionIds}) async {
    final currentMemberships = await getUserMemberships(userId);
    final currentSectionIds = currentMemberships.map((m) => m.sectionId).toSet();

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

  // ── Notifications ──────────────────────────────────────────────────────────

  /// Streams notifications for a given recipient [userId], newest first.
  Stream<List<NotificationModel>> streamNotifications(String userId) {
    _log.fine('streamNotifications for user $userId');
    return _firestore
        .collection('notifications')
        .where('recipientId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => NotificationModel.fromJson({...doc.data(), 'id': doc.id}))
              .toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  /// Gets all notifications for a given recipient [userId], newest first.
  Future<List<NotificationModel>> getNotifications(String userId) async {
    final snapshot = await _firestore
        .collection('notifications')
        .where('recipientId', isEqualTo: userId)
        .get();
    final list = snapshot.docs
        .map((doc) => NotificationModel.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  /// Gets a single notification by [notificationId].
  Future<NotificationModel?> getNotification(String notificationId) async {
    final doc = await _firestore.collection('notifications').doc(notificationId).get();
    if (!doc.exists || doc.data() == null) return null;
    return NotificationModel.fromJson({...doc.data()!, 'id': doc.id});
  }

  /// Marks a notification as read or unread.
  Future<void> markNotificationAsRead(String notificationId, {bool isRead = true}) async {
    _log.fine('Marking notification $notificationId as read=$isRead');
    await _firestore.collection('notifications').doc(notificationId).update({'isRead': isRead});
  }

  /// Deletes a notification by [notificationId].
  Future<void> deleteNotification(String notificationId) async {
    _log.fine('Deleting notification $notificationId');
    await _firestore.collection('notifications').doc(notificationId).delete();
  }

  /// Deletes all notifications for a given recipient [userId].
  Future<void> deleteAllNotifications(String userId) async {
    _log.fine('Deleting all notifications for user $userId');
    final snapshot = await _firestore
        .collection('notifications')
        .where('recipientId', isEqualTo: userId)
        .get();
    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  /// Creates a new notification document.
  Future<String> createNotification(NotificationModel notification) async {
    _log.fine('Creating notification for ${notification.recipientId}');
    if (notification.id.isNotEmpty) {
      await _firestore.collection('notifications').doc(notification.id).set(notification.toJson());
      return notification.id;
    }
    final docRef = await _firestore.collection('notifications').add(notification.toJson());
    return docRef.id;
  }
}
