import 'package:flutter/material.dart';
import 'package:kaisel/kaisel.dart';

import '../routes.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Column(
        children: [
          const Center(child: Text('Home')),

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
