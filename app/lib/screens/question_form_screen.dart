import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/question.dart';
import '../providers/quiz_provider.dart';
import '../ui/app_theme.dart';
import '../widgets/question_form.dart';

/// Écran de formulaire pour créer ou modifier une question.
///
/// Passer [question] pour pré-remplir en mode édition ; omettre pour créer.
class QuestionFormScreen extends StatelessWidget {
  /// Question à modifier. Si `null`, l'écran est en mode création.
  final Question? question;

  const QuestionFormScreen({super.key, this.question});

  bool get isEditing => question != null;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final title = isEditing ? l.questionFormEditTitle : l.questionFormCreateTitle;

    return AppScaffold(
      title: title,
      child: Consumer<QuizProvider>(
        builder: (context, quizProvider, child) {
          final themes = quizProvider.themes;

          if (themes.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: AppSurfaceCard(
                  child: Text(l.questionFormNoTheme, textAlign: TextAlign.center),
                ),
              ),
            );
          }

          return QuestionForm(
            themes: themes,
            initialQuestion: question,
            submitButtonLabel:
                isEditing ? l.questionFormSave : l.questionFormCreate,
            onSubmit: (values) async {
              if (isEditing) {
                await quizProvider.updateQuestion(
                  question!.copyWith(
                    text: values.text,
                    imageUrl: values.imageUrl,
                    audioUrl: values.audioUrl,
                    questionType: values.questionType,
                    answerType: values.answerType,
                    choices: values.choices,
                    correctAnswers: values.correctAnswers,
                    themeId: values.themeId,
                  ),
                );

                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l.questionFormEditSuccess),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                await quizProvider.addQuestion(
                  Question(
                    id: quizProvider.generateId(),
                    text: values.text,
                    imageUrl: values.imageUrl,
                    audioUrl: values.audioUrl,
                    questionType: values.questionType,
                    answerType: values.answerType,
                    choices: values.choices,
                    correctAnswers: values.correctAnswers,
                    themeId: values.themeId,
                  ),
                );

                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l.questionFormSuccess),
                    backgroundColor: Colors.green,
                  ),
                );
              }

              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}
