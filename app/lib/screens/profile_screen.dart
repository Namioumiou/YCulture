import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/quiz_provider.dart';
import '../ui/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const String _avatarDirectory = 'assets/avatars/';
  List<_AvatarPreset> _avatarBank = const [];

  @override
  void initState() {
    super.initState();
    _loadAvatarBank();
  }

  Future<void> _loadAvatarBank() async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final avatarAssets = manifest.listAssets()
        .where(
          (asset) =>
              asset.startsWith(_avatarDirectory) &&
              (asset.endsWith('.png') || asset.endsWith('.jpg') || asset.endsWith('.jpeg') || asset.endsWith('.webp')),
        )
        .toList()
      ..sort();

    if (!mounted) {
      return;
    }

    setState(() {
      _avatarBank = avatarAssets
          .map(
            (assetPath) => _AvatarPreset(
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

  _AvatarPreset _resolveAvatar(String? avatarId) {
    if (_avatarBank.isEmpty) {
      return const _AvatarPreset(
        id: 'placeholder',
        imagePath: '',
      );
    }

    return _avatarBank.firstWhere(
      (preset) => preset.id == avatarId,
      orElse: () => _avatarBank.first,
    );
  }

  Future<void> _selectAvatar(String avatarId) async {
    await context.read<QuizProvider>().setProfileAvatar(avatarId);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Avatar mis a jour')),
    );
  }

  Future<void> _openAvatarPicker(String? selectedAvatarId) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: AppSurfaceCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Choisir un avatar',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Selectionnez un avatar depuis la banque integree.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.muted,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _avatarBank.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemBuilder: (context, index) {
                      final avatar = _avatarBank[index];
                      final isSelected = avatar.id == selectedAvatarId;

                      return InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () async {
                          Navigator.of(modalContext).pop();
                          await _selectAvatar(avatar.id);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : AppColors.border,
                              width: isSelected ? 2.2 : 1,
                            ),
                          ),
                          child: Container(
                            margin: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Image.asset(
                              avatar.imagePath,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Profil',
      child: SafeArea(
        child: Consumer<QuizProvider>(
          builder: (context, quizProvider, _) {
            if (_avatarBank.isEmpty) {
              return Center(
                child: AppSurfaceCard(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.hide_image_outlined,
                        size: 42,
                        color: AppColors.muted,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aucun avatar disponible',
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ajoutez des images dans assets/avatars pour les afficher ici.',
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

            final selectedAvatarId = quizProvider.profileAvatarId;
            final selectedPreset = _resolveAvatar(selectedAvatarId);

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppSurfaceCard(
                    child: Column(
                      children: [
                        Container(
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
                        const SizedBox(height: 20),
                        Text(
                          'Mon profil',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Choisissez un avatar depuis la banque integree a l\'application.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.muted,
                              ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _openAvatarPicker(selectedAvatarId),
                            icon: const Icon(Icons.edit_outlined),
                            label: const Text('Modifier l\'avatar'),
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
    );
  }
}

class _AvatarPreset {
  final String id;
  final String imagePath;

  const _AvatarPreset({
    required this.id,
    required this.imagePath,
  });
}
