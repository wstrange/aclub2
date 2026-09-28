// ignore_for_file: experimental_member_use

import 'package:firebase_functions/firebase_functions.dart';

import 'src/event_handlers.dart';
import 'src/registration_handlers.dart';

export 'src/event_handlers.dart';
export 'src/notification_dispatcher.dart';
export 'src/registration_handlers.dart';

/// Registers all Cloud Functions (HTTP endpoints and background triggers).
///
/// Called from `bin/server.dart` at startup.
void registerFunctions(Firebase firebase) {
  firebase.https.onRequest(name: 'helloWorld', helloWorld);

  // ── Events triggers ────────────────────────────────────────────────────────
  firebase.firestore.onDocumentCreated(
    document: 'sections/{sectionId}/events/{eventId}',
    (event) => onNewEventCreated(event, firebase),
  );

  firebase.firestore.onDocumentUpdated(
    document: 'sections/{sectionId}/events/{eventId}',
    (event) => onEventUpdated(event, firebase),
  );

  // ── Registrations triggers ─────────────────────────────────────────────────
  firebase.firestore.onDocumentCreatedWithAuthContext(
    document: 'sections/{sectionId}/events/{eventId}/registrations/{registrationId}',
    (event) => onRegistrationCreated(event, firebase),
  );

  firebase.firestore.onDocumentUpdatedWithAuthContext(
    document: 'sections/{sectionId}/events/{eventId}/registrations/{registrationId}',
    (event) => onRegistrationUpdated(event, firebase),
  );

  firebase.firestore.onDocumentDeletedWithAuthContext(
    document: 'sections/{sectionId}/events/{eventId}/registrations/{registrationId}',
    (event) => onRegistrationDeleted(event, firebase),
  );
}

/// Health check Cloud Function: `/helloWorld`
Future<Response> helloWorld(Request request) async {
  return Response.ok('Hello from aclub Dart Functions!');
}
