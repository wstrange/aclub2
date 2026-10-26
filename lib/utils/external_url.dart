import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Parses a user-entered link (e.g. an event's map URL).
///
/// Leaders type these into a free-text field, so they often arrive without a
/// scheme ("maps.google.com/?q=..."). Anything without one is treated as
/// `https://`. Returns `null` when [raw] is empty or cannot be parsed.
Uri? parseExternalUrl(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return null;

  final parsed = Uri.tryParse(trimmed);
  if (parsed != null && parsed.hasScheme) {
    // "https://" alone parses but has nowhere to go.
    if ((parsed.scheme == 'http' || parsed.scheme == 'https') && parsed.host.isEmpty) return null;
    return parsed;
  }

  final withHttps = Uri.tryParse('https://$trimmed');
  return withHttps != null && withHttps.host.isNotEmpty ? withHttps : null;
}

/// Opens [url] in the platform browser (or whichever app handles its scheme).
/// Returns `false` when the URL is unusable or nothing could be launched.
Future<bool> openExternalUrl(String url) async {
  final uri = parseExternalUrl(url);
  if (uri == null) return false;

  try {
    // externalApplication keeps the trip page alive: the map opens in the
    // browser instead of an in-app webview.
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (e) {
    if (kDebugMode) debugPrint('openExternalUrl($uri) failed: $e');
    return false;
  }
}
