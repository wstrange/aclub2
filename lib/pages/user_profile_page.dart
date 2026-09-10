import 'package:aclub2/repo.dart';
import 'package:bloc_signals_flutter/bloc_signals_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../models/models.dart';

sealed class UserFormState {
  const UserFormState();
}

class UserFormInitial extends UserFormState {
  const UserFormInitial();
}

class UserFormSaving extends UserFormState {
  const UserFormSaving();
}

class UserFormSuccess extends UserFormState {
  const UserFormSuccess();
}

class UserFormError extends UserFormState {
  final String message;

  const UserFormError(this.message);
}

class UserCubit extends CubitSignal<UserFormState> {
  final AlpineRepository repository;

  UserCubit(this.repository) : super(initialState: const UserFormInitial());

  Future<void> createUser({required UserModel user}) async {
    emit(const UserFormSaving());

    try {
      await repository.createUser(user);

      emit(const UserFormSuccess());
    } catch (e) {
      emit(UserFormError(e.toString()));
    }
  }
}

class CreateUserPage extends HookWidget {
  const CreateUserPage({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = useMemoized(() => GlobalKey<FormState>());

    final nameController = useTextEditingController();
    final emailController = useTextEditingController();
    final emergencyContactNameController = useTextEditingController();
    final emergencyContactPhoneController = useTextEditingController();
    final phoneController = useTextEditingController();
    final firstNameController = useTextEditingController();
    final lastNameController = useTextEditingController();
    // final addressController = useTextEditingController();
    // final cityController = useTextEditingController();
    // final provinceController = useTextEditingController();
    // final postalCodeController = useTextEditingController();
    // final countryController = useTextEditingController();
    // final dateOfBirthController = useTextEditingController();
    // final genderController = useTextEditingController();
    // final profilePictureController = useTextEditingController();
    // final bioController = useTextEditingController();
    // final websiteController = useTextEditingController();
    // final facebookController = useTextEditingController();
    // final twitterController = useTextEditingController();
    // final instagramController = useTextEditingController();
    // final linkedinController = useTextEditingController();

    void submit() async {
      if (!formKey.currentState!.validate()) {
        return;
      }

      final user = UserModel(
        displayName: nameController.text.trim(),
        email: emailController.text.trim(),
        id: '1234',
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        emergencyContactName: emergencyContactNameController.text.trim(),
        emergencyContactPhone: emergencyContactPhoneController.text.trim(),
        phone: phoneController.text.trim(),
        // notificationPreferences: NotificationPreferences(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      try {
        await context.read<UserCubit>().createUser(user: user);
      } catch (e) {
        print(e);
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Create User')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter a name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter an email';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              BlocSignalBuilder<UserCubit, UserFormState>(
                builder: (context, state) {
                  final isSaving = state is UserFormSaving;

                  return ElevatedButton(
                    onPressed: isSaving ? null : submit,
                    child: isSaving ? const CircularProgressIndicator() : const Text('Create User'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
