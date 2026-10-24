// Facebook sign-in — the platform-appropriate implementation is selected by
// conditional export (see facebook_auth.dart).
export 'facebook_auth_io.dart' if (dart.library.html) 'facebook_auth_web.dart';
