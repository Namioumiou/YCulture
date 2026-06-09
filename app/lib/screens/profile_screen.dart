import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/quiz_result.dart';
import '../providers/quiz_provider.dart';
import '../ui/app_theme.dart';
import '../widgets/avatar_picker_sheet.dart';
import 'result_screen.dart';

/// Écran de profil de l'utilisateur.
///
/// Affiche l'avatar sélectionné, la progression XP/niveau
/// et les 10 derniers résultats de quiz.
/// Permet de choisir un avatar parmi la galerie d'assets `assets/avatars/`,
/// certains avatars étant débloqués en fonction du niveau atteint.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const String _avatarDirectory = 'assets/avatars/';
  List<AvatarPreset> _avatarBank = const [];

  @override
  void initState() {
    super.initState();
    _loadAvatarBank();
  }

  Future<void> _loadAvatarBank() async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final avatarAssets = manifest
        .listAssets()
        .where(
          (asset) =>
              asset.startsWith(_avatarDirectory) &&
              (asset.endsWith('.png') ||
                  asset.endsWith('.jpg') ||
                  asset.endsWith('.jpeg') ||
                  asset.endsWith('.webp')),
        )
        .toList()
      ..sort();

    if (!mounted) return;

    setState(() {
      _avatarBank = avatarAssets
          .map(
            (assetPath) => AvatarPreset(
              id: _buildAvatarId(assetPath),
              imagePath: assetPath,
            ),
          )
          .toList();
    });
  }

  String _buildAvatarId(String assetPath) {
    final fileName = assetPath.split('/').last;
    final dotIndex = fileName.lastIndexOf('.');
    return dotIndex == -1 ? fileName : fileName.substring(0, dotIndex);
  }

  AvatarPreset _resolveAvatar(String? avatarId) {
    if (_avatarBank.isEmpty) {
      return const AvatarPreset(id: 'placeholder', imagePath: '');
    }
    return _avatarBank.firstWhere(
      (preset) => preset.id == avatarId,
      orElse: () => _avatarBank.first,
    );
  }

  Future<void> _selectAvatar(String avatarId) async {
    await context.read<QuizProvider>().setProfileAvatar(avatarId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).profileAvatarUpdated)),
    );
  }

  int _requiredLevelForAvatarIndex(int index) => 1 + (index ~/ 2);

  Future<void> _openAvatarPicker(String? selectedAvatarId, int userLevel) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AvatarPickerSheet(
        avatarBank: _avatarBank,
        selectedAvatarId: selectedAvatarId,
        userLevel: userLevel,
        onSelected: _selectAvatar,
        requiredLevelForIndex: _requiredLevelForAvatarIndex,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return AppScaffold(
      title: l.profileTitle,
      child: SafeArea(
        child: Builder(
          builder: (context) {
            if (_avatarBank.isEmpty) {
              return Center(
                child: AppSurfaceCard(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.hide_image_outlined, size: 42, color: AppColors.muted),
                      const SizedBox(height: 16),
                      Text(
                        l.profileNoAvatar,
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l.profileNoAvatarHint,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.muted,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            final selectedAvatarId = context.select((QuizProvider p) => p.profileAvatarId);
            final selectedPreset = _resolveAvatar(selectedAvatarId);
            final level = context.select((QuizProvider p) => p.level);
            final levelXp = context.select((QuizProvider p) => p.experiencePointsInCurrentLevel);
            final xpPerLevel = context.select((QuizProvider p) => p.xpPerLevel);
            final recentResults = context.select(
              (QuizProvider p) => p.results.reversed.take(10).toList(),
            );

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppSurfaceCard(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () => _openAvatarPicker(selectedAvatarId, level),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.2),
                                  blurRadius: 24,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 64,
                              backgroundColor: AppColors.primary.withValues(alpha: 0.14),
                              child: ClipOval(
                                child: Image.asset(
                                  selectedPreset.imagePath,
                                  width: 128,
                                  height: 128,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          l.profileMyProfile,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.stars_rounded, color: AppColors.secondary),
                                  const SizedBox(width: 8),
                                  Text(
                                    l.profileLevel(level),
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    l.profileXp(levelXp, xpPerLevel),
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.muted,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: LinearProgressIndicator(
                                  minHeight: 9,
                                  value: levelXp / xpPerLevel,
                                  backgroundColor: AppColors.border,
                                  valueColor: const AlwaysStoppedAnimation<Color>(
                                    AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l.profileHistory,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (recentResults.isEmpty)
                    AppSurfaceCard(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.history_rounded, color: AppColors.muted, size: 28),
                            const SizedBox(width: 12),
                            Text(
                              l.profileNoHistory,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    AppSurfaceCard(
                      child: Column(
                        children: [
                          for (int i = 0; i < recentResults.length; i++) ...[
                            if (i > 0) const Divider(height: 1, color: AppColors.border),
                            _QuizHistoryRow(
                              result: recentResults[i],
                              themeName: context
                                      .read<QuizProvider>()
                                      .getThemeById(recentResults[i].themeId)
                                      ?.name ??
                                  l.profileThemeDeleted,
                              onTap: () {
                                final theme = context
                                    .read<QuizProvider>()
                                    .getThemeById(recentResults[i].themeId);
                                if (theme == null) return;
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ResultScreen(
                                      theme: theme,
                                      totalQuestions: recentResults[i].totalQuestions,
                                      correctAnswers: recentResults[i].correctAnswers,
                                      questions: const [],
                                      userAnswers: const {},
                                      isHistoryView: true,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Ligne d'historique affichant le score, le thème et la date d'un [QuizResult].
class _QuizHistoryRow extends StatelessWidget {
  final QuizResult result;
  final String themeName;
  final VoidCallback? onTap;

  const _QuizHistoryRow({required this.result, required this.themeName, this.onTap});

  Color _scoreColor(double percentage) {
    if (percentage >= 80) return AppColors.primary;
    if (percentage >= 50) return AppColors.secondary;
    return AppColors.accent;
  }

  String _formatDate(DateTime date) {
    final d = date.toLocal();
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    final hour = d.hour.toString().padLeft(2, '0');
    final minute = d.minute.toString().padLeft(2, '0');
    return '$day/$month/${d.year} à $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final pct = result.percentage;
    final color = _scoreColor(pct);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '${pct.round()}%',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    themeName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(result.completedAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${result.correctAnswers}/${result.totalQuestions}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
