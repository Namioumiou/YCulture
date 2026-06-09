import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../ui/app_theme.dart';

/// Métadonnées d'un avatar disponible dans la galerie de sélection.
class AvatarPreset {
  /// Identifiant unique dérivé du nom de fichier (sans extension).
  final String id;

  /// Chemin d'asset Flutter (ex. `assets/avatars/cat.png`).
  final String imagePath;

  const AvatarPreset({required this.id, required this.imagePath});
}

/// Feuille modale de sélection d'avatar avec verrouillage par niveau.
///
/// Affiche une grille d'[AvatarPreset] ; les avatars dont le niveau requis
/// dépasse [userLevel] sont verrouillés et affichent un cadenas.
/// Se ferme automatiquement après la sélection et appelle [onSelected].
class AvatarPickerSheet extends StatelessWidget {
  final List<AvatarPreset> avatarBank;
  final String? selectedAvatarId;
  final int userLevel;
  final ValueChanged<String> onSelected;

  /// Retourne le niveau minimum requis pour débloquer l'avatar à [index].
  final int Function(int index) requiredLevelForIndex;

  const AvatarPickerSheet({
    super.key,
    required this.avatarBank,
    required this.selectedAvatarId,
    required this.userLevel,
    required this.onSelected,
    required this.requiredLevelForIndex,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: AppSurfaceCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l.avatarPickerTitle,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l.avatarPickerSubtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: avatarBank.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  final avatar = avatarBank[index];
                  final isSelected = avatar.id == selectedAvatarId;
                  final requiredLevel = requiredLevelForIndex(index);
                  final isUnlocked = userLevel >= requiredLevel;

                  return InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      if (!isUnlocked) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l.avatarPickerLocked(requiredLevel))),
                        );
                        return;
                      }
                      Navigator.of(context).pop();
                      onSelected(avatar.id);
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
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Opacity(
                              opacity: isUnlocked ? 1 : 0.32,
                              child: Image.asset(avatar.imagePath, fit: BoxFit.cover),
                            ),
                            if (!isUnlocked)
                              Container(
                                color: Colors.black.withValues(alpha: 0.2),
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.lock_rounded, color: Colors.white, size: 20),
                                    const SizedBox(height: 4),
                                    Text(
                                      l.avatarPickerLevelBadge(requiredLevel),
                                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
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
  }
}
