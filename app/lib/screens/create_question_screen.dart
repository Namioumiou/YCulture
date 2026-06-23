import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/question.dart';
import '../providers/quiz_provider.dart';
import '../ui/app_theme.dart';
import '../widgets/question_form.dart';

class CreateQuestionScreen extends StatelessWidget {
  const CreateQuestionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Créer une question',
      child: Consumer<QuizProvider>(
        builder: (context, quizProvider, child) {
          final themes = quizProvider.themes;

          if (themes.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: AppSurfaceCard(
                  child: Text(
                    'Vous devez d\'abord créer un thème avant de pouvoir ajouter des questions.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          }

          return QuestionForm(
            themes: themes,
            submitButtonLabel: 'Créer la question',
            onSubmit: (values) async {
              final newQuestion = Question(
                id: quizProvider.generateId(),
                text: values.text,
                imageUrl: values.imageUrl,
                audioUrl: values.audioUrl,
                questionType: values.questionType,
                answerType: values.answerType,
                choices: values.choices,
                correctAnswers: values.correctAnswers,
                themeId: values.themeId,
              );

              await quizProvider.addQuestion(newQuestion);

              if (!context.mounted) {
                return;
              }

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Question créée avec succès !'),
                  backgroundColor: Colors.green,
                ),
              );

              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}
