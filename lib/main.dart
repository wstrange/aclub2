import 'dart:async';
import 'dart:io';

import 'package:aclub2/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import 'package:bloc_signals_flutter/bloc_signals_flutter.dart';

import 'routes.dart';
import 'state/user_state_cubit.dart';

// import 'firebase_options.dart';

/// iOS/macOS client ID from Google Cloud Console (Firebase → iOS app aclub.ui).
/// Native platforms require an iOS/macOS OAuth client, not the Web one.
const _googleClientId = '797970173318-61nopoe594icajtj7u0c3pql7ep20see.apps.googleusercontent.com';

void main() async {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.message}');
  });

  try {
    WidgetsFlutterBinding.ensureInitialized();
    // 1. Still initialize Firebase normally first!
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    // Configure the auth providers globally
    FirebaseUIAuth.configureProviders([EmailAuthProvider(), GoogleProvider(clientId: _googleClientId)]);

    // 2. Redirect to Local Emulators only during development
    if (kDebugMode) {
      await _connectToFirebaseEmulator();
    }

    // 3. Determine the initial route by evaluating the guard pipeline
    final initialRoutes = await appGuard(const [], const [HomeRoute()]);
    final initialRoute = initialRoutes.last;
    routerConfig = createRouterConfig(initial: initialRoute);

    // 4. React to auth state changes (e.g. sign out) across the app lifecycle
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      try {
        if (user == null) {
          userStateCubit.clear();
          unawaited(routerConfig.router.reevaluate());
        }
      } catch (e) {
        print('Error in authStateChanges listener: $e');
      }
    });

    runApp(
      BlocSignalProvider<UserStateCubit>.value(
        value: userStateCubit,
        child: MaterialApp.router(
          routerConfig: routerConfig,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            // Explicitly declare Roboto (already bundled with Flutter Web) to
            // prevent the "Could not find Noto fonts" warning in Chrome.
            fontFamily: 'Roboto',
          ),
        ),
      ),
    );
  } catch (e) {
    print('Error: $e');
  }
}

Future<void> _connectToFirebaseEmulator() async {
  String localHost;

  // 1. Check if running on the Web FIRST to prevent dart:io crashes
  if (kIsWeb) {
    localHost = 'localhost';
  } else {
    // 2. If it's a native platform, it's safe to use dart:io's Platform check
    localHost = Platform.isAndroid ? '10.0.2.2' : 'localhost';
  }

  localHost = 'localhost';
  print('Connecting to Firebase Emulator at $localHost...');

  try {
    // Optional: Turn off SSL/Persistence constraints if hitting emulator sync lags
    FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: false, sslEnabled: false);

    // autohost mapping is disabled for running on a usb connected android device vs. an emulator

    // Connect Auth Emulator (default port: 9099)
    await FirebaseAuth.instance.useAuthEmulator(localHost, 9099, automaticHostMapping: false);

    // Connect Firestore Emulator (default port: 8080)
    FirebaseFirestore.instance.useFirestoreEmulator(localHost, 8080, automaticHostMapping: false);

    // Connect Storage Emulator if you use it (default port: 9199)
    // await FirebaseStorage.instance.useStorageEmulator(localHost, 9199);
  } catch (e) {
    print('Error connecting to Firebase Emulator: $e');
  }
}
