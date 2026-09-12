import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shared_models/shared_models.dart';

import '../repo.dart';

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
class UserDisplay extends HookWidget {
  const UserDisplay({super.key, required this.userId, this.style});

  final String userId;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final profileFuture = useMemoized(() => repository.getUserProfile(userId), [userId]);
    final snapshot = useFuture(profileFuture);

    final profile = snapshot.hasData ? snapshot.data : null;
    return Text(
      profile == null ? '…' : resolveUserDisplay(userId, profile),
      style: style,
    );
  }
}