import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// Titre de l'application
  ///
  /// In fr, this message translates to:
  /// **'YCulture'**
  String get appTitle;

  /// No description provided for @homeWelcome.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue sur YCulture, votre application de quiz personnalisable ✨🎉'**
  String get homeWelcome;

  /// No description provided for @homePlayNow.
  ///
  /// In fr, this message translates to:
  /// **'Jouer maintenant'**
  String get homePlayNow;

  /// No description provided for @homePlaySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Parcourir les thèmes disponibles'**
  String get homePlaySubtitle;

  /// No description provided for @homeCreateTheme.
  ///
  /// In fr, this message translates to:
  /// **'Créer un thème'**
  String get homeCreateTheme;

  /// No description provided for @homeCreateThemeSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une nouvelle catégorie de quiz'**
  String get homeCreateThemeSubtitle;

  /// No description provided for @homeCreateQuestion.
  ///
  /// In fr, this message translates to:
  /// **'Créer une question'**
  String get homeCreateQuestion;

  /// No description provided for @homeCreateQuestionSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Texte, image ou audio'**
  String get homeCreateQuestionSubtitle;

  /// No description provided for @homeMyProfile.
  ///
  /// In fr, this message translates to:
  /// **'Mon profil'**
  String get homeMyProfile;

  /// No description provided for @homeMyProfileSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier votre avatar utilisateur'**
  String get homeMyProfileSubtitle;

  /// No description provided for @homeThemesCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{0 thème} =1{1 thème} other{{count} thèmes}}'**
  String homeThemesCount(num count);

  /// No description provided for @homeQuestionsCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{0 question} =1{1 question} other{{count} questions}}'**
  String homeQuestionsCount(num count);

  /// No description provided for @homeResultsCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{0 résultat} =1{1 résultat} other{{count} résultats}}'**
  String homeResultsCount(num count);

  /// No description provided for @homeLevelBadge.
  ///
  /// In fr, this message translates to:
  /// **'Niv. {level}'**
  String homeLevelBadge(int level);

  /// No description provided for @themeSelectionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez un thème'**
  String get themeSelectionTitle;

  /// No description provided for @themeNoThemesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucun thème disponible'**
  String get themeNoThemesTitle;

  /// No description provided for @themeNoThemesSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Créez votre premier thème pour commencer à jouer.'**
  String get themeNoThemesSubtitle;

  /// No description provided for @themeNoQuestionsSnack.
  ///
  /// In fr, this message translates to:
  /// **'Ce thème ne contient pas encore de questions.'**
  String get themeNoQuestionsSnack;

  /// No description provided for @themeManageTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Gérer le thème'**
  String get themeManageTooltip;

  /// No description provided for @themeQuestionCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucune question} =1{1 question} other{{count} questions}}'**
  String themeQuestionCount(num count);

  /// No description provided for @themeQuestionsInTheme.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucune question dans ce thème} =1{1 question dans ce thème} other{{count} questions dans ce thème}}'**
  String themeQuestionsInTheme(num count);

  /// No description provided for @themeQuestionsNone.
  ///
  /// In fr, this message translates to:
  /// **'Aucune question dans ce thème pour le moment.'**
  String get themeQuestionsNone;

  /// No description provided for @themeDeleteTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer la question ?'**
  String get themeDeleteTitle;

  /// No description provided for @themeDeleteConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Cette action est irréversible.\n\n\"{questionText}\"'**
  String themeDeleteConfirm(String questionText);

  /// No description provided for @themeDeleteCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get themeDeleteCancel;

  /// No description provided for @themeDeleteButton.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get themeDeleteButton;

  /// No description provided for @themeDeleteSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Question supprimée'**
  String get themeDeleteSuccess;

  /// No description provided for @themeEditAction.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get themeEditAction;

  /// No description provided for @quizNoQuestions.
  ///
  /// In fr, this message translates to:
  /// **'Aucune question disponible'**
  String get quizNoQuestions;

  /// No description provided for @quizQuestionCounter.
  ///
  /// In fr, this message translates to:
  /// **'Question {current}/{total}'**
  String quizQuestionCounter(int current, int total);

  /// No description provided for @quizYourAnswer.
  ///
  /// In fr, this message translates to:
  /// **'Votre réponse'**
  String get quizYourAnswer;

  /// No description provided for @quizAnswerSubtitleSingle.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionnez une seule réponse.'**
  String get quizAnswerSubtitleSingle;

  /// No description provided for @quizAnswerSubtitleMultiple.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionnez une ou plusieurs réponses.'**
  String get quizAnswerSubtitleMultiple;

  /// No description provided for @quizAnswerSubtitleOpen.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez votre réponse.'**
  String get quizAnswerSubtitleOpen;

  /// No description provided for @quizAudioPlaying.
  ///
  /// In fr, this message translates to:
  /// **'Lecture audio en cours'**
  String get quizAudioPlaying;

  /// No description provided for @quizAudioPrompt.
  ///
  /// In fr, this message translates to:
  /// **'Appuyez pour écouter l\'indice audio'**
  String get quizAudioPrompt;

  /// No description provided for @quizAudioNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Le fichier audio est introuvable sur cet appareil.'**
  String get quizAudioNotFound;

  /// No description provided for @quizAudioError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de lire ce fichier audio.'**
  String get quizAudioError;

  /// No description provided for @quizImageError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger l\'image'**
  String get quizImageError;

  /// No description provided for @quizAnswerHint.
  ///
  /// In fr, this message translates to:
  /// **'Votre réponse...'**
  String get quizAnswerHint;

  /// No description provided for @quizValidate.
  ///
  /// In fr, this message translates to:
  /// **'Valider'**
  String get quizValidate;

  /// No description provided for @quizFinish.
  ///
  /// In fr, this message translates to:
  /// **'Terminer'**
  String get quizFinish;

  /// No description provided for @resultsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Résultats'**
  String get resultsTitle;

  /// No description provided for @resultsQuizDone.
  ///
  /// In fr, this message translates to:
  /// **'Quiz terminé'**
  String get resultsQuizDone;

  /// No description provided for @resultsCorrectLabel.
  ///
  /// In fr, this message translates to:
  /// **'Correctes'**
  String get resultsCorrectLabel;

  /// No description provided for @resultsIncorrectLabel.
  ///
  /// In fr, this message translates to:
  /// **'Incorrectes'**
  String get resultsIncorrectLabel;

  /// No description provided for @resultsTotalLabel.
  ///
  /// In fr, this message translates to:
  /// **'Total'**
  String get resultsTotalLabel;

  /// No description provided for @resultsProgression.
  ///
  /// In fr, this message translates to:
  /// **'Progression'**
  String get resultsProgression;

  /// No description provided for @resultsXpGained.
  ///
  /// In fr, this message translates to:
  /// **'+{amount} XP'**
  String resultsXpGained(int amount);

  /// No description provided for @resultsLevelUp.
  ///
  /// In fr, this message translates to:
  /// **'Bravo ! Niveau {level} atteint.'**
  String resultsLevelUp(int level);

  /// No description provided for @resultsCurrentLevel.
  ///
  /// In fr, this message translates to:
  /// **'Niveau actuel : {level}'**
  String resultsCurrentLevel(int level);

  /// No description provided for @resultsXpToNextLevel.
  ///
  /// In fr, this message translates to:
  /// **'{current}/{max} XP vers le niveau suivant'**
  String resultsXpToNextLevel(int current, int max);

  /// No description provided for @resultsDetailedReview.
  ///
  /// In fr, this message translates to:
  /// **'Corrigé détaillé'**
  String get resultsDetailedReview;

  /// No description provided for @resultsDetailedReviewSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Comparez votre réponse avec la bonne réponse pour chaque question.'**
  String get resultsDetailedReviewSubtitle;

  /// No description provided for @resultsQuestionNumber.
  ///
  /// In fr, this message translates to:
  /// **'Question {number}'**
  String resultsQuestionNumber(int number);

  /// No description provided for @resultsCorrect.
  ///
  /// In fr, this message translates to:
  /// **'Correct'**
  String get resultsCorrect;

  /// No description provided for @resultsIncorrect.
  ///
  /// In fr, this message translates to:
  /// **'Incorrect'**
  String get resultsIncorrect;

  /// No description provided for @resultsYourAnswerLabel.
  ///
  /// In fr, this message translates to:
  /// **'Votre réponse'**
  String get resultsYourAnswerLabel;

  /// No description provided for @resultsCorrectAnswerLabel.
  ///
  /// In fr, this message translates to:
  /// **'Bonne réponse'**
  String get resultsCorrectAnswerLabel;

  /// No description provided for @resultsNoAnswer.
  ///
  /// In fr, this message translates to:
  /// **'Aucune réponse'**
  String get resultsNoAnswer;

  /// No description provided for @resultsNoAnswerDefined.
  ///
  /// In fr, this message translates to:
  /// **'Aucune réponse définie'**
  String get resultsNoAnswerDefined;

  /// No description provided for @resultsRetry.
  ///
  /// In fr, this message translates to:
  /// **'Refaire le quiz'**
  String get resultsRetry;

  /// No description provided for @resultsBackHome.
  ///
  /// In fr, this message translates to:
  /// **'Retour à l\'accueil'**
  String get resultsBackHome;

  /// No description provided for @resultsBack.
  ///
  /// In fr, this message translates to:
  /// **'Retour'**
  String get resultsBack;

  /// No description provided for @profileTitle.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get profileTitle;

  /// No description provided for @profileNoAvatar.
  ///
  /// In fr, this message translates to:
  /// **'Aucun avatar disponible'**
  String get profileNoAvatar;

  /// No description provided for @profileNoAvatarHint.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez des images dans assets/avatars pour les afficher ici.'**
  String get profileNoAvatarHint;

  /// No description provided for @profileMyProfile.
  ///
  /// In fr, this message translates to:
  /// **'Mon profil'**
  String get profileMyProfile;

  /// No description provided for @profileLevel.
  ///
  /// In fr, this message translates to:
  /// **'Niveau {level}'**
  String profileLevel(int level);

  /// No description provided for @profileXp.
  ///
  /// In fr, this message translates to:
  /// **'{current}/{max} XP'**
  String profileXp(int current, int max);

  /// No description provided for @profileAvatarUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Avatar mis à jour'**
  String get profileAvatarUpdated;

  /// No description provided for @profileHistory.
  ///
  /// In fr, this message translates to:
  /// **'Historique des quizz'**
  String get profileHistory;

  /// No description provided for @profileNoHistory.
  ///
  /// In fr, this message translates to:
  /// **'Aucun quizz effectué pour l\'instant.'**
  String get profileNoHistory;

  /// No description provided for @profileThemeDeleted.
  ///
  /// In fr, this message translates to:
  /// **'Thème supprimé'**
  String get profileThemeDeleted;

  /// No description provided for @avatarPickerTitle.
  ///
  /// In fr, this message translates to:
  /// **'Choisir un avatar'**
  String get avatarPickerTitle;

  /// No description provided for @avatarPickerSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Certains avatars se débloquent avec votre niveau.'**
  String get avatarPickerSubtitle;

  /// No description provided for @avatarPickerLocked.
  ///
  /// In fr, this message translates to:
  /// **'Cet avatar se débloque au niveau {level}.'**
  String avatarPickerLocked(int level);

  /// No description provided for @avatarPickerLevelBadge.
  ///
  /// In fr, this message translates to:
  /// **'Niv. {level}'**
  String avatarPickerLevelBadge(int level);

  /// No description provided for @createThemeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Créer un thème'**
  String get createThemeTitle;

  /// No description provided for @createThemeNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom du thème'**
  String get createThemeNameLabel;

  /// No description provided for @createThemeNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex: Géographie mondiale'**
  String get createThemeNameHint;

  /// No description provided for @createThemeNameError.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer un nom'**
  String get createThemeNameError;

  /// No description provided for @createThemeDescLabel.
  ///
  /// In fr, this message translates to:
  /// **'Description'**
  String get createThemeDescLabel;

  /// No description provided for @createThemeDescHint.
  ///
  /// In fr, this message translates to:
  /// **'Décrivez le contenu du thème'**
  String get createThemeDescHint;

  /// No description provided for @createThemeDescError.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer une description'**
  String get createThemeDescError;

  /// No description provided for @createThemeButton.
  ///
  /// In fr, this message translates to:
  /// **'Créer le thème'**
  String get createThemeButton;

  /// No description provided for @createThemeSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Thème créé avec succès !'**
  String get createThemeSuccess;

  /// No description provided for @questionFormCreateTitle.
  ///
  /// In fr, this message translates to:
  /// **'Créer une question'**
  String get questionFormCreateTitle;

  /// No description provided for @questionFormEditTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier la question'**
  String get questionFormEditTitle;

  /// No description provided for @questionFormNoTheme.
  ///
  /// In fr, this message translates to:
  /// **'Vous devez d\'abord créer un thème avant d\'ajouter des questions.'**
  String get questionFormNoTheme;

  /// No description provided for @questionFormQuestionTypeLabel.
  ///
  /// In fr, this message translates to:
  /// **'Type de question'**
  String get questionFormQuestionTypeLabel;

  /// No description provided for @questionFormAnswerTypeLabel.
  ///
  /// In fr, this message translates to:
  /// **'Type de réponse'**
  String get questionFormAnswerTypeLabel;

  /// No description provided for @questionFormQuestionLabel.
  ///
  /// In fr, this message translates to:
  /// **'Question'**
  String get questionFormQuestionLabel;

  /// No description provided for @questionFormQuestionHint.
  ///
  /// In fr, this message translates to:
  /// **'Entrez votre question'**
  String get questionFormQuestionHint;

  /// No description provided for @questionFormQuestionError.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer une question'**
  String get questionFormQuestionError;

  /// No description provided for @questionFormThemeLabel.
  ///
  /// In fr, this message translates to:
  /// **'Thème'**
  String get questionFormThemeLabel;

  /// No description provided for @questionFormThemeError.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez sélectionner un thème'**
  String get questionFormThemeError;

  /// No description provided for @questionFormAddImage.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une image'**
  String get questionFormAddImage;

  /// No description provided for @questionFormImageSelected.
  ///
  /// In fr, this message translates to:
  /// **'Image sélectionnée'**
  String get questionFormImageSelected;

  /// No description provided for @questionFormExpectedAnswersLabel.
  ///
  /// In fr, this message translates to:
  /// **'Réponses attendues (séparées par ;)'**
  String get questionFormExpectedAnswersLabel;

  /// No description provided for @questionFormExpectedAnswersHint.
  ///
  /// In fr, this message translates to:
  /// **'ex: Paris; paris'**
  String get questionFormExpectedAnswersHint;

  /// No description provided for @questionFormSave.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get questionFormSave;

  /// No description provided for @questionFormCreate.
  ///
  /// In fr, this message translates to:
  /// **'Créer la question'**
  String get questionFormCreate;

  /// No description provided for @questionFormSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Question créée avec succès !'**
  String get questionFormSuccess;

  /// No description provided for @questionFormEditSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Question modifiée avec succès'**
  String get questionFormEditSuccess;

  /// No description provided for @questionFormSelectTheme.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez sélectionner un thème'**
  String get questionFormSelectTheme;

  /// No description provided for @questionFormSelectAudio.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez sélectionner un fichier audio'**
  String get questionFormSelectAudio;

  /// No description provided for @questionFormStopRecording.
  ///
  /// In fr, this message translates to:
  /// **'Arrêtez l\'enregistrement avant d\'enregistrer la question.'**
  String get questionFormStopRecording;

  /// No description provided for @questionFormMinAnswer.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer au moins une réponse attendue'**
  String get questionFormMinAnswer;

  /// No description provided for @questionFormSelectCorrect.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez sélectionner au moins une bonne réponse'**
  String get questionFormSelectCorrect;

  /// No description provided for @answerTypeOpen.
  ///
  /// In fr, this message translates to:
  /// **'Ouverte'**
  String get answerTypeOpen;

  /// No description provided for @answerTypeSingle.
  ///
  /// In fr, this message translates to:
  /// **'Choix'**
  String get answerTypeSingle;

  /// No description provided for @answerTypeMultiple.
  ///
  /// In fr, this message translates to:
  /// **'Multiple'**
  String get answerTypeMultiple;

  /// No description provided for @questionTypeText.
  ///
  /// In fr, this message translates to:
  /// **'Texte'**
  String get questionTypeText;

  /// No description provided for @questionTypeImage.
  ///
  /// In fr, this message translates to:
  /// **'Image'**
  String get questionTypeImage;

  /// No description provided for @questionTypeAudio.
  ///
  /// In fr, this message translates to:
  /// **'Audio'**
  String get questionTypeAudio;

  /// No description provided for @audioImport.
  ///
  /// In fr, this message translates to:
  /// **'Importer un fichier audio'**
  String get audioImport;

  /// No description provided for @audioSelected.
  ///
  /// In fr, this message translates to:
  /// **'Audio sélectionné'**
  String get audioSelected;

  /// No description provided for @audioRecord.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer un audio'**
  String get audioRecord;

  /// No description provided for @audioStop.
  ///
  /// In fr, this message translates to:
  /// **'Arrêter l\'enregistrement'**
  String get audioStop;

  /// No description provided for @audioRecordingLabel.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrement en cours...'**
  String get audioRecordingLabel;

  /// No description provided for @audioFileLabel.
  ///
  /// In fr, this message translates to:
  /// **'Fichier : {name}'**
  String audioFileLabel(String name);

  /// No description provided for @audioStopFirst.
  ///
  /// In fr, this message translates to:
  /// **'Arrêtez l\'enregistrement avant d\'importer un audio.'**
  String get audioStopFirst;

  /// No description provided for @audioPermission.
  ///
  /// In fr, this message translates to:
  /// **'L\'accès au microphone est nécessaire pour enregistrer.'**
  String get audioPermission;

  /// No description provided for @audioNoFile.
  ///
  /// In fr, this message translates to:
  /// **'Aucun fichier audio n\'a été généré.'**
  String get audioNoFile;

  /// No description provided for @audioRetrieveError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de récupérer ce fichier audio.'**
  String get audioRetrieveError;

  /// No description provided for @choiceAnswersLabel.
  ///
  /// In fr, this message translates to:
  /// **'Réponses possibles'**
  String get choiceAnswersLabel;

  /// No description provided for @choiceAddButton.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get choiceAddButton;

  /// No description provided for @choiceHint.
  ///
  /// In fr, this message translates to:
  /// **'Réponse {number}'**
  String choiceHint(int number);

  /// No description provided for @choiceRequired.
  ///
  /// In fr, this message translates to:
  /// **'Réponse requise'**
  String get choiceRequired;

  /// No description provided for @choiceSelectOne.
  ///
  /// In fr, this message translates to:
  /// **'Cochez la bonne réponse'**
  String get choiceSelectOne;

  /// No description provided for @choiceSelectMultiple.
  ///
  /// In fr, this message translates to:
  /// **'Cochez toutes les bonnes réponses'**
  String get choiceSelectMultiple;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
