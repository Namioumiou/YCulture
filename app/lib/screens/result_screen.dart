import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/question.dart';
import '../models/quiz_result.dart';
import '../models/theme.dart';
import '../providers/quiz_provider.dart';
import '../ui/app_theme.dart';
import 'quiz_screen.dart';

/// Écran de résultats affiché à la fin d'un quiz ou depuis l'historique du profil.
///
/// En mode normal ([isHistoryView] = false), enregistre le résultat via [QuizProvider]
/// et affiche le gain XP, l'éventuelle montée de niveau ainsi que le corrigé détaillé.
/// En mode historique ([isHistoryView] = true), l'affichage est en lecture seule.
class ResultScreen extends StatefulWidget {
  final QuizTheme theme;
  final int totalQuestions;
  final int correctAnswers;

  /// Liste des questions (vide en mode historique).
  final List<Question> questions;

  /// Réponses de l'utilisateur indexées par position (vide en mode historique).
  final Map<int, dynamic> userAnswers;

  /// Si vrai, l'écran est ouvert depuis l'historique ; le résultat n'est pas enregistré.
  final bool isHistoryView;

  const ResultScreen({
    super.key,
    required this.theme,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.questions,
    required this.userAnswers,
    this.isHistoryView = false,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  ExperienceGain? _experienceGain;

  @override
  void initState() {
    super.initState();
    if (!widget.isHistoryView) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;

        final experienceGain = await Provider.of<QuizProvider>(
          context,
          listen: false,
        ).addResult(
          QuizResult(
            themeId: widget.theme.id,
            totalQuestions: widget.totalQuestions,
            correctAnswers: widget.correctAnswers,
            completedAt: DateTime.now(),
            questions: widget.questions,
            userAnswers: widget.userAnswers,
          ),
        );

        if (!mounted) return;
        setState(() => _experienceGain = experienceGain);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final level = context.select((QuizProvider p) => p.level);
    final levelXp = context.select((QuizProvider p) => p.experiencePointsInCurrentLevel);
    final xpPerLevel = context.select((QuizProvider p) => p.xpPerLevel);

    final percentage = (widget.correctAnswers / widget.totalQuestions * 100).round();
    final ratio = widget.correctAnswers / widget.totalQuestions;
    final palette = _paletteForPercentage(percentage);
    final reviews = _buildReviews(l);

    return AppScaffold(
      title: l.resultsTitle,
      automaticallyImplyLeading: false,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSurfaceCard(
                child: Column(
                  children: [
                    _ScoreCircle(percentage: percentage, palette: palette, ratio: ratio),
                    const SizedBox(height: 24),
                    Text(
                      l.resultsQuizDone,
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.theme.name,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.muted,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 18),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        minHeight: 12,
                        value: ratio,
                        backgroundColor: AppColors.border,
                        valueColor: AlwaysStoppedAnimation<Color>(palette.first),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: l.resultsCorrectLabel,
                      value: widget.correctAnswers.toString(),
                      color: const Color(0xFF14B86A),
                      icon: Icons.check_circle_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: l.resultsIncorrectLabel,
                      value: (widget.totalQuestions - widget.correctAnswers).toString(),
                      color: AppColors.accent,
                      icon: Icons.remove_circle_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: l.resultsTotalLabel,
                      value: widget.totalQuestions.toString(),
                      color: AppColors.primary,
                      icon: Icons.quiz_rounded,
                    ),
                  ),
                ],
              ),
              if (_experienceGain != null) ...[
                const SizedBox(height: 20),
                _XpProgressCard(
                  experienceGain: _experienceGain!,
                  level: level,
                  levelXp: levelXp,
                  xpPerLevel: xpPerLevel,
                ),
              ],
              if (reviews.isNotEmpty) ...[
                const SizedBox(height: 20),
                AppSurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l.resultsDetailedReview,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l.resultsDetailedReviewSubtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.muted,
                        ),
                      ),
                      const SizedBox(height: 18),
                      ...reviews.asMap().entries.map((entry) {
                        final index = entry.key;
                        final review = entry.value;
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: index == reviews.length - 1 ? 0 : 14,
                          ),
                          child: _QuestionReviewCard(index: index + 1, review: review),
                        );
                      }),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              if (!widget.isHistoryView)
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => QuizScreen(theme: widget.theme),
                      ),
                    );
                  },
                  icon: const Icon(Icons.replay_rounded),
                  label: Text(l.resultsRetry),
                ),
              if (!widget.isHistoryView) const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  if (widget.isHistoryView) {
                    Navigator.of(context).pop();
                  } else {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                },
                icon: Icon(widget.isHistoryView
                    ? Icons.arrow_back_rounded
                    : Icons.home_rounded),
                label: Text(widget.isHistoryView ? l.resultsBack : l.resultsBackHome),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  List<Color> _paletteForPercentage(int percentage) {
    if (percentage >= 80) return const [Color(0xFF14B86A), Color(0xFF60D394)];
    if (percentage >= 60) return const [AppColors.primary, Color(0xFF5AA9FF)];
    if (percentage >= 40) return const [AppColors.accent, Color(0xFFFFB26B)];
    return const [Color(0xFFD94F70), Color(0xFFF08AA0)];
  }

  List<_QuestionReview> _buildReviews(AppLocalizations l) {
    return List<_QuestionReview>.generate(widget.questions.length, (index) {
      final question = widget.questions[index];
      final userAnswer = widget.userAnswers[index];
      final isCorrect = _isAnswerCorrect(question, userAnswer);

      return _QuestionReview(
        question: question,
        userAnswerLabel: _formatAnswer(l, question, userAnswer),
        correctAnswerLabel: _formatCorrectAnswer(l, question),
        isCorrect: isCorrect,
      );
    });
  }

  bool _isAnswerCorrect(Question question, dynamic userAnswer) {
    if (userAnswer == null) return false;

    if (question.answerType == AnswerType.multipleChoice) {
      final userSet = Set<String>.from(userAnswer as List);
      final correctSet = Set<String>.from(question.correctAnswers);
      return userSet.containsAll(correctSet) && correctSet.containsAll(userSet);
    }

    if (question.answerType == AnswerType.singleChoice) {
      return question.correctAnswers.contains(userAnswer);
    }

    final answer = (userAnswer as String).trim().toLowerCase();
    return question.correctAnswers.any((c) => c.trim().toLowerCase() == answer);
  }

  String _formatAnswer(AppLocalizations l, Question question, dynamic answer) {
    if (answer == null) return l.resultsNoAnswer;

    if (question.answerType == AnswerType.multipleChoice) {
      final answers = List<String>.from(answer as List);
      if (answers.isEmpty) return l.resultsNoAnswer;
      return answers.join(', ');
    }

    final label = answer.toString().trim();
    return label.isEmpty ? l.resultsNoAnswer : label;
  }

  String _formatCorrectAnswer(AppLocalizations l, Question question) {
    if (question.correctAnswers.isEmpty) return l.resultsNoAnswerDefined;
    return question.correctAnswers.join(', ');
  }
}

// ---------------------------------------------------------------------------
// Extracted widgets
// ---------------------------------------------------------------------------

/// Cercle de score animé affiché en haut de la carte de résultats.
class _ScoreCircle extends StatelessWidget {
  final int percentage;
  final List<Color> palette;
  final double ratio;

  const _ScoreCircle({
    required this.percentage,
    required this.palette,
    required this.ratio,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 172,
      height: 172,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: palette),
      ),
      padding: const EdgeInsets.all(12),
      child: DecoratedBox(
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$percentage%',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}

/// Carte de progression XP et niveau affiché après un quiz.
class _XpProgressCard extends StatelessWidget {
  final ExperienceGain experienceGain;
  final int level;
  final int levelXp;
  final int xpPerLevel;

  const _XpProgressCard({
    required this.experienceGain,
    required this.level,
    required this.levelXp,
    required this.xpPerLevel,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.resultsProgression, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 10),
          Text(
            l.resultsXpGained(experienceGain.gainedExperiencePoints),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            experienceGain.didLevelUp
                ? l.resultsLevelUp(experienceGain.currentLevel)
                : l.resultsCurrentLevel(level),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: levelXp / xpPerLevel,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l.resultsXpToNextLevel(levelXp, xpPerLevel),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

/// Données d'une question à afficher dans le corrigé détaillé.
class _QuestionReview {
  final Question question;
  final String userAnswerLabel;
  final String correctAnswerLabel;
  final bool isCorrect;

  const _QuestionReview({
    required this.question,
    required this.userAnswerLabel,
    required this.correctAnswerLabel,
    required this.isCorrect,
  });
}

/// Carte de corrigé pour une question individuelle.
class _QuestionReviewCard extends StatelessWidget {
  final int index;
  final _QuestionReview review;

  const _QuestionReviewCard({required this.index, required this.review});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final statusColor = review.isCorrect
        ? const Color(0xFF14B86A)
        : const Color(0xFFD94F70);
    final statusIcon = review.isCorrect
        ? Icons.check_circle_rounded
        : Icons.cancel_rounded;
    final statusLabel = review.isCorrect ? l.resultsCorrect : l.resultsIncorrect;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l.resultsQuestionNumber(index),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 16, color: statusColor),
                    const SizedBox(width: 6),
                    Text(
                      statusLabel,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review.question.text,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          _AnswerComparisonRow(
            label: l.resultsYourAnswerLabel,
            value: review.userAnswerLabel,
            color: review.isCorrect ? const Color(0xFF14B86A) : AppColors.accent,
            icon: review.isCorrect ? Icons.verified_rounded : Icons.person_rounded,
          ),
          const SizedBox(height: 10),
          _AnswerComparisonRow(
            label: l.resultsCorrectAnswerLabel,
            value: review.correctAnswerLabel,
            color: const Color(0xFF14B86A),
            icon: Icons.lightbulb_rounded,
          ),
        ],
      ),
    );
  }
}

/// Ligne de comparaison réponse utilisateur / bonne réponse dans le corrigé.
class _AnswerComparisonRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _AnswerComparisonRow({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(color: color),
                ),
                const SizedBox(height: 4),
                Text(value, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Carte de statistique (correctes, incorrectes, total).
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 10),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}
