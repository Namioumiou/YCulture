class QuizResult {
  final String themeId;
  final int totalQuestions;
  final int correctAnswers;
  final DateTime completedAt;

  QuizResult({
    required this.themeId,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.completedAt,
  });

  double get percentage => (correctAnswers / totalQuestions) * 100;
}
