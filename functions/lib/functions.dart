// ignore_for_file: experimental_member_use

import 'dart:io';

import 'package:firebase_functions/firebase_functions.dart';

import 'src/event_handlers.dart';
import 'src/https_handlers.dart';
import 'src/registration_handlers.dart';

export 'src/event_handlers.dart';
export 'src/https_handlers.dart';
export 'src/notification_dispatcher.dart';
export 'src/registration_handlers.dart';

/// Whether functions are currently running within a Firebase Emulator environment.
bool get isFirebaseEmulator =>
    Platform.environment['FUNCTIONS_EMULATOR'] == 'true' ||
    Platform.environment.containsKey('FIRESTORE_EMULATOR_HOST') ||
    Platform.environment.containsKey('FIREBASE_EMULATOR_HUB') ||
    Platform.environment.containsKey('FIREBASE_AUTH_EMULATOR_HOST');

/// Registers all Cloud Functions (HTTPS endpoints and emulator background triggers).
///
/// Dual strategy:
/// 1. Registers HTTPS endpoints for production (and Eventarc triggers / webhooks).
/// 2. Registers Firestore background triggers when running in the Firebase Emulator.
void registerFunctions(Firebase firebase) {
  // ── Health check ────────────────────────────────────────────────────────────
  firebase.https.onRequest(name: 'helloWorld', helloWorld);

  // ── HTTPS endpoints for production & Eventarc ───────────────────────────────
  firebase.https.onRequest(
    name: 'eventCreatedHttp',
    (request) => handleEventCreatedHttp(request, firebase),
  );

  firebase.https.onRequest(
    name: 'eventUpdatedHttp',
    (request) => handleEventUpdatedHttp(request, firebase),
  );

  firebase.https.onRequest(
    name: 'registrationCreatedHttp',
    (request) => handleRegistrationCreatedHttp(request, firebase),
  );

  firebase.https.onRequest(
    name: 'registrationUpdatedHttp',
    (request) => handleRegistrationUpdatedHttp(request, firebase),
  );

  firebase.https.onRequest(
    name: 'registrationDeletedHttp',
    (request) => handleRegistrationDeletedHttp(request, firebase),
  );

  firebase.https.onRequest(
    name: 'notificationTriggerHttp',
    (request) => handleNotificationTriggerHttp(request, firebase),
  );

  // ── Emulator Firestore triggers ─────────────────────────────────────────────
  // Active in emulator mode. Production uses the HTTPS endpoints above.
  if (isFirebaseEmulator) {
    _registerEmulatorFirestoreTriggers(firebase);
  }
}

/// Registers direct Firestore triggers for the Firebase Emulator.
void _registerEmulatorFirestoreTriggers(Firebase firebase) {
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
