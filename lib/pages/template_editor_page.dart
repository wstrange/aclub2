import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:kaisel/kaisel.dart';
import 'package:shared_models/shared_models.dart';

import '../repo.dart';

/// Creates or edits a [Template]. [templateId] is empty when creating.
class TemplateEditPage extends StatelessWidget {
  const TemplateEditPage({super.key, required this.templateId});

  final String templateId;

  bool get isCreate => templateId.isEmpty;

  @override
  Widget build(BuildContext context) {
    if (isCreate) {
      final now = DateTime.now();
      return TemplateEditorForm(
        isCreate: true,
        initialTemplate: Template(
          id: '',
          language: 'en',
          title: '',
          markdownText: '',
          createdBy: FirebaseAuth.instance.currentUser?.uid ?? '',
          createdAt: now,
          updatedAt: now,
        ),
      );
    }

    return FutureBuilder<Template?>(
      future: repository.getTemplate(templateId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Edit Template')),
            body: Center(
              child: Text(
                'Error loading template: ${snapshot.error}',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          );
        }

        final template = snapshot.data;
        if (template == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Edit Template')),
            body: const Center(child: Text('Template not found.')),
          );
        }

        return TemplateEditorForm(isCreate: false, initialTemplate: template);
      },
    );
  }
}

class TemplateEditorForm extends HookWidget {
  const TemplateEditorForm({super.key, required this.isCreate, required this.initialTemplate});

  final bool isCreate;
  final Template initialTemplate;

  @override
  Widget build(BuildContext context) {
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final titleController = useTextEditingController(text: initialTemplate.title);
    final language = useState(initialTemplate.language);
    final markdownController = useTextEditingController(text: initialTemplate.markdownText);

    final isSaving = useState(false);
    final errorMessage = useState<String?>(null);

    Future<void> save() async {
      final title = titleController.text.trim();
      final markdownText = markdownController.text.trim();

      if (title.isEmpty || markdownText.isEmpty) {
        errorMessage.value = 'Title and markdown body are required.';
        return;
      }

      isSaving.value = true;
      errorMessage.value = null;
      final now = DateTime.now();
      try {
        if (isCreate) {
          final template = initialTemplate.copyWith(
            title: title,
            language: language.value,
            markdownText: markdownText,
            createdAt: now,
            updatedAt: now,
          );
          await repository.createTemplate(template);
        } else {
          final template = initialTemplate.copyWith(
            title: title,
            language: language.value,
            markdownText: markdownText,
            updatedAt: now,
          );
          await repository.updateTemplate(template);
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Template saved successfully.')),
          );
          context.pop();
        }
      } catch (e) {
        if (context.mounted) {
          errorMessage.value = isCreate ? 'Failed to create template: $e' : 'Failed to update template: $e';
        }
      } finally {
        isSaving.value = false;
      }
    }

    Widget sectionHeader(String text) {
      return Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 8),
        child: Text(text, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(isCreate ? 'Add Template' : 'Edit Template')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              sectionHeader('Template'),
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title *', border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: language.value,
                decoration: const InputDecoration(labelText: 'Language', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'en', child: Text('English')),
                  DropdownMenuItem(value: 'fr', child: Text('French')),
                ],
                onChanged: (val) {
                  if (val != null) language.value = val;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: markdownController,
                maxLines: 12,
                decoration: const InputDecoration(
                  labelText: 'Markdown Body *',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Markdown body is required';
                  }
                  return null;
                },
              ),
              if (errorMessage.value != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    errorMessage.value!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.bold),
                  ),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: isSaving.value ? null : save,
                  child: isSaving.value
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(isCreate ? 'Create Template' : 'Save Changes', style: const TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}