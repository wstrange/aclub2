// Generates the launcher icon art for the Alpine Club of Canada from the
// official bilingual logo:
//
//   assets/icon/app_icon.png            — 1024×1024, logo on a white round rect
//   assets/icon/app_icon_foreground.png — adaptive-icon foreground (safe zone)
//
// Source: assets/icon/acc_logo_source.webp
// (https://alpineclubofcanada.ca/wp-content/uploads/2024/03/AlpineClub_Logos_RGB_Secondary_Bilingual-600x230.webp)
//
// The art is drawn at 2048² (supersampled) and downsampled to 1024² for
// anti-aliasing. Tuning lives in the "Layout" section; regenerate with:
//
//   dart run tool/generate_app_icon.dart
//
// then propagate the PNGs to the platform icon sets with:
//
//   dart run flutter_launcher_icons
import 'dart:io';

import 'package:image/image.dart' as img;

const size = 2048; // native supersampled draw size
const outSize = 1024;
const cornerRadius = 420.0; // of the rounded square

// Layout: the logo spans this fraction of the icon width, centered.
const logoWidthFraction = 0.78;

// Adaptive-icon foreground: the logo is drawn at this fraction of the canvas
// width (and centered) over transparency; the OS supplies the background.
const adaptiveLogoWidth = 0.62;

const _sourcePath = 'assets/icon/acc.png';

void main() {
  final logoBytes = File(_sourcePath).readAsBytesSync();
  final logo = img.decodeImage(logoBytes);
  if (logo == null) {
    stderr.writeln('❌ Could not decode $_sourcePath');
    exit(1);
  }

  Directory('assets/icon').createSync(recursive: true);

  final full = _drawArt(logo);
  final icon = img.copyResize(full, width: outSize, height: outSize, interpolation: img.Interpolation.cubic);
  File('assets/icon/app_icon.png').writeAsBytesSync(img.encodePng(icon, level: 9));

  // Adaptive-icon foreground: the logo centered inside the safe zone over
  // transparency.
  final scaled = img.copyResize(
    logo,
    width: (size * adaptiveLogoWidth).round(),
    interpolation: img.Interpolation.cubic,
  );
  final fg = img.Image(width: size, height: size, numChannels: 4);
  fg.clear(img.ColorRgba8(0, 0, 0, 0));
  _alphaBlend(fg, scaled, dstX: (size - scaled.width) ~/ 2, dstY: (size - scaled.height) ~/ 2);
  final fgOut = img.copyResize(fg, width: outSize, height: outSize, interpolation: img.Interpolation.cubic);
  File('assets/icon/app_icon_foreground.png').writeAsBytesSync(img.encodePng(fgOut, level: 9));

  stdout.writeln('✅ Wrote assets/icon/app_icon.png and assets/icon/app_icon_foreground.png');
}

// ── Layout ───────────────────────────────────────────────────────────────────

img.Image _drawArt(img.Image logo) {
  final image = img.Image(width: size, height: size, numChannels: 4);
  image.clear(img.ColorRgba8(0xFF, 0xFF, 0xFF, 0xFF)); // white field

  final scaled = img.copyResize(
    logo,
    width: (size * logoWidthFraction).round(),
    interpolation: img.Interpolation.cubic,
  );
  _alphaBlend(
    image,
    scaled,
    dstX: (size - scaled.width) ~/ 2,
    dstY: (size - scaled.height) ~/ 2,
    clipTo: (x, y) => _insideRoundedRect(x, y),
  );

  // Clear anything outside the rounded square.
  for (var y = 0; y < size; y++) {
    for (var x = 0; x < size; x++) {
      if (!_insideRoundedRect(x, y)) {
        image.setPixel(x, y, img.ColorRgba8(0, 0, 0, 0));
      }
    }
  }
  return image;
}

/// Blends [src] onto [dst] at ([dstX], [dstY]) with source-over compositing.
/// [clipTo] optionally suppresses pixels outside the allowed area.
void _alphaBlend(
  img.Image dst,
  img.Image src, {
  required int dstX,
  required int dstY,
  bool Function(int x, int y)? clipTo,
}) {
  for (var sy = 0; sy < src.height; sy++) {
    for (var sx = 0; sx < src.width; sx++) {
      final dx = dstX + sx;
      final dy = dstY + sy;
      if (dx < 0 || dy < 0 || dx >= dst.width || dy >= dst.height) continue;
      if (clipTo != null && !clipTo(dx, dy)) continue;

      final s = src.getPixel(sx, sy);
      final sr = s.r.toInt();
      final sg = s.g.toInt();
      final sb = s.b.toInt();
      if (s.a >= 0xFF) {
        dst.setPixel(dx, dy, img.ColorRgba8(sr, sg, sb, 0xFF));
        continue;
      }
      final d = dst.getPixel(dx, dy);
      final a = s.a / 0xFF;
      int blend(int sc, int dc) => (sc * a + dc * (1 - a)).round().clamp(0, 255);
      dst.setPixel(
        dx,
        dy,
        img.ColorRgba8(
          blend(sr, d.r.toInt()),
          blend(sg, d.g.toInt()),
          blend(sb, d.b.toInt()),
          0xFF,
        ),
      );
    }
  }
}

bool _insideRoundedRect(int x, int y) {
  final r = cornerRadius;
  final rightEdge = size - r;
  final bottomEdge = size - r;
  if (x < r && y < r) {
    if ((x - r) * (x - r) + (y - r) * (y - r) > r * r) return false;
  } else if (x > rightEdge && y < r) {
    if ((x - rightEdge) * (x - rightEdge) + (y - r) * (y - r) > r * r) return false;
  } else if (x < r && y > bottomEdge) {
    if ((x - r) * (x - r) + (y - bottomEdge) * (y - bottomEdge) > r * r) return false;
  } else if (x > rightEdge && y > bottomEdge) {
    if ((x - rightEdge) * (x - rightEdge) + (y - bottomEdge) * (y - bottomEdge) > r * r) return false;
  }
  return true;
}
