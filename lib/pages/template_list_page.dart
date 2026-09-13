import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:kaisel/kaisel.dart';
import 'package:shared_models/shared_models.dart';

import '../repo.dart';
import '../routes.dart';

/// Lists markdown templates that can be inserted into event descriptions.
/// Accessible only to section managers and trip leaders (menu item is hidden
/// for everyone else).
class TemplateListPage extends HookWidget {
  const TemplateListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final templatesSnapshot = useStream(repository.streamTemplates());
    final templates = templatesSnapshot.data ?? const <Template>[];
    final sorted = [...templates]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return Scaffold(
      appBar: AppBar(title: const Text('Templates')),
      body: templatesSnapshot.connectionState == ConnectionState.waiting && templates.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : templates.isEmpty
              ? const Center(child: Text('No templates yet. Tap + to create one.'))
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: sorted.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final template = sorted[index];
                    return ListTile(
                      leading: const Icon(Icons.description_outlined),
                      title: Text(template.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text(template.language.toUpperCase()),
                      onTap: () {
                        context.push(TemplateEditRoute(templateId: template.id));
                      },
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add Template',
        onPressed: () {
          context.push(TemplateEditRoute());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}