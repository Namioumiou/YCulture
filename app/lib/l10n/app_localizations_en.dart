// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'YCulture';

  @override
  String get homeWelcome => 'Welcome to YCulture, your customizable quiz app!';

  @override
  String get homePlayNow => 'Play now';

  @override
  String get homePlaySubtitle => 'Browse available themes';

  @override
  String get homeCreateTheme => 'Create a theme';

  @override
  String get homeCreateThemeSubtitle => 'Add a new quiz category';

  @override
  String get homeCreateQuestion => 'Create a question';

  @override
  String get homeCreateQuestionSubtitle => 'Text, image or audio';

  @override
  String get homeMyProfile => 'My profile';

  @override
  String get homeMyProfileSubtitle => 'Change your user avatar';

  @override
  String homeThemesCount(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString themes',
      one: '1 theme',
      zero: '0 themes',
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
      zero: '0 questions',
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
      other: '$countString results',
      one: '1 result',
      zero: '0 results',
    );
    return '$_temp0';
  }

  @override
  String homeLevelBadge(int level) {
    return 'Lvl. $level';
  }

  @override
  String get themeSelectionTitle => 'Choose a theme';

  @override
  String get themeNoThemesTitle => 'No themes available';

  @override
  String get themeNoThemesSubtitle =>
      'Create your first theme to start playing.';

  @override
  String get themeNoQuestionsSnack => 'This theme has no questions yet.';

  @override
  String get themeManageTooltip => 'Manage theme';

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
      zero: 'No questions',
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
      other: '$countString questions in this theme',
      one: '1 question in this theme',
      zero: 'No questions in this theme',
    );
    return '$_temp0';
  }

  @override
  String get themeQuestionsNone => 'No questions in this theme yet.';

  @override
  String get themeDeleteTitle => 'Delete question?';

  @override
  String themeDeleteConfirm(String questionText) {
    return 'This action is irreversible.\n\n\"$questionText\"';
  }

  @override
  String get themeDeleteCancel => 'Cancel';

  @override
  String get themeDeleteButton => 'Delete';

  @override
  String get themeDeleteSuccess => 'Question deleted';

  @override
  String get themeEditAction => 'Edit';

  @override
  String get quizNoQuestions => 'No questions available';

  @override
  String quizQuestionCounter(int current, int total) {
    return 'Question $current/$total';
  }

  @override
  String get quizYourAnswer => 'Your answer';

  @override
  String get quizAnswerSubtitleSingle => 'Select one answer.';

  @override
  String get quizAnswerSubtitleMultiple => 'Select one or more answers.';

  @override
  String get quizAnswerSubtitleOpen => 'Type your answer.';

  @override
  String get quizAudioPlaying => 'Playing audio';

  @override
  String get quizAudioPrompt => 'Tap to listen to the audio hint';

  @override
  String get quizAudioNotFound => 'Audio file not found on this device.';

  @override
  String get quizAudioError => 'Cannot play this audio file.';

  @override
  String get quizImageError => 'Cannot load image';

  @override
  String get quizAnswerHint => 'Your answer...';

  @override
  String get quizValidate => 'Validate';

  @override
  String get quizFinish => 'Finish';

  @override
  String get resultsTitle => 'Results';

  @override
  String get resultsQuizDone => 'Quiz completed';

  @override
  String get resultsCorrectLabel => 'Correct';

  @override
  String get resultsIncorrectLabel => 'Incorrect';

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
    return 'Congrats! Level $level reached.';
  }

  @override
  String resultsCurrentLevel(int level) {
    return 'Current level: $level';
  }

  @override
  String resultsXpToNextLevel(int current, int max) {
    return '$current/$max XP to next level';
  }

  @override
  String get resultsDetailedReview => 'Detailed review';

  @override
  String get resultsDetailedReviewSubtitle =>
      'Compare your answer with the correct answer for each question.';

  @override
  String resultsQuestionNumber(int number) {
    return 'Question $number';
  }

  @override
  String get resultsCorrect => 'Correct';

  @override
  String get resultsIncorrect => 'Incorrect';

  @override
  String get resultsYourAnswerLabel => 'Your answer';

  @override
  String get resultsCorrectAnswerLabel => 'Correct answer';

  @override
  String get resultsNoAnswer => 'No answer';

  @override
  String get resultsNoAnswerDefined => 'No answer defined';

  @override
  String get resultsRetry => 'Retry quiz';

  @override
  String get resultsBackHome => 'Back to home';

  @override
  String get resultsBack => 'Back';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileNoAvatar => 'No avatar available';

  @override
  String get profileNoAvatarHint =>
      'Add images in assets/avatars to display them here.';

  @override
  String get profileMyProfile => 'My profile';

  @override
  String profileLevel(int level) {
    return 'Level $level';
  }

  @override
  String profileXp(int current, int max) {
    return '$current/$max XP';
  }

  @override
  String get profileAvatarUpdated => 'Avatar updated';

  @override
  String get profileHistory => 'Quiz history';

  @override
  String get profileNoHistory => 'No quiz completed yet.';

  @override
  String get profileThemeDeleted => 'Theme deleted';

  @override
  String get avatarPickerTitle => 'Choose an avatar';

  @override
  String get avatarPickerSubtitle => 'Some avatars unlock with your level.';

  @override
  String avatarPickerLocked(int level) {
    return 'This avatar unlocks at level $level.';
  }

  @override
  String avatarPickerLevelBadge(int level) {
    return 'Lvl. $level';
  }

  @override
  String get createThemeTitle => 'Create a theme';

  @override
  String get createThemeNameLabel => 'Theme name';

  @override
  String get createThemeNameHint => 'Ex: World Geography';

  @override
  String get createThemeNameError => 'Please enter a name';

  @override
  String get createThemeDescLabel => 'Description';

  @override
  String get createThemeDescHint => 'Describe the theme content';

  @override
  String get createThemeDescError => 'Please enter a description';

  @override
  String get createThemeButton => 'Create theme';

  @override
  String get createThemeSuccess => 'Theme created successfully!';

  @override
  String get questionFormCreateTitle => 'Create a question';

  @override
  String get questionFormEditTitle => 'Edit question';

  @override
  String get questionFormNoTheme =>
      'You need to create a theme first before adding questions.';

  @override
  String get questionFormQuestionTypeLabel => 'Question type';

  @override
  String get questionFormAnswerTypeLabel => 'Answer type';

  @override
  String get questionFormQuestionLabel => 'Question';

  @override
  String get questionFormQuestionHint => 'Enter your question';

  @override
  String get questionFormQuestionError => 'Please enter a question';

  @override
  String get questionFormThemeLabel => 'Theme';

  @override
  String get questionFormThemeError => 'Please select a theme';

  @override
  String get questionFormAddImage => 'Add image';

  @override
  String get questionFormImageSelected => 'Image selected';

  @override
  String get questionFormExpectedAnswersLabel =>
      'Expected answers (separated by ;)';

  @override
  String get questionFormExpectedAnswersHint => 'ex: Paris; paris';

  @override
  String get questionFormSave => 'Save';

  @override
  String get questionFormCreate => 'Create question';

  @override
  String get questionFormSuccess => 'Question created successfully!';

  @override
  String get questionFormEditSuccess => 'Question updated successfully';

  @override
  String get questionFormSelectTheme => 'Please select a theme';

  @override
  String get questionFormSelectAudio => 'Please select an audio file';

  @override
  String get questionFormStopRecording =>
      'Stop the recording before saving the question.';

  @override
  String get questionFormMinAnswer =>
      'Please enter at least one expected answer';

  @override
  String get questionFormSelectCorrect =>
      'Please select at least one correct answer';

  @override
  String get answerTypeOpen => 'Open';

  @override
  String get answerTypeSingle => 'Choice';

  @override
  String get answerTypeMultiple => 'Multiple';

  @override
  String get questionTypeText => 'Text';

  @override
  String get questionTypeImage => 'Image';

  @override
  String get questionTypeAudio => 'Audio';

  @override
  String get audioImport => 'Import audio file';

  @override
  String get audioSelected => 'Audio selected';

  @override
  String get audioRecord => 'Record audio';

  @override
  String get audioStop => 'Stop recording';

  @override
  String get audioRecordingLabel => 'Recording...';

  @override
  String audioFileLabel(String name) {
    return 'File: $name';
  }

  @override
  String get audioStopFirst => 'Stop recording before importing an audio file.';

  @override
  String get audioPermission => 'Microphone access is required to record.';

  @override
  String get audioNoFile => 'No audio file was generated.';

  @override
  String get audioRetrieveError => 'Cannot retrieve this audio file.';

  @override
  String get choiceAnswersLabel => 'Possible answers';

  @override
  String get choiceAddButton => 'Add';

  @override
  String choiceHint(int number) {
    return 'Answer $number';
  }

  @override
  String get choiceRequired => 'Answer required';

  @override
  String get choiceSelectOne => 'Check the correct answer';

  @override
  String get choiceSelectMultiple => 'Check all correct answers';
}
