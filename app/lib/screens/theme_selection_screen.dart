import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/question.dart';
import '../providers/quiz_provider.dart';
import '../models/theme.dart';
import 'edit_question_screen.dart';
import 'quiz_screen.dart';

class ThemeSelectionScreen extends StatelessWidget {
  const ThemeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choisissez un thème'),
        centerTitle: true,
      ),
      body: Consumer<QuizProvider>(
        builder: (context, quizProvider, child) {
          final themes = quizProvider.themes;

          if (themes.isEmpty) {
            return const Center(
              child: Text(
                'Aucun thème disponible.\nCréez votre premier thème !',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return SafeArea(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: themes.length,
              itemBuilder: (context, index) {
                final theme = themes[index];
                final questions = quizProvider.getQuestionsByTheme(theme.id);

                return _ThemeCard(
                  theme: theme,
                  questionCount: questions.length,
                  onSettingsTap: () => _showThemeQuestions(context, theme),
                  onTap: () {
                    if (questions.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Ce thème ne contient pas encore de questions',
                          ),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuizScreen(theme: theme),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  final QuizTheme theme;
  final int questionCount;
  final VoidCallback onTap;
  final VoidCallback onSettingsTap;

  const _ThemeCard({
    required this.theme,
    required this.questionCount,
    required this.onTap,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.category, size: 30, color: Colors.blue),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      theme.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      theme.description,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.quiz, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '$questionCount question${questionCount > 1 ? 's' : ''}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onSettingsTap,
                tooltip: 'Paramètres du thème',
                icon: const Icon(Icons.settings, size: 22, color: Colors.grey),
              ),
              const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

void _showThemeQuestions(BuildContext parentContext, QuizTheme theme) {
  showModalBottomSheet<void>(
    context: parentContext,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Consumer<QuizProvider>(
        builder: (context, quizProvider, child) {
          final questions = quizProvider.getQuestionsByTheme(theme.id);

          return SafeArea(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Questions - ${theme.name}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${questions.length} question${questions.length > 1 ? 's' : ''}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: questions.isEmpty
                          ? const Center(
                              child: Text(
                                'Aucune question dans ce thème pour le moment.',
                                textAlign: TextAlign.center,
                              ),
                            )
                          : ListView.separated(
                              itemCount: questions.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final question = questions[index];
                                return ListTile(
                                  leading: CircleAvatar(
                                    radius: 14,
                                    backgroundColor: Colors.blue.withOpacity(
                                      0.1,
                                    ),
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  title: Text(question.text),
                                  subtitle: Text(
                                    _answerTypeLabel(question.answerType),
                                  ),
                                  trailing: PopupMenuButton<String>(
                                    onSelected: (value) {
                                      if (value == 'edit') {
                                        Navigator.pop(parentContext);
                                        Navigator.push(
                                          parentContext,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                EditQuestionScreen(
                                                  question: question,
                                                ),
                                          ),
                                        );
                                      } else if (value == 'delete') {
                                        _showDeleteQuestionDialog(
                                          context,
                                          question,
                                        );
                                      }
                                    },
                                    itemBuilder: (context) => const [
                                      PopupMenuItem<String>(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit, size: 18),
                                            SizedBox(width: 8),
                                            Text('Modifier'),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem<String>(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.delete,
                                              size: 18,
                                              color: Colors.red,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              'Supprimer',
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

void _showDeleteQuestionDialog(BuildContext context, Question question) {
  showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Supprimer la question ?'),
        content: Text('Cette action est irréversible.\n\n"${question.text}"'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Provider.of<QuizProvider>(
                context,
                listen: false,
              ).deleteQuestion(question.id);
              Navigator.pop(dialogContext);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Question supprimée'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Supprimer'),
          ),
        ],
      );
    },
  );
}

String _answerTypeLabel(AnswerType type) {
  switch (type) {
    case AnswerType.open:
      return 'Réponse ouverte';
    case AnswerType.singleChoice:
      return 'Choix unique';
    case AnswerType.multipleChoice:
      return 'Choix multiple';
  }
}
