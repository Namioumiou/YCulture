/// Media type attached to a question.
enum QuestionType {
  /// Plain text question — no media.
  text,
  /// Question accompanied by an image.
  image,
  /// Question accompanied by an audio clip.
  audio,
}

/// How the user must answer a question.
enum AnswerType {
  /// User types a free-form answer; compared case-insensitively against [Question.correctAnswers].
  open,
  /// User picks exactly one choice from [Question.choices].
  singleChoice,
  /// User picks one or more choices from [Question.choices].
  multipleChoice,
}

/// A single quiz question with its media, answer configuration and theme membership.
class Question {
  final String id;
  final String text;
  final String? imageUrl;
  final String? audioUrl;
  final QuestionType questionType;
  final AnswerType answerType;

  /// Available choices shown for [AnswerType.singleChoice] and [AnswerType.multipleChoice].
  final List<String> choices;

  /// Accepted correct answers. For open questions, multiple accepted phrasings can be listed.
  final List<String> correctAnswers;

  /// ID of the [QuizTheme] this question belongs to.
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

  factory Question.fromJson(Map<String, dynamic> json) => Question(
        id: json['id'] as String,
        text: json['text'] as String,
        imageUrl: json['imageUrl'] as String?,
        audioUrl: json['audioUrl'] as String?,
        questionType: QuestionType.values.firstWhere((e) => e.name == json['questionType']),
        answerType: AnswerType.values.firstWhere((e) => e.name == json['answerType']),
        choices: List<String>.from(json['choices'] as List),
        correctAnswers: List<String>.from(json['correctAnswers'] as List),
        themeId: json['themeId'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'imageUrl': imageUrl,
        'audioUrl': audioUrl,
        'questionType': questionType.name,
        'answerType': answerType.name,
        'choices': choices,
        'correctAnswers': correctAnswers,
        'themeId': themeId,
      };

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
