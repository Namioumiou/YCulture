import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/question.dart';
import '../models/theme.dart';
import '../models/quiz_result.dart';

class QuizProvider with ChangeNotifier {
  static const int _xpSystemVersion = 2;
  static const int _baseXpPerLevel = 150;
  static const int _xpPerLevelIncrement = 50;
  static const int _xpPerCorrectAnswer = 18;
  static const int _xpParticipationBonus = 8;
  static const int _xpPerfectQuizBonus = 30;

  final List<QuizTheme> _themes = [];
  final List<Question> _questions = [];
  final List<QuizResult> _results = [];
  final _uuid = const Uuid();
  bool _isLoaded = false;
  String? _profileAvatarId;
  int _experiencePoints = 0;

  bool get isLoaded => _isLoaded;
  List<QuizTheme> get themes => List.unmodifiable(_themes);
  List<Question> get questions => List.unmodifiable(_questions);
  List<QuizResult> get results => List.unmodifiable(_results);
  String? get profileAvatarId => _profileAvatarId;
  int get experiencePoints => _experiencePoints;
  int get xpPerLevel => _xpRequiredForLevel(level);
  int get level => _getLevelProgress(_experiencePoints).level;
  int get experiencePointsInCurrentLevel =>
      _getLevelProgress(_experiencePoints).experiencePointsInCurrentLevel;

  QuizProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _profileAvatarId = prefs.getString('profile_avatar_id');
    _experiencePoints = prefs.getInt('experience_points') ?? 0;
    final storedXpSystemVersion = prefs.getInt('xp_system_version') ?? 1;
    if (storedXpSystemVersion < _xpSystemVersion) {
      _experiencePoints = _migrateExperiencePoints(
        legacyExperiencePoints: _experiencePoints,
      );
      await prefs.setInt('experience_points', _experiencePoints);
      await prefs.setInt('xp_system_version', _xpSystemVersion);
    }
    final themesJson = prefs.getString('themes');
    if (themesJson == null) {
      _initializeDefaultData();
    } else {
      final themesList = jsonDecode(themesJson) as List;
      _themes.addAll(themesList.map((j) => QuizTheme.fromJson(j as Map<String, dynamic>)));
      final questionsJson = prefs.getString('questions') ?? '[]';
      final questionsList = jsonDecode(questionsJson) as List;
      _questions.addAll(questionsList.map((j) => Question.fromJson(j as Map<String, dynamic>)));
      final resultsJson = prefs.getString('results') ?? '[]';
      final resultsList = jsonDecode(resultsJson) as List;
      _results.addAll(resultsList.map((j) => QuizResult.fromJson(j as Map<String, dynamic>)));
    }
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themes', jsonEncode(_themes.map((t) => t.toJson()).toList()));
    await prefs.setString('questions', jsonEncode(_questions.map((q) => q.toJson()).toList()));
    await prefs.setString('results', jsonEncode(_results.map((r) => r.toJson()).toList()));
    await prefs.setInt('experience_points', _experiencePoints);
    await prefs.setInt('xp_system_version', _xpSystemVersion);
    if (_profileAvatarId == null || _profileAvatarId!.isEmpty) {
      await prefs.remove('profile_avatar_id');
    } else {
      await prefs.setString('profile_avatar_id', _profileAvatarId!);
    }
    // Cleanup legacy value from old gallery-based implementation.
    await prefs.remove('profile_avatar_base64');
  }

  void _initializeDefaultData() {
    // Thèmes par défaut
    _themes.addAll([
      QuizTheme(
        id: _uuid.v4(),
        name: 'Culture Générale',
        description: 'Testez vos connaissances générales',
      )
    ]);

    // Questions par défaut
    final cultureThemeId = _themes[0].id;
    _questions.addAll([
      Question(
        id: _uuid.v4(),
        text: 'Quelle est la capitale de la France ?',
        questionType: QuestionType.text,
        answerType: AnswerType.singleChoice,
        choices: ['Paris', 'Londres', 'Berlin', 'Madrid'],
        correctAnswers: ['Paris'],
        themeId: cultureThemeId,
      ),
      Question(
        id: _uuid.v4(),
        text: 'Qui a peint la Joconde ?',
        questionType: QuestionType.text,
        answerType: AnswerType.open,
        choices: [],
        correctAnswers: ['Léonard de Vinci', 'Leonardo da Vinci'],
        themeId: cultureThemeId,
      ),
      Question(
        id: _uuid.v4(),
        text: 'Quels sont les pays du Maghreb ?',
        questionType: QuestionType.text,
        answerType: AnswerType.multipleChoice,
        choices: ['Maroc', 'Algérie', 'Tunisie', 'Égypte', 'Libye'],
        correctAnswers: ['Maroc', 'Algérie', 'Tunisie'],
        themeId: cultureThemeId,
      ),
    ]);
  }

  // Gestion des thèmes
  void addTheme(QuizTheme theme) {
    _themes.add(theme);
    notifyListeners();
    _saveData();
  }

  void updateTheme(QuizTheme theme) {
    final index = _themes.indexWhere((t) => t.id == theme.id);
    if (index != -1) {
      _themes[index] = theme;
      notifyListeners();
      _saveData();
    }
  }

  void deleteTheme(String themeId) {
    _themes.removeWhere((t) => t.id == themeId);
    _questions.removeWhere((q) => q.themeId == themeId);
    notifyListeners();
    _saveData();
  }

  QuizTheme? getThemeById(String id) {
    try {
      return _themes.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  // Gestion des questions
  void addQuestion(Question question) {
    _questions.add(question);
    notifyListeners();
    _saveData();
  }

  void updateQuestion(Question question) {
    final index = _questions.indexWhere((q) => q.id == question.id);
    if (index != -1) {
      _questions[index] = question;
      notifyListeners();
      _saveData();
    }
  }

  void deleteQuestion(String questionId) {
    _questions.removeWhere((q) => q.id == questionId);
    notifyListeners();
    _saveData();
  }

  List<Question> getQuestionsByTheme(String themeId) {
    return _questions.where((q) => q.themeId == themeId).toList();
  }

  // Gestion des résultats
  ExperienceGain addResult(QuizResult result) {
    final previousExperiencePoints = _experiencePoints;
    final previousLevel = level;
    final gainedExperiencePoints = _calculateExperienceGain(
      correctAnswers: result.correctAnswers,
      totalQuestions: result.totalQuestions,
    );

    _results.add(result);
    _experiencePoints += gainedExperiencePoints;

    final currentLevel = level;

    notifyListeners();
    _saveData();

    return ExperienceGain(
      gainedExperiencePoints: gainedExperiencePoints,
      previousLevel: previousLevel,
      currentLevel: currentLevel,
      previousExperiencePoints: previousExperiencePoints,
      currentExperiencePoints: _experiencePoints,
    );
  }

  int _calculateExperienceGain({
    required int correctAnswers,
    required int totalQuestions,
  }) {
    var gain = _xpParticipationBonus + (correctAnswers * _xpPerCorrectAnswer);
    if (totalQuestions > 0 && correctAnswers == totalQuestions) {
      gain += _xpPerfectQuizBonus;
    }
    return gain;
  }

  int _xpRequiredForLevel(int currentLevel) {
    return _baseXpPerLevel + ((currentLevel - 1) * _xpPerLevelIncrement);
  }

  int _totalExperienceRequiredToReachLevel(int targetLevel) {
    if (targetLevel <= 1) {
      return 0;
    }

    final completedLevels = targetLevel - 1;
    return (completedLevels *
            ((2 * _baseXpPerLevel) +
                ((completedLevels - 1) * _xpPerLevelIncrement))) ~/
        2;
  }

  _LevelProgress _getLevelProgress(int totalExperiencePoints) {
    var currentLevel = 1;
    var remainingExperiencePoints = totalExperiencePoints;

    while (remainingExperiencePoints >= _xpRequiredForLevel(currentLevel)) {
      remainingExperiencePoints -= _xpRequiredForLevel(currentLevel);
      currentLevel++;
    }

    return _LevelProgress(
      level: currentLevel,
      experiencePointsInCurrentLevel: remainingExperiencePoints,
    );
  }

  int _migrateExperiencePoints({
    required int legacyExperiencePoints,
  }) {
    final legacyLevel = (legacyExperiencePoints ~/ _baseXpPerLevel) + 1;
    final legacyExperiencePointsInCurrentLevel =
        legacyExperiencePoints % _baseXpPerLevel;
    final migratedLevelBaseExperience =
        _totalExperienceRequiredToReachLevel(legacyLevel);
    final migratedXpPerLevel = _xpRequiredForLevel(legacyLevel);
    final migratedLevelProgress =
        ((legacyExperiencePointsInCurrentLevel / _baseXpPerLevel) *
                migratedXpPerLevel)
            .round();

    return migratedLevelBaseExperience + migratedLevelProgress;
  }

  List<QuizResult> getResultsByTheme(String themeId) {
    return _results.where((r) => r.themeId == themeId).toList();
  }

  Future<void> setProfileAvatar(String avatarId) async {
    _profileAvatarId = avatarId;
    notifyListeners();
    await _saveData();
  }

  Future<void> clearProfileAvatar() async {
    _profileAvatarId = null;
    notifyListeners();
    await _saveData();
  }

  String generateId() => _uuid.v4();
}

class ExperienceGain {
  final int gainedExperiencePoints;
  final int previousLevel;
  final int currentLevel;
  final int previousExperiencePoints;
  final int currentExperiencePoints;

  const ExperienceGain({
    required this.gainedExperiencePoints,
    required this.previousLevel,
    required this.currentLevel,
    required this.previousExperiencePoints,
    required this.currentExperiencePoints,
  });

  bool get didLevelUp => currentLevel > previousLevel;
}

class _LevelProgress {
  final int level;
  final int experiencePointsInCurrentLevel;

  const _LevelProgress({
    required this.level,
    required this.experiencePointsInCurrentLevel,
  });
}
