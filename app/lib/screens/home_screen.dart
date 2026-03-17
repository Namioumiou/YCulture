import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import '../ui/app_theme.dart';
import 'theme_selection_screen.dart';
import 'create_theme_screen.dart';
import 'create_question_screen.dart';
import 'profile_screen.dart';

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
                        Row(
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
                            const Spacer(),
                            _HomeProfileAvatar(
                              avatarId: quizProvider.profileAvatarId,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ProfileScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
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
                            AppInfoChip(
                              icon: Icons.stars_rounded,
                              label: 'Niv. ${quizProvider.level}',
                              color: AppColors.ink,
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
                  const SizedBox(height: 14),
                  _MenuButton(
                    icon: Icons.person_outline_rounded,
                    label: 'Mon profil',
                    subtitle: 'Modifier votre avatar utilisateur',
                    color: AppColors.ink,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileScreen(),
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

class _HomeProfileAvatar extends StatefulWidget {
  final String? avatarId;
  final VoidCallback onTap;

  const _HomeProfileAvatar({
    required this.avatarId,
    required this.onTap,
  });

  @override
  State<_HomeProfileAvatar> createState() => _HomeProfileAvatarState();
}

class _HomeProfileAvatarState extends State<_HomeProfileAvatar> {
  static const String _avatarDirectory = 'assets/avatars/';
  Map<String, String> _avatarById = const {};

  @override
  void initState() {
    super.initState();
    _loadAvatarIndex();
  }

  Future<void> _loadAvatarIndex() async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final assets = manifest.listAssets().where((asset) {
      return asset.startsWith(_avatarDirectory) &&
          (asset.endsWith('.png') ||
              asset.endsWith('.jpg') ||
              asset.endsWith('.jpeg') ||
              asset.endsWith('.webp'));
    });

    final map = <String, String>{};
    for (final path in assets) {
      final fileName = path.split('/').last;
      final dot = fileName.lastIndexOf('.');
      final id = dot == -1 ? fileName : fileName.substring(0, dot);
      map[id] = path;
    }

    if (!mounted) {
      return;
    }
    setState(() {
      _avatarById = map;
    });
  }

  @override
  Widget build(BuildContext context) {
    final avatarPath = widget.avatarId != null ? _avatarById[widget.avatarId] : null;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [AppColors.secondary, AppColors.accent],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A0F172A),
              blurRadius: 14,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: CircleAvatar(
          radius: 26,
          backgroundColor: Colors.white,
          child: ClipOval(
            child: avatarPath != null
                ? Image.asset(
                    avatarPath,
                    width: 46,
                    height: 46,
                    fit: BoxFit.cover,
                  )
                : const Icon(
                    Icons.person_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
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
