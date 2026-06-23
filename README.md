# YCulture

Application mobile de quiz personnalisable, développée en Flutter dans le cadre du cours Mobile M2 à Ynov.

---

## Sommaire

1. [Présentation](#présentation)
2. [Fonctionnalités](#fonctionnalités)
3. [Architecture du projet](#architecture-du-projet)
4. [Modèles de données](#modèles-de-données)
5. [État global — QuizProvider](#état-global--quizprovider)
6. [Écrans](#écrans)
7. [Système d'XP et de niveaux](#système-dxp-et-de-niveaux)
8. [Thème visuel](#thème-visuel)
9. [Dépendances](#dépendances)
10. [Lancer le projet](#lancer-le-projet)
11. [Tests](#tests)

---

## Présentation

**YCulture** est une application de quiz mobile complète qui permet à l'utilisateur de :
- jouer à des quiz organisés par thèmes,
- créer ses propres thèmes et questions (texte, image, audio),
- suivre sa progression via un système d'expérience (XP) et de niveaux,
- personnaliser son profil avec un avatar.

Toutes les données sont stockées **localement** sur l'appareil grâce à `shared_preferences` — aucun backend n'est requis.

---

## Fonctionnalités

| Fonctionnalité | Description |
|---|---|
| **Quiz par thème** | Sélectionner un thème et répondre à toutes ses questions |
| **3 types de questions** | Texte seul, avec image, avec fichier audio |
| **3 types de réponses** | Choix unique, choix multiple, réponse ouverte (saisie libre) |
| **Création de thèmes** | Nom, description et icône optionnelle |
| **Création de questions** | Éditeur complet avec media picker (image / audio) |
| **Édition / suppression de questions** | Modifier ou supprimer des questions depuis la gestion d'un thème |
| **Résultats détaillés** | Score, pourcentage, revue question par question |
| **Système XP / Niveaux** | Gagner de l'XP après chaque quiz, monter de niveau |
| **Profil & avatar** | Choisir un avatar parmi une banque d'images prédéfinies |
| **Persistance locale** | Toutes les données survivent au redémarrage de l'app |
| **Historique détaillé** | Consulter la revue complète d'un quiz passé depuis le profil |
| **Avatars déverrouillables** | Les avatars se débloquent en montant de niveau |

---

## Architecture du projet

```
app/
├── lib/
│   ├── main.dart                  # Point d'entrée, configuration du Provider et du thème
│   ├── models/
│   │   ├── question.dart          # Modèle Question + enums QuestionType / AnswerType
│   │   ├── quiz_result.dart       # Modèle QuizResult (score, date, snapshot des réponses)
│   │   └── theme.dart             # Modèle QuizTheme
│   ├── providers/
│   │   └── quiz_provider.dart     # État global (thèmes, questions, résultats, XP)
│   ├── screens/
│   │   ├── home_screen.dart       # Accueil avec raccourcis de navigation
│   │   ├── theme_selection_screen.dart  # Liste des thèmes jouables
│   │   ├── quiz_screen.dart       # Déroulement du quiz (une question à la fois)
│   │   ├── result_screen.dart     # Résultats, XP gagné, revue des réponses
│   │   ├── profile_screen.dart    # Profil : niveau, XP, historique, avatar
│   │   ├── create_theme_screen.dart    # Formulaire de création de thème
│   │   ├── create_question_screen.dart # Écran de création (délègue à QuestionForm)
│   │   └── edit_question_screen.dart   # Écran d'édition (délègue à QuestionForm)
│   ├── widgets/
│   │   └── question_form.dart     # Formulaire partagé création / édition de question
│   └── ui/
│       └── app_theme.dart         # Palette de couleurs, typographie, ThemeData global
├── assets/
│   └── avatars/                   # Images d'avatars incluses dans le bundle
├── test/
│   └── widget_test.dart           # Test widget de démarrage (écran d'accueil)
└── pubspec.yaml
```

Le pattern d'état choisi est **Provider** (`ChangeNotifier`). Un seul `QuizProvider` est placé en haut de l'arbre de widgets dans `main.dart` et est consommé par tous les écrans.

---

## Modèles de données

### `QuizTheme`

Représente une catégorie de quiz.

| Champ | Type | Description |
|---|---|---|
| `id` | `String` | Identifiant UUID unique |
| `name` | `String` | Nom du thème |
| `description` | `String` | Description courte |
| `iconUrl` | `String?` | Chemin vers une image d'icône (optionnel) |

### `Question`

Représente une question appartenant à un thème.

| Champ | Type | Description |
|---|---|---|
| `id` | `String` | Identifiant UUID unique |
| `text` | `String` | Énoncé de la question |
| `imageUrl` | `String?` | Chemin vers une image (optionnel) |
| `audioUrl` | `String?` | Chemin vers un fichier audio (optionnel) |
| `questionType` | `QuestionType` | `text`, `image` ou `audio` |
| `answerType` | `AnswerType` | `open`, `singleChoice` ou `multipleChoice` |
| `choices` | `List<String>` | Propositions (vide si réponse ouverte) |
| `correctAnswers` | `List<String>` | Réponse(s) correcte(s) |
| `themeId` | `String` | Référence au thème parent |

**`QuestionType`** — décrit le media attaché à la question :
- `text` : question textuelle uniquement
- `image` : question accompagnée d'une image
- `audio` : question accompagnée d'un enregistrement audio

**`AnswerType`** — décrit le mode de réponse :
- `singleChoice` : l'utilisateur sélectionne une seule proposition
- `multipleChoice` : l'utilisateur sélectionne une ou plusieurs propositions
- `open` : l'utilisateur saisit librement sa réponse (comparaison insensible à la casse)

### `QuizResult`

Enregistre le résultat d'une session de quiz.

| Champ | Type | Description |
|---|---|---|
| `themeId` | `String` | Thème joué |
| `totalQuestions` | `int` | Nombre total de questions |
| `correctAnswers` | `int` | Nombre de bonnes réponses |
| `completedAt` | `DateTime` | Date et heure de la session |
| `questions` | `List<Question>` | Snapshot des questions jouées (pour l'historique) |
| `userAnswers` | `Map<int, dynamic>` | Réponses de l'utilisateur, indexées par numéro de question |

La propriété calculée `percentage` retourne le score en pourcentage.

Les champs `questions` et `userAnswers` sont sérialisés avec le résultat afin de permettre la revue détaillée depuis l'historique du profil. Les entrées enregistrées avant cette évolution n'ont pas de snapshot : seul le score reste consultable.

---

## État global — QuizProvider

`QuizProvider` étend `ChangeNotifier` et centralise l'intégralité de l'état de l'application.

### Responsabilités

- **Chargement** : lit les données JSON stockées dans `SharedPreferences` au démarrage. Si aucune donnée n'existe, initialise un thème "Culture Générale" avec 3 questions d'exemple, puis **persiste immédiatement** ce jeu de données par défaut.
- **Persistance** : réécrit l'intégralité des données dans `SharedPreferences` à chaque mutation. Les méthodes de modification (`addTheme`, `updateTheme`, `deleteTheme`, `addQuestion`, `updateQuestion`, `deleteQuestion`, `addResult`, `setProfileAvatar`, `clearProfileAvatar`) sont **asynchrones** (`Future`) et attendent la fin de l'écriture. En cas d'échec, l'erreur est journalisée puis propagée pour que l'interface puisse réagir.
- **CRUD thèmes** : `addTheme`, `updateTheme`, `deleteTheme` (supprime aussi les questions associées). L'édition et la suppression de thèmes sont exposées au niveau du provider ; l'interface ne propose pour l'instant que la création de thèmes.
- **CRUD questions** : `addQuestion`, `updateQuestion`, `deleteQuestion`.
- **Résultats** : `addResult` enregistre la session (y compris le snapshot questions / réponses), calcule le gain d'XP et persiste.
- **Profil** : `setProfileAvatar` / `clearProfileAvatar` pour l'avatar.

### Propriétés exposées

| Propriété | Description |
|---|---|
| `isLoaded` | `true` une fois le chargement initial terminé |
| `themes` | Liste immuable de `QuizTheme` |
| `questions` | Liste immuable de `Question` |
| `results` | Liste immuable de `QuizResult` |
| `level` | Niveau courant du joueur |
| `experiencePoints` | XP total accumulé |
| `experiencePointsInCurrentLevel` | XP progressé dans le niveau courant |
| `xpPerLevel` | XP requis pour passer au niveau suivant |
| `profileAvatarId` | Identifiant de l'avatar sélectionné |

---

## Écrans

### `HomeScreen`
Écran d'accueil. Affiche un résumé (nombre de thèmes, questions, résultats, niveau) et des boutons de navigation vers les fonctionnalités principales. L'avatar du profil est accessible depuis le coin supérieur droit.

### `ThemeSelectionScreen`
Liste tous les thèmes disponibles sous forme de cartes. Chaque carte affiche le nom, la description et le nombre de questions. Un appui lance le quiz ; une icône d'engrenage ouvre la gestion des questions du thème (édition, suppression, ajout).

### `QuizScreen`
Cœur du jeu. Affiche les questions une par une avec :
- rendu adapté selon `QuestionType` (texte, image affichée, lecteur audio intégré),
- composant de saisie adapté selon `AnswerType` (boutons radio, cases à cocher, champ texte libre),
- barre de progression indiquant la question courante.

À la dernière question, calcule le score et navigue vers `ResultScreen`.

### `ResultScreen`
Affiche le score final (pourcentage, fraction correcte/totale) avec une palette de couleurs contextuelle (vert si bon score, orange, rouge). Montre le gain d'XP et une éventuelle montée de niveau. Propose une revue détaillée question par question avec la réponse de l'utilisateur et la bonne réponse. Boutons pour **rejouer** le même quiz ou retourner à l'accueil.

Cet écran est également utilisable en mode **lecture seule** (`isHistoryView: true`) pour consulter le détail d'un quiz passé depuis l'historique du profil, sans recalculer l'XP. Le corrigé détaillé s'appuie sur le snapshot `questions` / `userAnswers` stocké dans `QuizResult`.

### `ProfileScreen`
Affiche le niveau, la barre de progression d'XP, et l'historique des **10 derniers quiz** joués (thème, score, date). Un appui sur une entrée de l'historique ouvre la revue détaillée du quiz correspondant (`ResultScreen` en mode lecture seule).

Permet de sélectionner un avatar parmi la banque d'images dans `assets/avatars/`. Les avatars sont **déverrouillés par niveau** : un nouvel avatar se débloque tous les deux emplacements (niveau 1 = avatars 1-2, niveau 2 = avatars 3-4, etc.).

### `CreateThemeScreen`
Formulaire de création d'un thème (nom, description). Génère un UUID et sauvegarde via `QuizProvider.addTheme`.

### `QuestionForm` (`widgets/question_form.dart`)
Widget partagé qui centralise le formulaire de création et d'édition d'une question :
- sélection du thème cible,
- choix du `QuestionType` (texte / image / audio),
- choix de l'`AnswerType` (choix unique / multiple / ouvert),
- ajout des propositions et des bonnes réponses,
- sélection d'image via `image_picker` ou d'audio via `file_picker` / `record`,
- validation des champs obligatoires avant soumission.

Expose un callback `onSubmit` appelé avec un objet `QuestionFormValues`.

### `CreateQuestionScreen`
Écran léger qui affiche `QuestionForm` en mode création. À la soumission, construit une `Question`, appelle `QuizProvider.addQuestion` et retourne à l'écran précédent.

### `EditQuestionScreen`
Écran léger qui affiche `QuestionForm` pré-rempli avec une question existante. À la soumission, appelle `QuizProvider.updateQuestion`. La suppression d'une question se fait depuis `ThemeSelectionScreen`.

---

## Système d'XP et de niveaux

Le système de progression est entièrement calculé côté client dans `QuizProvider`.

### Gain d'XP par session

| Événement | XP gagné |
|---|---|
| Participation (toute session) | +8 XP |
| Bonne réponse | +18 XP |
| Quiz parfait (100 %) | +30 XP bonus |

### Formule des niveaux

Le nombre d'XP requis pour progresser dans un niveau augmente linéairement :

$$\text{XP requis niveau } n = 150 + (n - 1) \times 50$$

Exemples :
- Niveau 1 → 2 : 150 XP
- Niveau 2 → 3 : 200 XP
- Niveau 3 → 4 : 250 XP

### Migration de version

Un mécanisme de migration (`_xpSystemVersion`) permet de convertir les XP des versions antérieures vers la formule courante sans perte de progression.

---

## Thème visuel

L'identité graphique est définie dans `lib/ui/app_theme.dart`.

### Palette de couleurs (`AppColors`)

| Nom | Valeur | Usage |
|---|---|---|
| `ink` | `#132238` | Texte principal, fond sombre |
| `primary` | `#1C6DD0` | Couleur d'action principale (bleu) |
| `secondary` | `#14B8A6` | Couleur secondaire (teal) |
| `accent` | `#FF8A5B` | Couleur d'accentuation (orange) |
| `canvas` | `#F6F8FC` | Fond de scaffold |
| `surface` | `#FFFFFF` | Fond des cartes |
| `muted` | `#66758C` | Textes secondaires |
| `border` | `#D7E1EF` | Bordures et séparateurs |

### Typographie

Police principale : **Manrope** (via `google_fonts`), avec des graisses allant de `w500` (corps) à `w800` (titres display).

---

## Dépendances

| Package | Version | Usage |
|---|---|---|
| `provider` | ^6.1.1 | Gestion d'état |
| `shared_preferences` | ^2.3.3 | Persistance locale |
| `uuid` | ^4.3.3 | Génération d'identifiants uniques |
| `google_fonts` | ^8.0.2 | Police Manrope |
| `image_picker` | ^1.0.7 | Sélection d'images depuis la galerie/caméra |
| `file_picker` | ^10.3.10 | Sélection de fichiers audio |
| `audioplayers` | ^6.5.1 | Lecture de fichiers audio dans le quiz |
| `record` | ^6.2.0 | Enregistrement audio lors de la création de questions |
| `path_provider` | ^2.1.5 | Accès aux répertoires du système de fichiers |

---

## Lancer le projet

### Prérequis

- Flutter SDK ≥ 3.10.0
- Android Studio ou un émulateur Android / appareil physique

### Commandes

```bash
# Installer les dépendances
cd app
flutter pub get

# Lancer sur un appareil connecté ou émulateur
flutter run

# Compiler un APK de release
flutter build apk --release
```

Les données de l'application sont stockées localement sur l'appareil. Aucune configuration de serveur ou de clé API n'est nécessaire.

---

## Tests

### Analyse statique

```bash
cd app
flutter analyze
```

### Tests automatisés

Un test widget de fumée vérifie le démarrage de l'application : affichage du chargement initial, puis de l'écran d'accueil.

```bash
cd app
flutter test
```

Le test mocke `SharedPreferences` avec des valeurs vides pour simuler une première installation.

### Vérifications manuelles recommandées

| Scénario | Attendu |
|---|---|
| Première installation | Le thème « Culture Générale » et ses 3 questions sont présents après redémarrage |
| Fin de quiz | Le corrigé détaillé s'affiche sur l'écran de résultats |
| Historique (profil) | Un appui sur un quiz récent rouvre le corrigé détaillé |
| Création / édition de question | Le formulaire partagé fonctionne pour les 3 types de questions et de réponses |
| Persistance | Thèmes, questions, avatar et historique survivent à un redémarrage de l'app |

