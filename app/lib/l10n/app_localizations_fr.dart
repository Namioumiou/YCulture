// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'YCulture';

  @override
  String get homeWelcome =>
      'Bienvenue sur YCulture, votre application de quiz personnalisable !';

  @override
  String get homePlayNow => 'Jouer maintenant';

  @override
  String get homePlaySubtitle => 'Parcourir les thèmes disponibles';

  @override
  String get homeCreateTheme => 'Créer un thème';

  @override
  String get homeCreateThemeSubtitle =>
      'Ajouter une nouvelle catégorie de quiz';

  @override
  String get homeCreateQuestion => 'Créer une question';

  @override
  String get homeCreateQuestionSubtitle => 'Texte, image ou audio';

  @override
  String get homeMyProfile => 'Mon profil';

  @override
  String get homeMyProfileSubtitle => 'Modifier votre avatar utilisateur';

  @override
  String homeThemesCount(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString thèmes',
      one: '1 thème',
      zero: '0 thème',
    );
    return '$_temp0';
  }

  @override
  String homeQuestionsCount(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString questions',
      one: '1 question',
      zero: '0 question',
    );
    return '$_temp0';
  }

  @override
  String homeResultsCount(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString résultats',
      one: '1 résultat',
      zero: '0 résultat',
    );
    return '$_temp0';
  }

  @override
  String homeLevelBadge(int level) {
    return 'Niv. $level';
  }

  @override
  String get themeSelectionTitle => 'Choisissez un thème';

  @override
  String get themeNoThemesTitle => 'Aucun thème disponible';

  @override
  String get themeNoThemesSubtitle =>
      'Créez votre premier thème pour commencer à jouer.';

  @override
  String get themeNoQuestionsSnack =>
      'Ce thème ne contient pas encore de questions.';

  @override
  String get themeManageTooltip => 'Gérer le thème';

  @override
  String themeQuestionCount(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString questions',
      one: '1 question',
      zero: 'Aucune question',
    );
    return '$_temp0';
  }

  @override
  String themeQuestionsInTheme(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString questions dans ce thème',
      one: '1 question dans ce thème',
      zero: 'Aucune question dans ce thème',
    );
    return '$_temp0';
  }

  @override
  String get themeQuestionsNone =>
      'Aucune question dans ce thème pour le moment.';

  @override
  String get themeDeleteTitle => 'Supprimer la question ?';

  @override
  String themeDeleteConfirm(String questionText) {
    return 'Cette action est irréversible.\n\n\"$questionText\"';
  }

  @override
  String get themeDeleteCancel => 'Annuler';

  @override
  String get themeDeleteButton => 'Supprimer';

  @override
  String get themeDeleteSuccess => 'Question supprimée';

  @override
  String get themeEditAction => 'Modifier';

  @override
  String get quizNoQuestions => 'Aucune question disponible';

  @override
  String quizQuestionCounter(int current, int total) {
    return 'Question $current/$total';
  }

  @override
  String get quizYourAnswer => 'Votre réponse';

  @override
  String get quizAnswerSubtitleSingle => 'Sélectionnez une seule réponse.';

  @override
  String get quizAnswerSubtitleMultiple =>
      'Sélectionnez une ou plusieurs réponses.';

  @override
  String get quizAnswerSubtitleOpen => 'Saisissez votre réponse.';

  @override
  String get quizAudioPlaying => 'Lecture audio en cours';

  @override
  String get quizAudioPrompt => 'Appuyez pour écouter l\'indice audio';

  @override
  String get quizAudioNotFound =>
      'Le fichier audio est introuvable sur cet appareil.';

  @override
  String get quizAudioError => 'Impossible de lire ce fichier audio.';

  @override
  String get quizImageError => 'Impossible de charger l\'image';

  @override
  String get quizAnswerHint => 'Votre réponse...';

  @override
  String get quizValidate => 'Valider';

  @override
  String get quizFinish => 'Terminer';

  @override
  String get resultsTitle => 'Résultats';

  @override
  String get resultsQuizDone => 'Quiz terminé';

  @override
  String get resultsCorrectLabel => 'Correctes';

  @override
  String get resultsIncorrectLabel => 'Incorrectes';

  @override
  String get resultsTotalLabel => 'Total';

  @override
  String get resultsProgression => 'Progression';

  @override
  String resultsXpGained(int amount) {
    return '+$amount XP';
  }

  @override
  String resultsLevelUp(int level) {
    return 'Bravo ! Niveau $level atteint.';
  }

  @override
  String resultsCurrentLevel(int level) {
    return 'Niveau actuel : $level';
  }

  @override
  String resultsXpToNextLevel(int current, int max) {
    return '$current/$max XP vers le niveau suivant';
  }

  @override
  String get resultsDetailedReview => 'Corrigé détaillé';

  @override
  String get resultsDetailedReviewSubtitle =>
      'Comparez votre réponse avec la bonne réponse pour chaque question.';

  @override
  String resultsQuestionNumber(int number) {
    return 'Question $number';
  }

  @override
  String get resultsCorrect => 'Correct';

  @override
  String get resultsIncorrect => 'Incorrect';

  @override
  String get resultsYourAnswerLabel => 'Votre réponse';

  @override
  String get resultsCorrectAnswerLabel => 'Bonne réponse';

  @override
  String get resultsNoAnswer => 'Aucune réponse';

  @override
  String get resultsNoAnswerDefined => 'Aucune réponse définie';

  @override
  String get resultsRetry => 'Refaire le quiz';

  @override
  String get resultsBackHome => 'Retour à l\'accueil';

  @override
  String get resultsBack => 'Retour';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileNoAvatar => 'Aucun avatar disponible';

  @override
  String get profileNoAvatarHint =>
      'Ajoutez des images dans assets/avatars pour les afficher ici.';

  @override
  String get profileMyProfile => 'Mon profil';

  @override
  String profileLevel(int level) {
    return 'Niveau $level';
  }

  @override
  String profileXp(int current, int max) {
    return '$current/$max XP';
  }

  @override
  String get profileAvatarUpdated => 'Avatar mis à jour';

  @override
  String get profileHistory => 'Historique des quizz';

  @override
  String get profileNoHistory => 'Aucun quizz effectué pour l\'instant.';

  @override
  String get profileThemeDeleted => 'Thème supprimé';

  @override
  String get avatarPickerTitle => 'Choisir un avatar';

  @override
  String get avatarPickerSubtitle =>
      'Certains avatars se débloquent avec votre niveau.';

  @override
  String avatarPickerLocked(int level) {
    return 'Cet avatar se débloque au niveau $level.';
  }

  @override
  String avatarPickerLevelBadge(int level) {
    return 'Niv. $level';
  }

  @override
  String get createThemeTitle => 'Créer un thème';

  @override
  String get createThemeNameLabel => 'Nom du thème';

  @override
  String get createThemeNameHint => 'Ex: Géographie mondiale';

  @override
  String get createThemeNameError => 'Veuillez entrer un nom';

  @override
  String get createThemeDescLabel => 'Description';

  @override
  String get createThemeDescHint => 'Décrivez le contenu du thème';

  @override
  String get createThemeDescError => 'Veuillez entrer une description';

  @override
  String get createThemeButton => 'Créer le thème';

  @override
  String get createThemeSuccess => 'Thème créé avec succès !';

  @override
  String get questionFormCreateTitle => 'Créer une question';

  @override
  String get questionFormEditTitle => 'Modifier la question';

  @override
  String get questionFormNoTheme =>
      'Vous devez d\'abord créer un thème avant d\'ajouter des questions.';

  @override
  String get questionFormQuestionTypeLabel => 'Type de question';

  @override
  String get questionFormAnswerTypeLabel => 'Type de réponse';

  @override
  String get questionFormQuestionLabel => 'Question';

  @override
  String get questionFormQuestionHint => 'Entrez votre question';

  @override
  String get questionFormQuestionError => 'Veuillez entrer une question';

  @override
  String get questionFormThemeLabel => 'Thème';

  @override
  String get questionFormThemeError => 'Veuillez sélectionner un thème';

  @override
  String get questionFormAddImage => 'Ajouter une image';

  @override
  String get questionFormImageSelected => 'Image sélectionnée';

  @override
  String get questionFormExpectedAnswersLabel =>
      'Réponses attendues (séparées par ;)';

  @override
  String get questionFormExpectedAnswersHint => 'ex: Paris; paris';

  @override
  String get questionFormSave => 'Enregistrer';

  @override
  String get questionFormCreate => 'Créer la question';

  @override
  String get questionFormSuccess => 'Question créée avec succès !';

  @override
  String get questionFormEditSuccess => 'Question modifiée avec succès';

  @override
  String get questionFormSelectTheme => 'Veuillez sélectionner un thème';

  @override
  String get questionFormSelectAudio =>
      'Veuillez sélectionner un fichier audio';

  @override
  String get questionFormStopRecording =>
      'Arrêtez l\'enregistrement avant d\'enregistrer la question.';

  @override
  String get questionFormMinAnswer =>
      'Veuillez entrer au moins une réponse attendue';

  @override
  String get questionFormSelectCorrect =>
      'Veuillez sélectionner au moins une bonne réponse';

  @override
  String get answerTypeOpen => 'Ouverte';

  @override
  String get answerTypeSingle => 'Choix';

  @override
  String get answerTypeMultiple => 'Multiple';

  @override
  String get questionTypeText => 'Texte';

  @override
  String get questionTypeImage => 'Image';

  @override
  String get questionTypeAudio => 'Audio';

  @override
  String get audioImport => 'Importer un fichier audio';

  @override
  String get audioSelected => 'Audio sélectionné';

  @override
  String get audioRecord => 'Enregistrer un audio';

  @override
  String get audioStop => 'Arrêter l\'enregistrement';

  @override
  String get audioRecordingLabel => 'Enregistrement en cours...';

  @override
  String audioFileLabel(String name) {
    return 'Fichier : $name';
  }

  @override
  String get audioStopFirst =>
      'Arrêtez l\'enregistrement avant d\'importer un audio.';

  @override
  String get audioPermission =>
      'L\'accès au microphone est nécessaire pour enregistrer.';

  @override
  String get audioNoFile => 'Aucun fichier audio n\'a été généré.';

  @override
  String get audioRetrieveError => 'Impossible de récupérer ce fichier audio.';

  @override
  String get choiceAnswersLabel => 'Réponses possibles';

  @override
  String get choiceAddButton => 'Ajouter';

  @override
  String choiceHint(int number) {
    return 'Réponse $number';
  }

  @override
  String get choiceRequired => 'Réponse requise';

  @override
  String get choiceSelectOne => 'Cochez la bonne réponse';

  @override
  String get choiceSelectMultiple => 'Cochez toutes les bonnes réponses';
}
