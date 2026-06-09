import 'question.dart';

/// The outcome of a completed quiz session.
class QuizResult {
  /// ID of the [QuizTheme] that was played.
  final String themeId;
  final int totalQuestions;
  final int correctAnswers;
  final DateTime completedAt;
  final List<Question> questions;
  final Map<int, dynamic> userAnswers;

  QuizResult({
    required this.themeId,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.completedAt,
    this.questions = const [],
    this.userAnswers = const {},
  });

  /// Score as a percentage in [0, 100].
  double get percentage => (correctAnswers / totalQuestions) * 100;

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    final questionsJson = json['questions'] as List?;
    final userAnswersJson = json['userAnswers'] as Map<String, dynamic>?;

    final userAnswers = <int, dynamic>{};
    if (userAnswersJson != null) {
      for (final entry in userAnswersJson.entries) {
        final value = entry.value;
        userAnswers[int.parse(entry.key)] =
            value is List ? List<String>.from(value) : value;
      }
    }

    return QuizResult(
      themeId: json['themeId'] as String,
      totalQuestions: json['totalQuestions'] as int,
      correctAnswers: json['correctAnswers'] as int,
      completedAt: DateTime.parse(json['completedAt'] as String),
      questions: questionsJson != null
          ? questionsJson
              .map((j) => Question.fromJson(j as Map<String, dynamic>))
              .toList()
          : const [],
      userAnswers: userAnswers,
    );
  }

  Map<String, dynamic> toJson() => {
        'themeId': themeId,
        'totalQuestions': totalQuestions,
        'correctAnswers': correctAnswers,
        'completedAt': completedAt.toIso8601String(),
        'questions': questions.map((q) => q.toJson()).toList(),
        'userAnswers': userAnswers.map(
          (key, value) => MapEntry(key.toString(), value),
        ),
      };
}
