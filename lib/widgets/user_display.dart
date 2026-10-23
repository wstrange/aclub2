import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shared_models/shared_models.dart';

import '../repo.dart';
import 'user_avatar.dart';

/// Resolves a Firebase UID into a display name / email, using the user's
/// stored [UserProfile] and falling back to the signed-in user's Auth
/// display name / email.
String resolveUserDisplay(String uid, UserProfile? profile) {
  String? name;
  String? email;
  if (profile != null) {
    final n = [profile.firstName, profile.lastName].where((s) => s.isNotEmpty).join(' ').trim();
    if (n.isNotEmpty) name = n;
    if (profile.email != null && profile.email!.isNotEmpty) email = profile.email;
  }
  if (name == null && email == null) {
    final auth = FirebaseAuth.instance.currentUser;
    if (auth != null && auth.uid == uid) {
      if (auth.displayName != null && auth.displayName!.trim().isNotEmpty) name = auth.displayName!.trim();
      if (auth.email != null && auth.email!.isNotEmpty) email = auth.email;
    }
  }
  if (name == null && email == null) return 'Unknown user';
  if (name != null && email != null) return '$name ($email)';
  return name ?? email!;
}

/// Resolves a user ID and renders the user's display name / email as text.
class const UserDisplay({super.key, required this.userId, this.style}) extends HookWidget {
  final String userId;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final profileFuture = useMemoized(() => repository.getUserProfile(userId), [userId]);
    final snapshot = useFuture(profileFuture);

    final profile = snapshot.hasData ? snapshot.data : null;
    return Text(profile == null ? '…' : resolveUserDisplay(userId, profile), style: style);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// UserChip — tappable / hoverable user name with a contact-detail popover
// ─────────────────────────────────────────────────────────────────────────────

/// A reusable widget that renders a user's display name as an interactive
/// [InkWell]. Tapping (or hovering on desktop/web) opens a small popover card
/// showing the user's full name, email address, and phone number.
///
/// Usage — drop-in replacement wherever you previously used [UserDisplay] but
/// want the contact-detail popover behaviour:
///
/// ```dart
/// UserChip(userId: event.creatorId)
/// UserChip(userId: leaderId, style: TextStyle(fontSize: 14))
/// ```
///
/// The popover is anchored to the widget using a [MenuAnchor] / overlay so it
/// works correctly inside scrollable lists. On mobile the popover opens on tap;
/// on desktop/web it also opens on hover.
class const UserChip({super.key, required this.userId, this.style}) extends HookWidget {
  final String userId;

  /// Optional [TextStyle] applied to the name label (same API as [UserDisplay]).
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final profileFuture = useMemoized(() => repository.getUserProfile(userId), [userId]);
    final snapshot = useFuture(profileFuture);

    // Distinguish between "still loading" and "loaded but no document found".
    final isDone = snapshot.connectionState == ConnectionState.done;
    final profile = snapshot.data; // null while loading OR when no document exists

    final displayName = switch ((isDone, profile)) {
      (false, _) => '…', // still fetching
      (true, null) => 'Unknown user', // fetch complete, no profile document
      (true, final p?) => resolveUserDisplay(userId, p), // profile found
    };

    // Don't allow the popover to open while still fetching — the card body
    // will just spin. Once done, always show the popover (even for missing
    // profiles, so the user sees "Unknown user" rather than a stuck spinner).
    final canShowPopover = isDone;

    final menuController = useMemoized(MenuController.new);
    final isHovered = useState(false);

    void openMenu() {
      if (canShowPopover && !menuController.isOpen) menuController.open();
    }

    void closeMenu() {
      if (menuController.isOpen) menuController.close();
    }

    return MenuAnchor(
      controller: menuController,
      // Align the popover below-left of the tapped text.
      alignmentOffset: const Offset(0, 4),
      style: MenuStyle(
        padding: const WidgetStatePropertyAll(EdgeInsets.zero),
        elevation: const WidgetStatePropertyAll(4),
        shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      ),
      menuChildren: [_UserPopoverCard(userId: userId, profile: profile, isDone: isDone)],
      child: MouseRegion(
        cursor: canShowPopover ? SystemMouseCursors.click : MouseCursor.defer,
        onEnter: (_) {
          isHovered.value = true;
          openMenu();
        },
        onExit: (_) {
          isHovered.value = false;
          // Let the menu stay open a moment so the user can move to it.
          // The MenuAnchor handles focus loss on its own.
        },
        child: GestureDetector(
          onTap: () {
            if (!canShowPopover) return;
            if (menuController.isOpen) {
              closeMenu();
            } else {
              openMenu();
            }
          },
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 150),
            style: (style ?? DefaultTextStyle.of(context).style).copyWith(
              color: isHovered.value && canShowPopover
                  ? Theme.of(context).colorScheme.primary
                  : (style?.color ?? DefaultTextStyle.of(context).style.color),
              decoration: isHovered.value && canShowPopover ? TextDecoration.underline : TextDecoration.none,
            ),
            child: Text(displayName),
          ),
        ),
      ),
    );
  }
}

/// The card body shown inside the [UserChip] popover.
class const _UserPopoverCard({required this.userId, this.profile, required this.isDone}) extends StatelessWidget {
  final String userId;
  final UserProfile? profile;

  /// Whether the profile fetch has completed. When false the card shows a
  /// loading spinner; when true but [profile] is null it shows a "no profile"
  /// message instead of a stuck spinner.
  final bool isDone;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final firstName = profile?.firstName ?? '';
    final lastName = profile?.lastName ?? '';
    final fullName = [firstName, lastName].where((s) => s.isNotEmpty).join(' ').trim();
    final email = profile?.email;
    final phone = profile?.phone;

    // Build initials for the avatar (up to 2 chars).
    String initials() {
      if (firstName.isNotEmpty && lastName.isNotEmpty) {
        return '${firstName[0]}${lastName[0]}'.toUpperCase();
      } else if (fullName.isNotEmpty) {
        return fullName[0].toUpperCase();
      } else if (email != null && email.isNotEmpty) {
        return email[0].toUpperCase();
      }
      return '?';
    }

    Widget infoRow(IconData icon, String? value) {
      if (value == null || value.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 15, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Flexible(
              child: Text(value, style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface)),
            ),
          ],
        ),
      );
    }

    Widget body;
    if (!isDone) {
      // Still fetching — show a spinner.
      body = const SizedBox(
        height: 48,
        child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
      );
    } else if (profile == null) {
      // Fetch finished but no profile document exists (e.g. system-created events).
      body = Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: colorScheme.surfaceContainerHighest,
            child: Icon(Icons.person_off_outlined, size: 18, color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(width: 10),
          Text(
            'No profile found',
            style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ],
      );
    } else {
      // Profile loaded successfully.
      body = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              UserAvatar(
                photoUrl: profile?.photoUrl,
                initials: initials(),
                radius: 20,
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  fullName.isNotEmpty ? fullName : (email ?? 'Unknown user'),
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (email != null || phone != null) ...[
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),
            infoRow(Icons.email_outlined, email),
            infoRow(Icons.phone_outlined, phone),
          ],
        ],
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 200, maxWidth: 280),
      child: Padding(padding: const EdgeInsets.all(14), child: body),
    );
  }
}
