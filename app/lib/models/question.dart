enum QuestionType {
  text,
  image,
  audio,
}

enum AnswerType {
  open,
  singleChoice,
  multipleChoice,
}

class Question {
  final String id;
  final String text;
  final String? imageUrl;
  final String? audioUrl;
  final QuestionType questionType;
  final AnswerType answerType;
  final List<String> choices;
  final List<String> correctAnswers;
  final String themeId;

  Question({
    required this.id,
    required this.text,
    this.imageUrl,
    this.audioUrl,
    required this.questionType,
    required this.answerType,
    required this.choices,
    required this.correctAnswers,
    required this.themeId,
  });

  Question copyWith({
    String? id,
    String? text,
    String? imageUrl,
    String? audioUrl,
    QuestionType? questionType,
    AnswerType? answerType,
    List<String>? choices,
    List<String>? correctAnswers,
    String? themeId,
  }) {
    return Question(
      id: id ?? this.id,
      text: text ?? this.text,
      imageUrl: imageUrl ?? this.imageUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      questionType: questionType ?? this.questionType,
      answerType: answerType ?? this.answerType,
      choices: choices ?? this.choices,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      themeId: themeId ?? this.themeId,
    );
  }
}
