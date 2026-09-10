import 'dart:io';

import 'package:aclub2/firebase_options.dart';
import 'package:bloc_signals_flutter/bloc_signals_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import 'admin/setup.dart';
import 'pages/user_profile_page.dart';
import 'repo.dart';
import 'routes.dart';

// import 'firebase_options.dart';

final repo = AlpineRepository();

void main() async {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.message}');
  });
  WidgetsFlutterBinding.ensureInitialized();
  // 1. Still initialize Firebase normally first!
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Configure the auth providers globally
  FirebaseUIAuth.configureProviders([EmailAuthProvider()]);

  // 2. Redirect to Local Emulators only during development
  if (kDebugMode) {
    await _connectToFirebaseEmulator();
  }

  await createSections();

  runApp(
    MultiBlocSignalProvider(
      providers: [BlocSignalProvider<UserModelCubit>(create: (context) => UserModelCubit(repo))],
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

  print('Connecting to Firebase Emulator at $localHost...');

  try {
    // Connect Auth Emulator (default port: 9099)
    await FirebaseAuth.instance.useAuthEmulator(localHost, 9099);

    // Connect Firestore Emulator (default port: 8080)
    FirebaseFirestore.instance.useFirestoreEmulator(localHost, 8080);

    // Optional: Turn off SSL/Persistence constraints if hitting emulator sync lags
    FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: false, sslEnabled: false);

    // Connect Storage Emulator if you use it (default port: 9199)
    // await FirebaseStorage.instance.useStorageEmulator(localHost, 9199);
  } catch (e) {
    print('Error connecting to Firebase Emulator: $e');
  }
}
