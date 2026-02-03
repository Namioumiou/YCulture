import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/question.dart';
import '../models/theme.dart';
import '../models/quiz_result.dart';

class QuizProvider with ChangeNotifier {
  final List<QuizTheme> _themes = [];
  final List<Question> _questions = [];
  final List<QuizResult> _results = [];
  final _uuid = const Uuid();

  List<QuizTheme> get themes => List.unmodifiable(_themes);
  List<Question> get questions => List.unmodifiable(_questions);
  List<QuizResult> get results => List.unmodifiable(_results);

  QuizProvider() {
    _initializeDefaultData();
  }

  void _initializeDefaultData() {
    // Thèmes par défaut
    _themes.addAll([
      QuizTheme(
        id: _uuid.v4(),
        name: 'Culture Générale',
        description: 'Testez vos connaissances générales',
      ),
      QuizTheme(
        id: _uuid.v4(),
        name: 'Histoire',
        description: 'Questions sur l\'histoire mondiale',
      ),
      QuizTheme(
        id: _uuid.v4(),
        name: 'Sciences',
        description: 'Questions scientifiques',
      ),
      QuizTheme(
        id: _uuid.v4(),
        name: 'Géographie',
        description: 'Explorez le monde',
      ),
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
  }

  void updateTheme(QuizTheme theme) {
    final index = _themes.indexWhere((t) => t.id == theme.id);
    if (index != -1) {
      _themes[index] = theme;
      notifyListeners();
    }
  }

  void deleteTheme(String themeId) {
    _themes.removeWhere((t) => t.id == themeId);
    _questions.removeWhere((q) => q.themeId == themeId);
    notifyListeners();
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
  }

  void updateQuestion(Question question) {
    final index = _questions.indexWhere((q) => q.id == question.id);
    if (index != -1) {
      _questions[index] = question;
      notifyListeners();
    }
  }

  void deleteQuestion(String questionId) {
    _questions.removeWhere((q) => q.id == questionId);
    notifyListeners();
  }

  List<Question> getQuestionsByTheme(String themeId) {
    return _questions.where((q) => q.themeId == themeId).toList();
  }

  // Gestion des résultats
  void addResult(QuizResult result) {
    _results.add(result);
    notifyListeners();
  }

  List<QuizResult> getResultsByTheme(String themeId) {
    return _results.where((r) => r.themeId == themeId).toList();
  }

  String generateId() => _uuid.v4();
}
