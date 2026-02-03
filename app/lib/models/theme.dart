class QuizTheme {
  final String id;
  final String name;
  final String description;
  final String? iconUrl;

  QuizTheme({
    required this.id,
    required this.name,
    required this.description,
    this.iconUrl,
  });

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
