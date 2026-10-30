import 'dart:io';
import 'package:dart_firebase_admin/dart_firebase_admin.dart';
import 'package:dart_firebase_admin/auth.dart';

Future<void> main() async {
  // Correct method: Pass the Project ID string first, followed by the Credential object
  final adminApp = FirebaseAdminApp.initializeApp(
    'YOUR_FIREBASE_PROJECT_ID',
    // Never check this into source control!
    Credential.fromServiceAccount(File('/Users/warren/serviceAccountKey.json')),
  );

  final auth = Auth(adminApp);

  final uid = 'RVbO0QLNlmPLmUhiKD0ShlXJ66C2';

  // Use the auth instance to set claims...
  await auth.setCustomUserClaims(uid, customUserClaims: {'role': 'admin'});

  await adminApp.close();
}
