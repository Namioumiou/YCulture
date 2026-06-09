import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/question.dart';
import '../models/theme.dart';
import '../models/quiz_result.dart';

/// Fournisseur d'état central de l'application YCulture.
///
/// Gère les thèmes, questions, résultats et la progression XP du joueur.
/// Toutes les données sont persistées localement via [SharedPreferences] ;
/// l'application fonctionne entièrement hors ligne.
/// Chaque méthode mutante notifie les listeners et déclenche une sauvegarde.
class QuizProvider with ChangeNotifier {
  /// Version du système d'XP. Une migration est effectuée si la version stockée est inférieure.
  static const int _xpSystemVersion = 2;

  /// XP de base requis pour passer du niveau 1 au niveau 2.
  static const int _baseXpPerLevel = 150;

  /// Incrément d'XP ajouté à chaque niveau (la progression devient plus longue au fil du temps).
  static const int _xpPerLevelIncrement = 50;

  /// XP gagnés par bonne réponse.
  static const int _xpPerCorrectAnswer = 18;

  /// XP minimum accordés pour avoir participé à un quiz, quel que soit le score.
  static const int _xpParticipationBonus = 8;

  /// Bonus XP accordé en cas de quiz parfait (toutes les réponses correctes).
  static const int _xpPerfectQuizBonus = 30;

  final List<QuizTheme> _themes = [];
  final List<Question> _questions = [];
  final List<QuizResult> _results = [];
  final _uuid = const Uuid();

  /// Indique si le chargement initial depuis [SharedPreferences] est terminé.
  bool _isLoaded = false;
  String? _profileAvatarId;
  int _experiencePoints = 0;

  bool get isLoaded => _isLoaded;

  /// Liste immuable des thèmes disponibles.
  List<QuizTheme> get themes => List.unmodifiable(_themes);

  /// Liste immuable de toutes les questions.
  List<Question> get questions => List.unmodifiable(_questions);

  /// Liste immuable de l'historique des résultats.
  List<QuizResult> get results => List.unmodifiable(_results);

  String? get profileAvatarId => _profileAvatarId;
  int get experiencePoints => _experiencePoints;

  /// XP total requis pour terminer le niveau actuel.
  int get xpPerLevel => _xpRequiredForLevel(level);

  /// Niveau actuel du joueur, calculé à partir du total d'XP accumulés.
  int get level => _getLevelProgress(_experiencePoints).level;

  /// XP accumulés dans le niveau en cours (réinitialisés à 0 à chaque montée de niveau).
  int get experiencePointsInCurrentLevel =>
      _getLevelProgress(_experiencePoints).experiencePointsInCurrentLevel;

  QuizProvider() {
    _loadData();
  }

  /// Charge toutes les données depuis [SharedPreferences] au démarrage.
  /// Effectue une migration d'XP si nécessaire avant de notifier l'UI.
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _profileAvatarId = prefs.getString('profile_avatar_id');
    _experiencePoints = prefs.getInt('experience_points') ?? 0;

    final storedXpSystemVersion = prefs.getInt('xp_system_version') ?? 1;
    if (storedXpSystemVersion < _xpSystemVersion) {
      // Migration nécessaire : recalcule l'XP selon la nouvelle formule progressive.
      _experiencePoints = _migrateExperiencePoints(
        legacyExperiencePoints: _experiencePoints,
      );
      await prefs.setInt('experience_points', _experiencePoints);
      await prefs.setInt('xp_system_version', _xpSystemVersion);
    }

    final themesJson = prefs.getString('themes');
    if (themesJson == null) {
      // Premier lancement : on initialise les données de démonstration.
      _initializeDefaultData();
      await _saveData();
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

  /// Sérialise et sauvegarde l'ensemble des données dans [SharedPreferences].
  ///
  /// En cas d'échec, l'erreur est journalisée via [debugPrint] puis propagée ;
  /// l'état en mémoire reste inchangé.
  Future<void> _saveData() async {
    try {
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
    } on Object catch (error, stackTrace) {
      debugPrint('QuizProvider: failed to persist data: $error');
      debugPrint('$stackTrace');
      rethrow;
    }
  }

  /// Crée le thème et les questions de démonstration affichés au premier lancement.
  void _initializeDefaultData() {
    _themes.addAll([
      QuizTheme(
        id: _uuid.v4(),
        name: 'Culture Générale',
        description: 'Testez vos connaissances générales',
      ),
    ]);

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

  // ── Gestion des thèmes ────────────────────────────────────────────────────

  /// Ajoute un nouveau thème et persiste les données.
  Future<void> addTheme(QuizTheme theme) async {
    _themes.add(theme);
    notifyListeners();
    await _saveData();
  }

  /// Met à jour un thème existant identifié par son [QuizTheme.id].
  Future<void> updateTheme(QuizTheme theme) async {
    final index = _themes.indexWhere((t) => t.id == theme.id);
    if (index != -1) {
      _themes[index] = theme;
      notifyListeners();
      await _saveData();
    }
  }

  /// Supprime un thème ainsi que toutes les questions qui lui appartiennent.
  Future<void> deleteTheme(String themeId) async {
    _themes.removeWhere((t) => t.id == themeId);
    _questions.removeWhere((q) => q.themeId == themeId);
    notifyListeners();
    await _saveData();
  }

  /// Retourne le thème correspondant à [id], ou [null] s'il n'existe pas.
  QuizTheme? getThemeById(String id) {
    try {
      return _themes.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  // ── Gestion des questions ─────────────────────────────────────────────────

  /// Ajoute une nouvelle question et persiste les données.
  Future<void> addQuestion(Question question) async {
    _questions.add(question);
    notifyListeners();
    await _saveData();
  }

  /// Met à jour une question existante identifiée par son [Question.id].
  Future<void> updateQuestion(Question question) async {
    final index = _questions.indexWhere((q) => q.id == question.id);
    if (index != -1) {
      _questions[index] = question;
      notifyListeners();
      await _saveData();
    }
  }

  /// Supprime la question identifiée par [questionId].
  Future<void> deleteQuestion(String questionId) async {
    _questions.removeWhere((q) => q.id == questionId);
    notifyListeners();
    await _saveData();
  }

  /// Retourne toutes les questions appartenant au thème [themeId].
  List<Question> getQuestionsByTheme(String themeId) {
    return _questions.where((q) => q.themeId == themeId).toList();
  }

  // ── Résultats et progression XP ───────────────────────────────────────────

  /// Enregistre le résultat d'un quiz terminé, calcule le gain d'XP
  /// et retourne un résumé [ExperienceGain] (dont l'éventuelle montée de niveau).
  Future<ExperienceGain> addResult(QuizResult result) async {
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
    await _saveData();

    return ExperienceGain(
      gainedExperiencePoints: gainedExperiencePoints,
      previousLevel: previousLevel,
      currentLevel: currentLevel,
      previousExperiencePoints: previousExperiencePoints,
      currentExperiencePoints: _experiencePoints,
    );
  }

  /// Calcule les XP gagnés pour un quiz :
  /// bonus de participation + (bonnes réponses × XP unitaire) + bonus de perfection.
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

  /// XP requis pour terminer [currentLevel] ; augmente linéairement avec le niveau.
  int _xpRequiredForLevel(int currentLevel) {
    return _baseXpPerLevel + ((currentLevel - 1) * _xpPerLevelIncrement);
  }

  /// XP total cumulé nécessaire pour atteindre [targetLevel] depuis le niveau 1.
  int _totalExperienceRequiredToReachLevel(int targetLevel) {
    if (targetLevel <= 1) return 0;
    final completedLevels = targetLevel - 1;
    return (completedLevels *
            ((2 * _baseXpPerLevel) +
                ((completedLevels - 1) * _xpPerLevelIncrement))) ~/
        2;
  }

  /// Calcule le niveau actuel et l'XP restant dans ce niveau à partir du total [totalExperiencePoints].
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

  /// Convertit les XP de l'ancienne formule plate (version 1)
  /// vers la formule progressive (version 2) en préservant le niveau atteint.
  int _migrateExperiencePoints({required int legacyExperiencePoints}) {
    final legacyLevel = (legacyExperiencePoints ~/ _baseXpPerLevel) + 1;
    final legacyXpInLevel = legacyExperiencePoints % _baseXpPerLevel;
    final migratedBase = _totalExperienceRequiredToReachLevel(legacyLevel);
    final migratedXpPerLevel = _xpRequiredForLevel(legacyLevel);
    final migratedProgress =
        ((legacyXpInLevel / _baseXpPerLevel) * migratedXpPerLevel).round();
    return migratedBase + migratedProgress;
  }

  /// Retourne tous les résultats enregistrés pour le thème [themeId].
  List<QuizResult> getResultsByTheme(String themeId) {
    return _results.where((r) => r.themeId == themeId).toList();
  }

  // ── Profil ────────────────────────────────────────────────────────────────

  /// Enregistre l'identifiant de l'avatar sélectionné par l'utilisateur.
  Future<void> setProfileAvatar(String avatarId) async {
    _profileAvatarId = avatarId;
    notifyListeners();
    await _saveData();
  }

  /// Efface l'avatar du profil (retour à l'icône par défaut).
  Future<void> clearProfileAvatar() async {
    _profileAvatarId = null;
    notifyListeners();
    await _saveData();
  }

  /// Génère un identifiant unique (UUID v4) pour les nouveaux objets.
  String generateId() => _uuid.v4();
}

/// Résumé des gains XP et de la progression de niveau après un quiz terminé.
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

  /// Vrai si le joueur a atteint un nouveau niveau grâce à ce quiz.
  bool get didLevelUp => currentLevel > previousLevel;
}

/// Résultat intermédiaire de calcul de niveau : niveau actuel et XP dans ce niveau.
class _LevelProgress {
  final int level;
  final int experiencePointsInCurrentLevel;

  const _LevelProgress({
    required this.level,
    required this.experiencePointsInCurrentLevel,
  });
}
