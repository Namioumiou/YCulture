import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/theme.dart';
import '../providers/quiz_provider.dart';
import '../ui/app_theme.dart';

/// Écran de création d'un nouveau thème de quiz.
///
/// Affiche un formulaire avec un champ nom et un champ description.
/// À la validation, un [QuizTheme] est créé et ajouté via [QuizProvider].
class CreateThemeScreen extends StatefulWidget {
  const CreateThemeScreen({super.key});

  @override
  State<CreateThemeScreen> createState() => _CreateThemeScreenState();
}

class _CreateThemeScreenState extends State<CreateThemeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveTheme() {
    if (_formKey.currentState!.validate()) {
      final l = AppLocalizations.of(context);
      final quizProvider = Provider.of<QuizProvider>(context, listen: false);

      final newTheme = QuizTheme(
        id: quizProvider.generateId(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
      );

      quizProvider.addTheme(newTheme);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.createThemeSuccess),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return AppScaffold(
      title: l.createThemeTitle,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                AppSurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: l.createThemeNameLabel,
                          hintText: l.createThemeNameHint,
                          prefixIcon: const Icon(Icons.title_rounded),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l.createThemeNameError;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: _descriptionController,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          labelText: l.createThemeDescLabel,
                          hintText: l.createThemeDescHint,
                          prefixIcon: const Icon(Icons.notes_rounded),
                        ),
                        minLines: 1,
                        maxLines: null,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l.createThemeDescError;
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _saveTheme,
                  icon: const Icon(Icons.check_circle_outline),
                  label: Text(l.createThemeButton),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
