// Floating snackbars with padded, selectable text. Selectability matters for
// error copy (Firestore exceptions include codes/details worth copying into a
// bug report), and floating behavior keeps long messages off the system
// gesture/edge areas.
import 'package:flutter/material.dart';

/// Shows a floating snackbar with padded, selectable [message] text.
void showFloatingSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      content: Padding(padding: const EdgeInsets.symmetric(vertical: 14), child: SelectableText(message)),
    ),
  );
}

/// Shows a floating error snackbar with a [title] and the raw failure text on
/// subsequent lines so users can still select and copy the underlying error
/// (code + message) for triage.
void showErrorSnackBar(BuildContext context, {required String message, required Object error}) {
  showFloatingSnackBar(context, '$message\n\n$error');
}
