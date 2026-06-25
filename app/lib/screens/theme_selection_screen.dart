import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/question.dart';
import '../models/theme.dart';
import '../providers/quiz_provider.dart';
import '../ui/app_theme.dart';
import 'question_form_screen.dart';
import 'quiz_screen.dart';

/// Écran de sélection du thème avant de lancer un quiz.
///
/// Affiche la liste des [QuizTheme] disponibles.
/// Un appui sur la carte lance le [QuizScreen] correspondant.
/// Le bouton d'options ouvre la feuille de gestion des questions du thème.
class ThemeSelectionScreen extends StatelessWidget {
  const ThemeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return AppScaffold(
      title: l.themeSelectionTitle,
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
                                color: AppColors.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: const Icon(
                                Icons.auto_stories_rounded,
                                color: AppColors.primary,
                                size: 34,
                              ),
                            ),
                            const SizedBox(height: 20),
                            AppSectionTitle(
                              title: l.themeNoThemesTitle,
                              subtitle: l.themeNoThemesSubtitle,
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
                      final questions = quizProvider.getQuestionsByTheme(theme.id);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _ThemeCard(
                          theme: theme,
                          questionCount: questions.length,
                          onSettingsTap: () => _showThemeQuestions(context, theme),
                          onDeleteTap: () => _showDeleteThemeDialog(context, theme),
                          onTap: () {
                            if (questions.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l.themeNoQuestionsSnack),
                                  backgroundColor: AppColors.accent,
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

/// Carte représentant un [QuizTheme] dans la liste de sélection.
class _ThemeCard extends StatelessWidget {
  final QuizTheme theme;
  final int questionCount;
  final VoidCallback onTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onDeleteTap;

  const _ThemeCard({
    required this.theme,
    required this.questionCount,
    required this.onTap,
    required this.onSettingsTap,
    required this.onDeleteTap,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

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
            child: const Icon(Icons.explore_rounded, size: 24, color: Colors.white),
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
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 8),
                AppInfoChip(
                  icon: Icons.quiz_rounded,
                  label: l.themeQuestionCount(questionCount),
                  color: questionCount == 0 ? AppColors.accent : AppColors.primary,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: onSettingsTap,
                    tooltip: l.themeManageTooltip,
                    constraints: const BoxConstraints.tightFor(width: 34, height: 34),
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.tune_rounded, color: AppColors.muted),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    onPressed: onDeleteTap,
                    tooltip: l.themeDeleteButton,
                    constraints: const BoxConstraints.tightFor(width: 34, height: 34),
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.ink,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Affiche une feuille modale listant les questions du [theme] avec options modifier/supprimer.
void _showThemeQuestions(BuildContext parentContext, QuizTheme theme) {
  showModalBottomSheet<void>(
    context: parentContext,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Consumer<QuizProvider>(
        builder: (context, quizProvider, child) {
          final l = AppLocalizations.of(context);
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
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: AppSectionTitle(
                              title: theme.name,
                              subtitle: l.themeQuestionsInTheme(questions.length),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Expanded(
                        child: questions.isEmpty
                            ? Center(
                                child: Text(
                                  l.themeQuestionsNone,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppColors.muted,
                                  ),
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
                                      color: Colors.white.withValues(alpha: 0.72),
                                      borderRadius: BorderRadius.circular(22),
                                      border: Border.all(color: AppColors.border),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 34,
                                          height: 34,
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            '${index + 1}',
                                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(question.text),
                                              const SizedBox(height: 6),
                                              Text(
                                                _answerTypeLabel(l, question.answerType),
                                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
                                                      QuestionFormScreen(question: question),
                                                ),
                                              );
                                            } else if (value == 'delete') {
                                              _showDeleteQuestionDialog(context, question);
                                            }
                                          },
                                          itemBuilder: (context) => [
                                            PopupMenuItem<String>(
                                              value: 'edit',
                                              child: Text(l.themeEditAction),
                                            ),
                                            PopupMenuItem<String>(
                                              value: 'delete',
                                              child: Text(l.themeDeleteButton),
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

/// Affiche une boîte de dialogue de confirmation avant de supprimer le [theme].
void _showDeleteThemeDialog(BuildContext context, QuizTheme theme) {
  showDialog<void>(
    context: context,
    builder: (dialogContext) {
      final l = AppLocalizations.of(context);

      return AlertDialog(
        title: Text(l.themeDeleteThemeTitle),
        content: Text(l.themeDeleteThemeConfirm(theme.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l.themeDeleteCancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(dialogContext);
              await Provider.of<QuizProvider>(
                context,
                listen: false,
              ).deleteTheme(theme.id);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l.profileThemeDeleted),
                  backgroundColor: Colors.redAccent,
                ),
              );
            },
            child: Text(l.themeDeleteButton),
          ),
        ],
      );
    },
  );
}

/// Affiche une boîte de dialogue de confirmation avant de supprimer [question].
void _showDeleteQuestionDialog(BuildContext context, Question question) {
  showDialog<void>(
    context: context,
    builder: (dialogContext) {
      final l = AppLocalizations.of(context);

      return AlertDialog(
        title: Text(l.themeDeleteTitle),
        content: Text(l.themeDeleteConfirm(question.text)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l.themeDeleteCancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              await Provider.of<QuizProvider>(
                context,
                listen: false,
              ).deleteQuestion(question.id);
              if (!context.mounted) return;
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l.themeDeleteSuccess),
                  backgroundColor: Colors.redAccent,
                ),
              );
            },
            child: Text(l.themeDeleteButton),
          ),
        ],
      );
    },
  );
}

/// Retourne le libellé localisé du [type] de réponse.
String _answerTypeLabel(AppLocalizations l, AnswerType type) {
  switch (type) {
    case AnswerType.open:
      return l.answerTypeOpen;
    case AnswerType.singleChoice:
      return l.answerTypeSingle;
    case AnswerType.multipleChoice:
      return l.answerTypeMultiple;
  }
}
