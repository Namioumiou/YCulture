import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/question.dart';
import '../models/theme.dart';
import '../models/quiz_result.dart';

class QuizProvider with ChangeNotifier {
  final List<QuizTheme> _themes = [];
  final List<Question> _questions = [];
  final List<QuizResult> _results = [];
  final _uuid = const Uuid();
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;
  List<QuizTheme> get themes => List.unmodifiable(_themes);
  List<Question> get questions => List.unmodifiable(_questions);
  List<QuizResult> get results => List.unmodifiable(_results);

  QuizProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
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
  void addResult(QuizResult result) {
    _results.add(result);
    notifyListeners();
    _saveData();
  }

  List<QuizResult> getResultsByTheme(String themeId) {
    return _results.where((r) => r.themeId == themeId).toList();
  }

  String generateId() => _uuid.v4();
}
