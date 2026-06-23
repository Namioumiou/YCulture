import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/question.dart';
import '../providers/quiz_provider.dart';
import '../ui/app_theme.dart';
import '../widgets/question_form.dart';

class EditQuestionScreen extends StatelessWidget {
  final Question question;

  const EditQuestionScreen({super.key, required this.question});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Modifier la question',
      child: Consumer<QuizProvider>(
        builder: (context, quizProvider, child) {
          return QuestionForm(
            themes: quizProvider.themes,
            initialQuestion: question,
            submitButtonLabel: 'Enregistrer',
            onSubmit: (values) async {
              final updated = question.copyWith(
                text: values.text,
                imageUrl: values.imageUrl,
                audioUrl: values.audioUrl,
                questionType: values.questionType,
                answerType: values.answerType,
                choices: values.choices,
                correctAnswers: values.correctAnswers,
                themeId: values.themeId,
              );

              await quizProvider.updateQuestion(updated);

              if (!context.mounted) {
                return;
              }

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Question modifiée avec succès'),
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
