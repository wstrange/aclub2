import 'package:flutter/material.dart';

import '../utils/external_url.dart';

/// Renders [text] as a hyperlink that opens [url] in the platform browser.
///
/// Used for event map links, where the leader-entered description doubles as
/// the tappable label ("Meet at the Canmore Nordic Centre").
class const ExternalLink({super.key, required this.text, required this.url, this.style}) extends StatelessWidget {
  final String text;
  final String url;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    final linkStyle = (style ?? const TextStyle(fontSize: 14)).copyWith(
      color: color,
      decoration: TextDecoration.underline,
      decorationColor: color.withValues(alpha: 0.5),
    );

    return Semantics(
      link: true,
      child: InkWell(
        onTap: () => _open(context),
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(child: Text(text, style: linkStyle)),
              const SizedBox(width: 4),
              Icon(Icons.open_in_new, size: 14, color: color),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _open(BuildContext context) async {
    // Capture before the await so the snackbar still works if the route is
    // rebuilt while the browser is opening.
    final messenger = ScaffoldMessenger.maybeOf(context);
    final opened = await openExternalUrl(url);
    if (!opened) {
      messenger?.showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          content: Text("Couldn't open that link in a browser."),
        ),
      );
    }
  }
}
