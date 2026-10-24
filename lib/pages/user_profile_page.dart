import 'package:aclub2/repo.dart';
import 'package:bloc_signals_flutter/bloc_signals_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:kaisel/kaisel.dart';
import 'package:shared_models/shared_models.dart';

import '../routes.dart';
import '../state/user_state_cubit.dart';
import '../utils/phone_formatter.dart';
import '../widgets/user_avatar.dart';

sealed class const UserProfileFormState();

class const UserFormInitial() extends UserProfileFormState;

class const UserFormSaving() extends UserProfileFormState;

class const UserFormSuccess(this.user) extends UserProfileFormState {
  final UserProfile user;
}

class const UserFormError(this.message) extends UserProfileFormState {
  final String message;
}

/// Saves edits to the [user] and Firebase Auth [authUser] supplied by the caller.
class UserProfileCubit(this.user, [this.authUser]) extends CubitSignal<UserProfileFormState> {
  this : super(initialState: const UserFormInitial());

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
      // Mirror the auth email and photoURL into the profile so other clients can display it.
      final withSyncedAuth = updatedUser.copyWith(
        email: authUser?.email,
        photoUrl: updatedUser.photoUrl ?? authUser?.photoURL,
      );
      await repository.updateUserProfile(withSyncedAuth);
      user = withSyncedAuth;
      // Merge the saved profile into app state without a network reload (see
      // UserStateCubit.applyProfile for why).
      userStateCubit.applyProfile(withSyncedAuth);
      emit(UserFormSuccess(withSyncedAuth));
    } on FirebaseAuthException catch (e) {
      emit(UserFormError(e.message ?? e.code));
    } catch (e) {
      emit(UserFormError(e.toString()));
    }
  }
}

/// Loads the signed-in member's profile, then passes that model to the editor.
class const UserProfilePage({super.key}) extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final authUser = FirebaseAuth.instance.currentUser;
    if (authUser == null) {
      return const Scaffold(body: Center(child: Text('Sign in to edit your profile.')));
    }

    final profileFuture = useMemoized(() => repository.getUserProfile(authUser.uid, reload: true), [authUser.uid]);
    final snapshot = useFuture(profileFuture);

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
  }
}

class const _UserProfileForm({required this.user, this.authUser}) extends HookWidget {
  final UserProfile user;
  final User? authUser;

  @override
  Widget build(BuildContext context) {
    final currentAuthUser = authUser ?? FirebaseAuth.instance.currentUser;
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final displayName = useTextEditingController(text: currentAuthUser?.displayName ?? '');
    // final phoneAuth = useTextEditingController(text: currentAuthUser?.phoneNumber ?? '');
    final email = useTextEditingController(text: currentAuthUser?.email ?? '');
    final firstName = useTextEditingController(text: user.firstName);
    final lastName = useTextEditingController(text: user.lastName);
    final phone = useTextEditingController(text: formatPhoneNumber(user.phone));
    final emergencyName = useTextEditingController(text: user.emergencyContactName);
    final emergencyPhone = useTextEditingController(text: formatPhoneNumber(user.emergencyContactPhone));
    final emergencyRelation = useTextEditingController(text: user.emergencyContactRelation ?? '');
    final medicalConditions = useTextEditingController(text: user.medicalConditions ?? '');
    final certifications = useTextEditingController(text: user.certifications.join(', '));
    final completedProfile = useState(user.complatedProfile);
    final pushEnabled = useState(user.notificationPreferences.pushEnabled);
    final emailEnabled = useState(user.notificationPreferences.emailEnabled);
    final inAppEnabled = useState(user.notificationPreferences.inAppEnabled);
    final notifyForNewEvents = useState(user.notificationPreferences.notifyForNewEvents);
    final frequency = useState(user.notificationPreferences.frequency);
    final submitted = useState(false);

    List<String> splitList(String value) =>
        value.split(',').map((item) => item.trim()).where((item) => item.isNotEmpty).toList();

    Future<void> submit() async {
      submitted.value = true;
      if (!(formKey.currentState?.validate() ?? false)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              content: Text('Fix the highlighted errors before saving.'),
            ),
          );
        }
        return;
      }

      completedProfile.value = true;
      final updatedUser = user.copyWith(
        firstName: firstName.text.trim(),
        lastName: lastName.text.trim(),
        phone: _emptyToNull(phone.text),
        emergencyContactName: emergencyName.text.trim(),
        emergencyContactPhone: emergencyPhone.text.trim(),
        emergencyContactRelation: _emptyToNull(emergencyRelation.text),
        medicalConditions: _emptyToNull(medicalConditions.text),
        certifications: splitList(certifications.text),
        complatedProfile: true,
        notificationPreferences: user.notificationPreferences.copyWith(
          pushEnabled: pushEnabled.value,
          emailEnabled: emailEnabled.value,
          inAppEnabled: inAppEnabled.value,
          notifyForNewEvents: notifyForNewEvents.value,
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
          autovalidateMode: submitted.value ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
          child: ListView(
            // Generous bottom padding so the Save button isn't flush against
            // the screen edge / system navbar, and snackbar overlays have a
            // visible separation from the form content.
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 56),
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: UserAvatar(
                    photoUrl: user.photoUrl ?? currentAuthUser?.photoURL,
                    initials: (user.firstName.isNotEmpty && user.lastName.isNotEmpty)
                        ? '${user.firstName[0]}${user.lastName[0]}'.toUpperCase()
                        : (displayName.text.trim().isNotEmpty ? displayName.text.trim()[0].toUpperCase() : '?'),
                    radius: 44,
                    textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                  ),
                ),
              ),
              _sectionTitle('Account'),
              TextFormField(
                controller: displayName,
                decoration: const InputDecoration(labelText: 'Display name'),
                validator: (value) => value == null || value.trim().isEmpty ? 'Enter a display name' : null,
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
                inputFormatters: const [PhoneNumberFormatter()],
                decoration: const InputDecoration(
                  labelText: 'Mobile phone',
                  hintText: '403-555-0123',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: (value) => phoneValidator(value, label: 'mobile phone number'),
              ),
              _sectionTitle('Emergency contact'),
              _requiredField(controller: emergencyName, label: 'Name'),
              TextFormField(
                controller: emergencyPhone,
                keyboardType: TextInputType.phone,
                inputFormatters: const [PhoneNumberFormatter()],
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  hintText: '403-555-0123',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: (value) => phoneValidator(value, label: 'emergency phone number'),
              ),
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
                value: completedProfile.value,
                onChanged: (value) => completedProfile.value = value,
                title: const Text('Profile completed'),
              ),
              ListTile(
                title: const Text('Waiver signed'),
                subtitle: Text(
                  user.waiverSignedDate != null ? 'Signed on ${_formatDate(user.waiverSignedDate!)}' : 'Not yet signed',
                ),
                trailing: Icon(
                  user.waiverSignedDate != null ? Icons.check_circle : Icons.warning_amber,
                  color: user.waiverSignedDate != null ? Colors.green : Colors.orange,
                ),
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
              SwitchListTile(
                value: notifyForNewEvents.value,
                onChanged: (value) => notifyForNewEvents.value = value,
                title: const Text('Notify me of new events'),
                subtitle: const Text('Be notified when new events are added to your calendars'),
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        behavior: SnackBarBehavior.floating,
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        content: Text('Profile saved.'),
                      ),
                    );
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

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }
}
