import 'package:flutter/material.dart';

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
        child: Image.network(
          url,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _fallback(context),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
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
    final style = textStyle ??
        TextStyle(
          color: fg,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.75,
        );

    return CircleAvatar(
      radius: radius,
      backgroundColor: bg,
      child: Text(initials, style: style),
    );
  }
}
