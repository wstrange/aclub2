import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:kaisel/kaisel.dart';
import 'package:shared_models/shared_models.dart';

import '../repo.dart';
import '../routes.dart';
import '../state/user_state_cubit.dart';

class SectionSelectionPage extends StatelessWidget {
  const SectionSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Sign in to select sections.')));
    }

    return FutureBuilder<List<dynamic>>(
      future: Future.wait([repository.getSections(), repository.getUserProfile(user.uid)]),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text('Error loading sections: ${snapshot.error}')));
        }

        final sections = (snapshot.data?[0] as List<Section>?) ?? [];
        final profile = snapshot.data?[1] as UserProfile?;

        if (sections.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Select Sections')),
            body: const Center(child: Text('No sections available.')),
          );
        }

        return _SectionSelectionForm(
          userId: user.uid,
          sections: sections,
          initialSelected: profile?.sectionIds ?? const [],
        );
      },
    );
  }
}

class _SectionSelectionForm extends HookWidget {
  const _SectionSelectionForm({required this.userId, required this.sections, required this.initialSelected});

  final String userId;
  final List<Section> sections;
  final List<String> initialSelected;

  @override
  Widget build(BuildContext context) {
    final selectedIds = useState<Set<String>>(initialSelected.toSet());
    final isSaving = useState(false);
    final errorMessage = useState<String?>(null);

    Future<void> save() async {
      if (selectedIds.value.isEmpty) {
        errorMessage.value = 'Please select at least one section.';
        return;
      }

      errorMessage.value = null;
      isSaving.value = true;
      try {
        await repository.setUserSections(userId: userId, sectionIds: selectedIds.value.toList());
        await userStateCubit.refresh();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sections updated.')));
          final popped = await context.pop();
          if (!popped && context.mounted) {
            context.replaceTop(const HomeRoute());
          }
        }
      } catch (e) {
        if (context.mounted) {
          errorMessage.value = 'Failed to save sections: $e';
        }
      } finally {
        isSaving.value = false;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Sections'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              repository.clearProfileCache();
              userStateCubit.clear();
              if (context.mounted) context.replaceTop(const SignInRoute());
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Card(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Choose the sections you want to join. Members can belong to more than one section, and you can change your selection at any time.',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ),
            ),
            if (errorMessage.value != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  errorMessage.value!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.bold),
                ),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: sections.length,
                itemBuilder: (context, index) {
                  final section = sections[index];
                  final isChecked = selectedIds.value.contains(section.id);

                  return CheckboxListTile(
                    title: Text(section.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: section.description != null ? Text(section.description!) : null,
                    value: isChecked,
                    onChanged: isSaving.value
                        ? null
                        : (bool? value) {
                            final next = Set<String>.from(selectedIds.value);
                            if (value == true) {
                              next.add(section.id);
                            } else {
                              next.remove(section.id);
                            }
                            selectedIds.value = next;
                            if (next.isNotEmpty) {
                              errorMessage.value = null;
                            }
                          },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSaving.value ? null : save,
                  child: isSaving.value
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Save Sections'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
