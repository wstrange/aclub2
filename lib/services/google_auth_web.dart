// Google sign-in on web: Firebase's popup OAuth flow. No extra packages are
// needed — `firebase_auth`'s web plugin handles it via the app's configured
// Google Cloud project.
import 'package:firebase_auth/firebase_auth.dart';

/// Signs in with Google via the Firebase web popup. Returns `null` when the
/// user closes the popup without completing the flow.
Future<UserCredential?> signInWithGoogle() async {
  return FirebaseAuth.instance.signInWithPopup(GoogleAuthProvider());
}
