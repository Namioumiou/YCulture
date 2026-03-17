import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import '../ui/app_theme.dart';
import 'theme_selection_screen.dart';
import 'create_theme_screen.dart';
import 'create_question_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
        child: Consumer<QuizProvider>(
          builder: (context, quizProvider, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppSurfaceCard(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, AppColors.secondary],
                            ),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Icon(
                            Icons.auto_awesome,
                            color: Colors.white,
                            size: 34,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'YCulture',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Bienvenue sur YCulture, votre application de quiz personnalisable !',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.muted,
                          ),
                        ),
                        const SizedBox(height: 22),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            AppInfoChip(
                              icon: Icons.category_rounded,
                              label: '${quizProvider.themes.length} thèmes',
                            ),
                            AppInfoChip(
                              icon: Icons.quiz_outlined,
                              label: '${quizProvider.questions.length} questions',
                              color: AppColors.secondary,
                            ),
                            AppInfoChip(
                              icon: Icons.insights_outlined,
                              label: '${quizProvider.results.length} résultats',
                              color: AppColors.accent,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _MenuButton(
                    icon: Icons.play_arrow_rounded,
                    label: 'Jouer maintenant',
                    subtitle: 'Parcourir les thèmes disponibles',
                    color: AppColors.primary,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ThemeSelectionScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  _MenuButton(
                    icon: Icons.palette_outlined,
                    label: 'Créer un thème',
                    subtitle: 'Ajouter une nouvelle catégorie de quiz',
                    color: AppColors.secondary,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateThemeScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  _MenuButton(
                    icon: Icons.edit_note_rounded,
                    label: 'Créer une question',
                    subtitle: 'Texte, image ou audio',
                    color: AppColors.accent,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateQuestionScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onPressed;

  const _MenuButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, Color.lerp(color, Colors.white, 0.3)!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.22),
            blurRadius: 26,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(icon, size: 28, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.88),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
