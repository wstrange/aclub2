import 'package:aclub2/admin/setup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kaisel/kaisel.dart';

import '../routes.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),

        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
            onPressed: () async {
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
          ],
        ),
      ),
      body: Column(
        children: [
          const Center(child: Text('Home')),
          Text('User is ${FirebaseAuth.instance.currentUser}'),
          ElevatedButton(
            onPressed: () {
              context.push(const UserProfileRoute());
            },
            child: const Text('Create User'),
          ),
        ],
      ),
    );
  }
}
