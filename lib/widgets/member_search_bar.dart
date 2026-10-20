import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// A reusable search bar intended for member/user picker lists.
///
/// Renders a [TextField] with a search prefix icon and a clear button. The
/// [onChanged] callback fires on every keystroke so the caller can filter its
/// list reactively.
///
/// Example:
/// ```dart
/// MemberSearchBar(
///   hintText: 'Search by name or email',
///   onChanged: (q) => query.value = q,
/// )
/// ```
class MemberSearchBar extends HookWidget {
  const MemberSearchBar({
    super.key,
    this.hintText = 'Search',
    this.onChanged,
    this.autofocus = false,
  });

  final String hintText;
  final ValueChanged<String>? onChanged;

  /// Whether to focus the field automatically when it first appears.
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController();
    final isEmpty = useState(true);

    useEffect(() {
      void listener() {
        isEmpty.value = controller.text.isEmpty;
        onChanged?.call(controller.text);
      }

      controller.addListener(listener);
      return () => controller.removeListener(listener);
    }, [controller]);

    return TextField(
      controller: controller,
      autofocus: autofocus,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search),
        hintText: hintText,
        isDense: true,
        suffixIcon: isEmpty.value
            ? null
            : IconButton(
                icon: const Icon(Icons.clear),
                tooltip: 'Clear',
                onPressed: () {
                  controller.clear();
                  // listener fires automatically via addListener above.
                },
              ),
      ),
    );
  }
}
