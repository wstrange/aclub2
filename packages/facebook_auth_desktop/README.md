# facebook_auth_desktop (vendored)

Vendored copy of [`facebook_auth_desktop` 2.1.3](https://pub.dev/packages/facebook_auth_desktop)
(the macOS implementation of [`flutter_facebook_auth`](https://pub.dev/packages/flutter_facebook_auth),
by darwin-morocho / meedu.app — see `LICENSE`).

The only change: `macos/facebook_auth_desktop/Package.swift` was added so the
macOS native plugin resolves through **Swift Package Manager**. The published
package ships a CocoaPods-only `.podspec` for macOS, and Flutter 3.44+ falls
back to CocoaPods (this project removed it) when any dependency lacks SPM
support.

The `pubspec.yaml` here wires the same plugin coordinates (`pluginClass` +
`dartPluginClass` `FacebookAuthDesktopPlugin`) so `flutter_facebook_auth`'s
`macos: default_package: facebook_auth_desktop` resolves to this copy via a
`dependency_overrides` entry in the root `pubspec.yaml`.

When the published package ships SPM support, delete this directory and the
override, and use the published version again.
