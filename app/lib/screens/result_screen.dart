import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/question.dart';
import '../models/quiz_result.dart';
import '../models/theme.dart';
import '../providers/quiz_provider.dart';
import '../ui/app_theme.dart';

class ResultScreen extends StatefulWidget {
  final QuizTheme theme;
  final int totalQuestions;
  final int correctAnswers;
  final List<Question> questions;
  final Map<int, dynamic> userAnswers;

  const ResultScreen({
    super.key,
    required this.theme,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.questions,
    required this.userAnswers,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  ExperienceGain? _experienceGain;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      final experienceGain = Provider.of<QuizProvider>(
        context,
        listen: false,
      ).addResult(
        QuizResult(
          themeId: widget.theme.id,
          totalQuestions: widget.totalQuestions,
          correctAnswers: widget.correctAnswers,
          completedAt: DateTime.now(),
        ),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _experienceGain = experienceGain;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final quizProvider = context.watch<QuizProvider>();
    final percentage = (widget.correctAnswers / widget.totalQuestions * 100)
        .round();
    final ratio = widget.correctAnswers / widget.totalQuestions;
    final palette = _paletteForPercentage(percentage);
    final reviews = _buildReviews();

    return AppScaffold(
      title: 'Résultats',
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
                    Container(
                      width: 172,
                      height: 172,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: palette),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: DecoratedBox(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$percentage%',
                              style: Theme.of(context).textTheme.headlineLarge
                                  ?.copyWith(color: AppColors.ink),
                            ),
                            const SizedBox(height: 6),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Quiz terminé',
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.theme.name,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: AppColors.muted),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 18),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        minHeight: 12,
                        value: ratio,
                        backgroundColor: AppColors.border,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          palette.first,
                        ),
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
                      label: 'Correctes',
                      value: widget.correctAnswers.toString(),
                      color: const Color(0xFF14B86A),
                      icon: Icons.check_circle_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Incorrectes',
                      value: (widget.totalQuestions - widget.correctAnswers)
                          .toString(),
                      color: AppColors.accent,
                      icon: Icons.remove_circle_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Total',
                      value: widget.totalQuestions.toString(),
                      color: AppColors.primary,
                      icon: Icons.quiz_rounded,
                    ),
                  ),
                ],
              ),
              if (_experienceGain != null) ...[
                const SizedBox(height: 20),
                AppSurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Progression',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '+${_experienceGain!.gainedExperiencePoints} XP',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(color: AppColors.primary),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _experienceGain!.didLevelUp
                            ? 'Bravo ! Niveau ${_experienceGain!.currentLevel} atteint.'
                            : 'Niveau actuel: ${quizProvider.level}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 14),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          minHeight: 10,
                          value: quizProvider.experiencePointsInCurrentLevel /
                              quizProvider.xpPerLevel,
                          backgroundColor: AppColors.border,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.secondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${quizProvider.experiencePointsInCurrentLevel}/${quizProvider.xpPerLevel} XP vers le niveau suivant',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.muted,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              AppSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Corrigé détaillé',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Comparez votre réponse avec la bonne réponse pour chaque question.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
                    ),
                    const SizedBox(height: 18),
                    ...reviews.asMap().entries.map((entry) {
                      final index = entry.key;
                      final review = entry.value;

                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index == reviews.length - 1 ? 0 : 14,
                        ),
                        child: _QuestionReviewCard(
                          index: index + 1,
                          review: review,
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                icon: const Icon(Icons.home_rounded),
                label: const Text('Retour à l\'accueil'),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  List<Color> _paletteForPercentage(int percentage) {
    if (percentage >= 80) {
      return const [Color(0xFF14B86A), Color(0xFF60D394)];
    }
    if (percentage >= 60) {
      return const [AppColors.primary, Color(0xFF5AA9FF)];
    }
    if (percentage >= 40) {
      return const [AppColors.accent, Color(0xFFFFB26B)];
    }
    return const [Color(0xFFD94F70), Color(0xFFF08AA0)];
  }

  List<_QuestionReview> _buildReviews() {
    return List<_QuestionReview>.generate(widget.questions.length, (index) {
      final question = widget.questions[index];
      final userAnswer = widget.userAnswers[index];
      final isCorrect = _isAnswerCorrect(question, userAnswer);

      return _QuestionReview(
        question: question,
        userAnswerLabel: _formatAnswer(question, userAnswer),
        correctAnswerLabel: _formatCorrectAnswer(question),
        isCorrect: isCorrect,
      );
    });
  }

  bool _isAnswerCorrect(Question question, dynamic userAnswer) {
    if (userAnswer == null) {
      return false;
    }

    if (question.answerType == AnswerType.multipleChoice) {
      final userSet = Set<String>.from(userAnswer as List);
      final correctSet = Set<String>.from(question.correctAnswers);
      return userSet.containsAll(correctSet) && correctSet.containsAll(userSet);
    }

    if (question.answerType == AnswerType.singleChoice) {
      return question.correctAnswers.contains(userAnswer);
    }

    final answer = (userAnswer as String).trim().toLowerCase();
    return question.correctAnswers.any(
      (correct) => correct.trim().toLowerCase() == answer,
    );
  }

  String _formatAnswer(Question question, dynamic answer) {
    if (answer == null) {
      return 'Aucune réponse';
    }

    if (question.answerType == AnswerType.multipleChoice) {
      final answers = List<String>.from(answer as List);
      if (answers.isEmpty) {
        return 'Aucune réponse';
      }
      return answers.join(', ');
    }

    final label = answer.toString().trim();
    if (label.isEmpty) {
      return 'Aucune réponse';
    }
    return label;
  }

  String _formatCorrectAnswer(Question question) {
    if (question.correctAnswers.isEmpty) {
      return 'Aucune réponse définie';
    }
    return question.correctAnswers.join(', ');
  }
}

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

class _QuestionReviewCard extends StatelessWidget {
  final int index;
  final _QuestionReview review;

  const _QuestionReviewCard({required this.index, required this.review});

  @override
  Widget build(BuildContext context) {
    final statusColor = review.isCorrect
        ? const Color(0xFF14B86A)
        : const Color(0xFFD94F70);
    final statusIcon = review.isCorrect
        ? Icons.check_circle_rounded
        : Icons.cancel_rounded;
    final statusLabel = review.isCorrect ? 'Correct' : 'Incorrect';

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
                  'Question $index',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
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
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          _AnswerComparisonRow(
            label: 'Votre réponse',
            value: review.userAnswerLabel,
            color: review.isCorrect
                ? const Color(0xFF14B86A)
                : AppColors.accent,
            icon: review.isCorrect
                ? Icons.verified_rounded
                : Icons.person_rounded,
          ),
          const SizedBox(height: 10),
          _AnswerComparisonRow(
            label: 'Bonne réponse',
            value: review.correctAnswerLabel,
            color: const Color(0xFF14B86A),
            icon: Icons.lightbulb_rounded,
          ),
        ],
      ),
    );
  }
}

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
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: color),
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
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}
