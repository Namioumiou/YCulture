import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import '../models/theme.dart';
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
                onTap: () {
                  if (questions.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ce thème ne contient pas encore de questions'),
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

  const _ThemeCard({
    required this.theme,
    required this.questionCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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
                child: const Icon(
                  Icons.category,
                  size: 30,
                  color: Colors.blue,
                ),
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
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.quiz,
                          size: 16,
                          color: Colors.grey[600],
                        ),
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
              const Icon(
                Icons.arrow_forward_ios,
                size: 20,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
