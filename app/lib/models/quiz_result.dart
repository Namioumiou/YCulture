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

  factory QuizResult.fromJson(Map<String, dynamic> json) => QuizResult(
        themeId: json['themeId'] as String,
        totalQuestions: json['totalQuestions'] as int,
        correctAnswers: json['correctAnswers'] as int,
        completedAt: DateTime.parse(json['completedAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'themeId': themeId,
        'totalQuestions': totalQuestions,
        'correctAnswers': correctAnswers,
        'completedAt': completedAt.toIso8601String(),
      };
}
