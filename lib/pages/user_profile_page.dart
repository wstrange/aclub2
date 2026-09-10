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

class UserModelCubit extends CubitSignal<UserFormState> {
  final AlpineRepository repository;

  UserModelCubit(this.repository) : super(initialState: const UserFormInitial());

  Future<void> createUser({required UserProfile user}) async {
    emit(const UserFormSaving());

    try {
      await repository.createUser(user);

      emit(const UserFormSuccess());
    } catch (e) {
      emit(UserFormError(e.toString()));
    }
  }
}

class UserProfilePage extends HookWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final emergencyContactNameController = useTextEditingController();
    final emergencyContactPhoneController = useTextEditingController();
    final phoneController = useTextEditingController();
    final firstNameController = useTextEditingController();
    final lastNameController = useTextEditingController();

    void submit() async {
      if (!formKey.currentState!.validate()) {
        return;
      }

      final user = UserProfile(
        id: '1234',
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        emergencyContactName: emergencyContactNameController.text.trim(),
        emergencyContactPhone: emergencyContactPhoneController.text.trim(),
        phone: phoneController.text.trim(),
        notificationPreferences: NotificationPreferences(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      try {
        await context.read<UserModelCubit>().createUser(user: user);
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
                controller: firstNameController,
                decoration: const InputDecoration(labelText: 'First Name'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter a name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: lastNameController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(labelText: 'Last Name'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter a last name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              BlocSignalBuilder<UserModelCubit, UserFormState>(
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
