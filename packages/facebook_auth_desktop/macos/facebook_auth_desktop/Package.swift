// swift-tools-version: 5.9
// Added when vendoring this plugin into the aclub2 repo: the published
// facebook_auth_desktop only ships a .podspec for its macOS plugin, which is
// incompatible with this project's Swift-Package-Manager-only setup.
// (See packages/facebook_auth_desktop/README-vendored block in pubspec.yaml.)
//
// The native code needs no external dependencies (Flutter + WebKit only), so
// the Flutter SPM plugin build support resolves `import FlutterMacOS` for us,
// matching how google_sign_in_ios' darwin package is structured.

import PackageDescription

let package = Package(
  name: "facebook_auth_desktop",
  platforms: [
    .macOS("12.0"),
  ],
  products: [
    .library(name: "facebook-auth-desktop", targets: ["facebook_auth_desktop"]),
  ],
  targets: [
    .target(
      name: "facebook_auth_desktop",
      resources: []
    ),
  ]
)
