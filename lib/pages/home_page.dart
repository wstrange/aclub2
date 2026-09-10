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
      body: Column(
        children: [
          const Center(child: Text('Home')),
          Text('User is ${FirebaseAuth.instance.currentUser}'),
          ElevatedButton(
            onPressed: () {
              context.push(const CreateUser());
            },
            child: const Text('Create User'),
          ),
        ],
      ),
    );
  }
}
