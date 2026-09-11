import 'package:aclub2/admin/setup.dart';
import 'package:aclub2/state/user_state_cubit.dart';
import 'package:bloc_signals_flutter/bloc_signals_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kaisel/kaisel.dart';

import '../models/user_state.dart';
import '../repo.dart';
import '../routes.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocSignalBuilder<UserStateCubit, UserState?>(
          builder: (context, state) {
            if (state == null || state.userSections.isEmpty) {
              return const Text('Home');
            }

            final currentSectionId = state.currentSection.id;
            final isCurrentValid = state.userSections.any((s) => s.id == currentSectionId);

            return DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: isCurrentValid ? currentSectionId : state.userSections.first.id,
                icon: const Icon(Icons.arrow_drop_down),
                items: state.userSections
                    .map(
                      (section) => DropdownMenuItem<String>(
                        value: section.id,
                        child: Text(section.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    context.read<UserStateCubit>().setCurrentSectionById(value);
                  }
                },
              ),
            );
          },
        ),

        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
            onPressed: () async {
              repository.clearProfileCache();
              userStateCubit.clear();
              await FirebaseAuth.instance.signOut();
              if (context.mounted) context.replaceTop(const SignInRoute());
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          // Remove any padding from the ListView to ensure header fills the space
          padding: EdgeInsets.zero,
          children: [
            // 2. Add a Drawer Header (Standard or UserAccountsDrawerHeader)
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            // 3. Add individual navigation links using ListTile widgets
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                repository.clearProfileCache();
                userStateCubit.clear();
                await FirebaseAuth.instance.signOut();
                if (context.mounted) context.replaceTop(const SignInRoute());
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () async {
                await doAdminSetup();
                // Handle your navigation logic here (e.g., Navigator.push)
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('My Profile'),
              onTap: () async {
                context.push(const UserProfileRoute());
              },
            ),
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('My Sections'),
              onTap: () async {
                context.push(const SectionSelectionRoute());
              },
            ),
          ],
        ),
      ),
      body: BlocSignalBuilder<UserStateCubit, UserState?>(
        builder: (context, state) {
          if (state == null || state.userSections.isEmpty) {
            return const Text('Home');
          }

          final profile = state.userProfile;
          final user = state.user;

          return Column(
            children: [
              const Center(child: Text('Home')),
              Text('Logged in as ${profile.firstName} ${profile.lastName} ${user.email}'),
              Text('Viewing section ${state.currentSection.name}'),
            ],
          );
        },
      ),
    );
  }
}
