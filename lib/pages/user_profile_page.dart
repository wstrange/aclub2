import 'package:aclub2/repo.dart';
import 'package:bloc_signals_flutter/bloc_signals_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:kaisel/kaisel.dart';

import '../models/models.dart';
import '../routes.dart';

sealed class UserProfileFormState {
  const UserProfileFormState();
}

class UserFormInitial extends UserProfileFormState {
  const UserFormInitial();
}

class UserFormSaving extends UserProfileFormState {
  const UserFormSaving();
}

class UserFormSuccess extends UserProfileFormState {
  const UserFormSuccess(this.user);

  final UserProfile user;
}

class UserFormError extends UserProfileFormState {
  const UserFormError(this.message);

  final String message;
}

/// Saves edits to the [user] and Firebase Auth [authUser] supplied by the caller.
class UserProfileCubit extends CubitSignal<UserProfileFormState> {
  UserProfileCubit(this.user, [this.authUser]) : super(initialState: const UserFormInitial());

  UserProfile user;
  User? authUser;

  Future<void> updateUserProfile(UserProfile updatedUser, {String? displayName, String? email}) async {
    emit(const UserFormSaving());
    try {
      final currentAuthUser = authUser ?? FirebaseAuth.instance.currentUser;
      if (currentAuthUser != null) {
        final trimmedDisplayName = displayName?.trim();
        if (trimmedDisplayName != null && trimmedDisplayName != currentAuthUser.displayName) {
          await currentAuthUser.updateDisplayName(trimmedDisplayName.isEmpty ? null : trimmedDisplayName);
        }
        final trimmedEmail = email?.trim();
        if (trimmedEmail != null && trimmedEmail.isNotEmpty && trimmedEmail != currentAuthUser.email) {
          await currentAuthUser.verifyBeforeUpdateEmail(trimmedEmail);
        }
        await currentAuthUser.reload();
        authUser = FirebaseAuth.instance.currentUser;
      }
      await repository.updateUserProfile(updatedUser);
      user = updatedUser;
      emit(UserFormSuccess(updatedUser));
    } on FirebaseAuthException catch (e) {
      emit(UserFormError(e.message ?? e.code));
    } catch (e) {
      emit(UserFormError(e.toString()));
    }
  }
}

/// Loads the signed-in member's profile, then passes that model to the editor.
class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authUser = FirebaseAuth.instance.currentUser;
    if (authUser == null) {
      return const Scaffold(body: Center(child: Text('Sign in to edit your profile.')));
    }

    return FutureBuilder<UserProfile?>(
      future: repository.getUserProfile(authUser.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text('Could not load profile: ${snapshot.error}')));
        }
        final user = snapshot.data;
        if (user == null) {
          return const Scaffold(body: Center(child: Text('Profile not found.')));
        }

        return BlocSignalProvider<UserProfileCubit>(
          create: (_) => UserProfileCubit(user, authUser),
          child: _UserProfileForm(user: user, authUser: authUser),
        );
      },
    );
  }
}

class _UserProfileForm extends HookWidget {
  const _UserProfileForm({required this.user, this.authUser});

  final UserProfile user;
  final User? authUser;

  @override
  Widget build(BuildContext context) {
    final currentAuthUser = authUser ?? FirebaseAuth.instance.currentUser;
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final displayName = useTextEditingController(text: currentAuthUser?.displayName ?? '');
    final phoneAuth = useTextEditingController(text: currentAuthUser?.phoneNumber ?? '');
    final email = useTextEditingController(text: currentAuthUser?.email ?? '');
    final firstName = useTextEditingController(text: user.firstName);
    final lastName = useTextEditingController(text: user.lastName);
    final phone = useTextEditingController(text: user.phone ?? '');
    final emergencyName = useTextEditingController(text: user.emergencyContactName);
    final emergencyPhone = useTextEditingController(text: user.emergencyContactPhone);
    final emergencyRelation = useTextEditingController(text: user.emergencyContactRelation ?? '');
    final medicalConditions = useTextEditingController(text: user.medicalConditions ?? '');
    final certifications = useTextEditingController(text: user.certifications.join(', '));
    final sectionIds = useTextEditingController(text: user.sectionIds.join(', '));
    final isAdmin = useState(user.isAdmin);
    final completedProfile = useState(user.complatedProfile);
    final signedWaiver = useState(user.signedWaiver);
    final pushEnabled = useState(user.notificationPreferences.pushEnabled);
    final emailEnabled = useState(user.notificationPreferences.emailEnabled);
    final inAppEnabled = useState(user.notificationPreferences.inAppEnabled);
    final frequency = useState(user.notificationPreferences.frequency);

    List<String> splitList(String value) =>
        value.split(',').map((item) => item.trim()).where((item) => item.isNotEmpty).toList();

    Future<void> submit() async {
      if (!(formKey.currentState?.validate() ?? false)) return;

      final updatedUser = user.copyWith(
        firstName: firstName.text.trim(),
        lastName: lastName.text.trim(),
        phone: _emptyToNull(phone.text),
        emergencyContactName: emergencyName.text.trim(),
        emergencyContactPhone: emergencyPhone.text.trim(),
        emergencyContactRelation: _emptyToNull(emergencyRelation.text),
        medicalConditions: _emptyToNull(medicalConditions.text),
        certifications: splitList(certifications.text),
        sectionIds: splitList(sectionIds.text),
        isAdmin: isAdmin.value,
        complatedProfile: completedProfile.value,
        signedWaiver: signedWaiver.value,
        notificationPreferences: user.notificationPreferences.copyWith(
          pushEnabled: pushEnabled.value,
          emailEnabled: emailEnabled.value,
          inAppEnabled: inAppEnabled.value,
          frequency: frequency.value,
        ),
        updatedAt: DateTime.now(),
      );

      await context.read<UserProfileCubit>().updateUserProfile(
        updatedUser,
        displayName: displayName.text,
        email: email.text,
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('User profile')),
      body: SafeArea(
        child: Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _readOnlyField('User ID', user.id),
              _readOnlyField('Created', user.createdAt.toLocal().toIso8601String()),
              _readOnlyField('Last updated', user.updatedAt.toLocal().toIso8601String()),
              _sectionTitle('Account'),
              TextFormField(
                controller: displayName,
                decoration: const InputDecoration(labelText: 'Display name'),
              ),
              TextFormField(
                controller: email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  helperText: 'Changing email may require verification',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter an email';
                  }
                  if (!value.contains('@')) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              // This triggers a Firebase authentication phone number update. Best to leave?
              // TextFormField(
              //   controller: phoneAuth,
              //   keyboardType: TextInputType.phone,
              //   autovalidateMode: AutovalidateMode.onUserInteraction, // Validates while typing

              //   decoration: const InputDecoration(labelText: 'Phone (Authentication)'),
              //   validator: phoneValidator,
              // ),
              _sectionTitle('Personal information'),
              _requiredField(controller: firstName, label: 'First name'),
              _requiredField(controller: lastName, label: 'Last name'),
              TextFormField(
                controller: phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone'),
                validator: phoneValidator,
                autovalidateMode: AutovalidateMode.onUserInteraction, // Validates while typing
              ),
              _sectionTitle('Emergency contact'),
              _requiredField(controller: emergencyName, label: 'Name'),
              _requiredField(controller: emergencyPhone, label: 'Phone', keyboardType: TextInputType.phone),
              TextFormField(
                controller: emergencyRelation,
                decoration: const InputDecoration(labelText: 'Relationship'),
              ),
              _sectionTitle('Health and memberships'),
              TextFormField(
                controller: medicalConditions,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Medical conditions'),
              ),
              TextFormField(
                controller: certifications,
                decoration: const InputDecoration(labelText: 'Certifications (comma-separated)'),
              ),

              _sectionTitle('Status (Remove latet)'),
              SwitchListTile(
                value: isAdmin.value,
                onChanged: (value) => isAdmin.value = value,
                title: const Text('Administrator'),
              ),
              SwitchListTile(
                value: completedProfile.value,
                onChanged: (value) => completedProfile.value = value,
                title: const Text('Profile completed'),
              ),
              SwitchListTile(
                value: signedWaiver.value,
                onChanged: (value) => signedWaiver.value = value,
                title: const Text('Waiver signed'),
              ),
              _sectionTitle('Notification preferences'),
              SwitchListTile(
                value: pushEnabled.value,
                onChanged: (value) => pushEnabled.value = value,
                title: const Text('Push notifications'),
              ),
              SwitchListTile(
                value: emailEnabled.value,
                onChanged: (value) => emailEnabled.value = value,
                title: const Text('Email notifications'),
              ),
              SwitchListTile(
                value: inAppEnabled.value,
                onChanged: (value) => inAppEnabled.value = value,
                title: const Text('In-app notifications'),
              ),
              DropdownButtonFormField<NotificationFrequency>(
                initialValue: frequency.value,
                decoration: const InputDecoration(labelText: 'Notification frequency'),
                items: NotificationFrequency.values
                    .map((value) => DropdownMenuItem(value: value, child: Text(value.name)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) frequency.value = value;
                },
              ),
              const SizedBox(height: 24),
              BlocSignalConsumer<UserProfileCubit, UserProfileFormState>(
                listenWhen: (previous, current) => current is UserFormSuccess,
                listener: (context, state) async {
                  if (state is UserFormSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile saved.')));
                    final popped = await context.pop();
                    if (!popped && context.mounted) {
                      context.replaceTop(const HomeRoute());
                    }
                  }
                },
                builder: (context, state) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (state is UserFormError)
                      Text(state.message, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                    ElevatedButton(
                      onPressed: state is UserFormSaving ? null : submit,
                      child: state is UserFormSaving ? const CircularProgressIndicator() : const Text('Save profile'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _readOnlyField(String label, String value) => TextFormField(
    initialValue: value,
    readOnly: true,
    decoration: InputDecoration(labelText: label),
  );

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(top: 24, bottom: 8),
    child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
  );

  Widget _requiredField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
  }) => TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    decoration: InputDecoration(labelText: label),
    validator: (value) => value == null || value.trim().isEmpty ? 'Enter $label' : null,
  );

  String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

// RegEx for a standard 10-digit phone number (adjust pattern to your needs)
final phoneRegex = RegExp(r'^\d{3}-?\d{3}-?\d{4}$');

String? phoneValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Enter a phone number';
  }

  if (!phoneRegex.hasMatch(value)) {
    return 'Please enter a valid 10-digit phone number';
  }
  return null;
}
