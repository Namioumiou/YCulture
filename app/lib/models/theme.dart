/// Catégorie regroupant des [Question]s de même thématique.
///
/// Les thèmes sont créés par l'utilisateur et constituent
/// le point d'entrée pour lancer un quiz.
class QuizTheme {
  final String id;
  final String name;
  final String description;

  /// Chemin optionnel vers une icône personnalisée pour ce thème.
  final String? iconUrl;

  QuizTheme({
    required this.id,
    required this.name,
    required this.description,
    this.iconUrl,
  });

  /// Construit un [QuizTheme] depuis un objet JSON stocké dans [SharedPreferences].
  factory QuizTheme.fromJson(Map<String, dynamic> json) => QuizTheme(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        iconUrl: json['iconUrl'] as String?,
      );

  /// Sérialise le thème en JSON pour la persistance locale.
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'iconUrl': iconUrl,
      };

  /// Retourne une copie du thème avec les champs remplacés.
  QuizTheme copyWith({
    String? id,
    String? name,
    String? description,
    String? iconUrl,
  }) {
    return QuizTheme(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconUrl: iconUrl ?? this.iconUrl,
    );
  }
}
