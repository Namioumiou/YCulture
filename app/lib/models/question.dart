/// Type de média associé à une question.
enum QuestionType {
  /// Question textuelle simple, sans média.
  text,

  /// Question accompagnée d'une image à afficher.
  image,

  /// Question accompagnée d'un clip audio à écouter.
  audio,
}

/// Mode de réponse attendu pour une question.
enum AnswerType {
  /// L'utilisateur saisit librement sa réponse ; elle est comparée
  /// sans distinction de casse aux [Question.correctAnswers].
  open,

  /// L'utilisateur choisit exactement une réponse parmi [Question.choices].
  singleChoice,

  /// L'utilisateur peut choisir plusieurs réponses parmi [Question.choices].
  multipleChoice,
}

/// Modèle représentant une question de quiz.
///
/// Une question appartient à un [QuizTheme] via [themeId],
/// peut porter un média ([imageUrl] ou [audioUrl] selon [questionType]),
/// et définit comment l'utilisateur doit répondre via [answerType].
class Question {
  final String id;
  final String text;

  /// Chemin local vers l'image (non null uniquement si [questionType] == image).
  final String? imageUrl;

  /// Chemin local vers le fichier audio (non null uniquement si [questionType] == audio).
  final String? audioUrl;

  final QuestionType questionType;
  final AnswerType answerType;

  /// Propositions affichées pour les modes [AnswerType.singleChoice] et [AnswerType.multipleChoice].
  final List<String> choices;

  /// Réponses acceptées comme correctes.
  /// Pour une question ouverte, plusieurs formulations peuvent être listées.
  final List<String> correctAnswers;

  /// Identifiant du [QuizTheme] auquel cette question appartient.
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

  /// Construit une [Question] depuis un objet JSON stocké dans [SharedPreferences].
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

  /// Sérialise la question en JSON pour la persistance locale.
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

  /// Retourne une copie de la question avec les champs remplacés.
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
