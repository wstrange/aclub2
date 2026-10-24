# Facebook Login setup

The Flutter app already uses Meta App ID `954559893876564`. Do not put the
Meta **App Secret** in this repository or in a mobile application.

## 1. Meta for Developers

Open the app in [Meta for Developers](https://developers.facebook.com/apps/954559893876564/).

In **Settings → Basic**:

- **App ID:** leave as `954559893876564`.
- **App Secret:** copy this only for the Firebase Console in step 2.
- **Privacy Policy URL:** enter the public URL for AClub's privacy policy.
- **User Data Deletion:** provide the public deletion-instructions URL (or a
  Data Deletion Callback URL) before the app is made Live.
- **Category:** select the category that best fits AClub, normally `Business
  and pages` or `Community and government`.
- Add the iOS platform with bundle ID `com.aclub.ui` if it is not already
  listed. No iPad Store ID is needed for development.
- Add the Android platform with Google Play package name `com.aclub.ui`. Add
  each signing key hash used to build the app. The current local debug-key
  hash is `ZaSBARx3hDglk9TBD1wI5oCMNfs=`. Add your release / Play App Signing
  key hash separately before shipping.

In **Settings → Advanced**, copy the **Client Token**. It is required in the
native SDK configuration, but is *not* the App Secret. Replace
`CHANGE_ME_CLIENT_TOKEN` with it in both:

- `android/app/src/main/res/values/strings.xml`
- `ios/Runner/Info.plist`

In **Add product → Facebook Login → Settings**:

- Enable **Client OAuth Login** and **Web OAuth Login**.
- Add this exact **Valid OAuth Redirect URI**:
  `https://aclub2.firebaseapp.com/__/auth/handler`
- For the macOS desktop flow, also enable **Login from Devices**. The desktop
  integration uses Meta's web OAuth dialog.

Keep the Meta app in Development mode while testing: only people with a role
on the app (or Meta test users) can log in. Switch it to Live only after the
required URLs and app details are complete.

## 2. Firebase Console

Open [Firebase Authentication providers](https://console.firebase.google.com/project/aclub2/authentication/providers).
Select **Facebook**, enable it, and enter:

- **App ID:** `954559893876564`
- **App secret:** the Meta **App Secret** from Settings → Basic (never the
  Client Token)

Save the provider. The Firebase web flow reads these server-side values; no
secret belongs in Flutter source.

## 3. Test

Run an Android debug build and choose **Continue with Facebook**. A successful
login returns a Facebook access token which the app exchanges with Firebase.
For a release build, add the release/Play signing key hash in Meta first.

If the browser flow says the redirect URI is invalid, re-check the URI above
character-for-character, including `/__/auth/handler`.
