import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/question.dart';
import '../models/theme.dart';
import '../providers/quiz_provider.dart';
import '../ui/app_theme.dart';
import 'edit_question_screen.dart';
import 'quiz_screen.dart';

class ThemeSelectionScreen extends StatelessWidget {
  const ThemeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Choisissez un thème',
      child: Consumer<QuizProvider>(
        builder: (context, quizProvider, child) {
          final themes = quizProvider.themes;

          return SafeArea(
            child: themes.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: AppSurfaceCard(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(
                                  alpha: 0.12,
                                ),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: const Icon(
                                Icons.auto_stories_rounded,
                                color: AppColors.primary,
                                size: 34,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const AppSectionTitle(
                              title: 'Aucun thème disponible',
                              subtitle:
                                  'Créez votre premier thème pour commencer à jouer.',
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                    itemCount: themes.length,
                    itemBuilder: (context, index) {
                      final theme = themes[index];
                      final questions = quizProvider.getQuestionsByTheme(
                        theme.id,
                      );

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _ThemeCard(
                          theme: theme,
                          questionCount: questions.length,
                          onSettingsTap: () =>
                              _showThemeQuestions(context, theme),
                          onTap: () {
                            if (questions.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Ce thème ne contient pas encore de questions.',
                                  ),
                                  backgroundColor: AppColors.accent,
                                ),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      QuizScreen(theme: theme),
                                ),
                              );
                            }
                          },
                        ),
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
    return AppSurfaceCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.explore_rounded,
              size: 24,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(theme.name, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(
                  theme.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
                ),
                const SizedBox(height: 8),
                AppInfoChip(
                  icon: Icons.quiz_rounded,
                  label:
                      '$questionCount question${questionCount > 1 ? 's' : ''}',
                  color: questionCount == 0
                      ? AppColors.accent
                      : AppColors.primary,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: onSettingsTap,
                tooltip: 'Gérer le thème',
                constraints: const BoxConstraints.tightFor(
                  width: 34,
                  height: 34,
                ),
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.tune_rounded, color: AppColors.muted),
              ),
              const SizedBox(height: 6),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.ink,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

void _showThemeQuestions(BuildContext parentContext, QuizTheme theme) {
  showModalBottomSheet<void>(
    context: parentContext,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Consumer<QuizProvider>(
        builder: (context, quizProvider, child) {
          final questions = quizProvider.getQuestionsByTheme(theme.id);

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: AppSurfaceCard(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.72,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppSectionTitle(
                        title: theme.name,
                        subtitle:
                            '${questions.length} question${questions.length > 1 ? 's' : ''} dans ce thème',
                      ),
                      const SizedBox(height: 18),
                      Expanded(
                        child: questions.isEmpty
                            ? Center(
                                child: Text(
                                  'Aucune question dans ce thème pour le moment.',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(color: AppColors.muted),
                                ),
                              )
                            : ListView.separated(
                                itemCount: questions.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final question = questions[index];

                                  return Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.72,
                                      ),
                                      borderRadius: BorderRadius.circular(22),
                                      border: Border.all(
                                        color: AppColors.border,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 34,
                                          height: 34,
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withValues(
                                              alpha: 0.12,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            '${index + 1}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelLarge
                                                ?.copyWith(
                                                  color: AppColors.primary,
                                                ),
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(question.text),
                                              const SizedBox(height: 6),
                                              Text(
                                                _answerTypeLabel(
                                                  question.answerType,
                                                ),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                      color: AppColors.muted,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        PopupMenuButton<String>(
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
                                              child: Text('Modifier'),
                                            ),
                                            PopupMenuItem<String>(
                                              value: 'delete',
                                              child: Text('Supprimer'),
                                            ),
                                          ],
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              await Provider.of<QuizProvider>(
                context,
                listen: false,
              ).deleteQuestion(question.id);
              if (!context.mounted) {
                return;
              }
              Navigator.pop(dialogContext);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Question supprimée'),
                  backgroundColor: Colors.redAccent,
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
