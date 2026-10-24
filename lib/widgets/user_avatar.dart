import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../utils/avatar_cache.dart';

/// A circular user avatar that displays a remote profile image if [photoUrl]
/// is available, falling back to [initials] rendered on a colored background
/// if the photo is missing, loading, or fails to load.
class const UserAvatar({
  super.key,
  this.photoUrl,
  required this.initials,
  this.radius = 20,
  this.backgroundColor,
  this.foregroundColor,
  this.textStyle,
}) extends StatelessWidget {
  final String? photoUrl;
  final String initials;
  final double radius;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final url = photoUrl?.trim();
    if (url != null && url.isNotEmpty) {
      return ClipOval(
        child: CachedNetworkImage(
          // Disk-backed, throttled cache: see utils/avatar_cache.dart for the
          // rate-limit rationale (Google avatar CDN → HTTP 429 on bursts).
          cacheManager: avatarCacheManager,
          imageUrl: url,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          // Show the initials fallback while loading, matching the old
          // loadingBuilder behaviour.
          placeholder: (context, _) => _fallback(context),
          errorWidget: (context, url, error) {
            if (kDebugMode) {
              debugPrint('UserAvatar: image load failed (url=$url): $error');
            }
            return _fallback(context);
          },
        ),
      );
    }
    return _fallback(context);
  }

  Widget _fallback(BuildContext context) {
    final theme = Theme.of(context);
    final bg = backgroundColor ?? theme.colorScheme.primaryContainer;
    final fg = foregroundColor ?? theme.colorScheme.onPrimaryContainer;
    final style = textStyle ?? TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: radius * 0.75);

    return CircleAvatar(
      radius: radius,
      backgroundColor: bg,
      child: Text(initials, style: style),
    );
  }
}
