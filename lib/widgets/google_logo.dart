import 'package:flutter/material.dart';

/// The multicolor Google "G" shown on the sign-in button.
///
/// This is Google's published sign-in branding asset (48dp @2x, bundled at
/// assets/icon/google_g.png), so the four brand colors survive. An icon font
/// such as `font_awesome_flutter` could not be used for this: icon glyphs
/// paint in a single color, and Google's branding guidelines require the
/// standard multicolor mark on a white/neutral surface.
class const GoogleLogo({super.key, this.size = 20}) extends StatelessWidget {
  /// Rendered width and height; Google requires at least 16dp.
  final double size;

  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/icon/google_g.png',
    width: size,
    height: size,
    filterQuality: FilterQuality.medium,
    excludeFromSemantics: true,
  );
}
