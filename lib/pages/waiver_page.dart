import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

import '../repo.dart';
import '../routes.dart';

/// Displays the Club liability waiver (loaded from [assets/waiver.md]) and
/// requires the user to accept before proceeding.
///
/// * **I Accept** — records [waiverSignedDate] on the user's Firestore profile
///   and re-evaluates the router guard, which will then route to [HomeRoute].
/// * **Decline** — signs the user out. The auth-state listener in [main.dart]
///   clears [userStateCubit] and re-evaluates the router, landing on [SignInRoute].
class WaiverPage extends StatefulWidget {
  const WaiverPage({super.key});

  @override
  State<WaiverPage> createState() => _WaiverPageState();
}

class _WaiverPageState extends State<WaiverPage> {
  String? _waiverText;
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadWaiver();
  }

  Future<void> _loadWaiver() async {
    try {
      final text = await rootBundle.loadString('assets/waiver.md');
      if (mounted) setState(() { _waiverText = text; _loading = false; });
    } catch (e) {
      if (mounted) {
        setState(() { _error = 'Failed to load waiver: $e'; _loading = false; });
      }
    }
  }

  Future<void> _accept() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    setState(() => _saving = true);
    try {
      await repository.updateWaiverSignedDate(uid);
      if (mounted) {
        // Re-run the guard; waiver is now current so it will pass through to Home.
        await routerConfig.router.reevaluate();
      }
    } catch (e) {
      if (mounted) {
        setState(() { _saving = false; _error = 'Could not save waiver acceptance: $e'; });
      }
    }
  }

  Future<void> _decline() async {
    // Sign out. The authStateChanges listener in main.dart clears state and
    // reevaluates the router → SignInRoute.
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liability Waiver'),
        automaticallyImplyLeading: false, // no back button — must accept or decline
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(_error!, style: theme.textTheme.bodyMedium),
                  ),
                )
              : Column(
                  children: [
                    // ── Expiry notice ─────────────────────────────────────
                    Container(
                      width: double.infinity,
                      color: theme.colorScheme.primaryContainer,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Text(
                        'Please read and accept the waiver below to continue. '
                        'This waiver must be renewed annually.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),

                    // ── Scrollable waiver body ─────────────────────────────
                    Expanded(
                      child: Markdown(
                        data: _waiverText ?? '',
                        padding: const EdgeInsets.all(16),
                      ),
                    ),

                    // ── Divider + action buttons ───────────────────────────
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          // Decline
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _saving ? null : _decline,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: theme.colorScheme.error,
                                side: BorderSide(color: theme.colorScheme.error),
                              ),
                              child: const Text('Decline'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Accept
                          Expanded(
                            child: FilledButton(
                              onPressed: _saving ? null : _accept,
                              child: _saving
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('I Accept'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
