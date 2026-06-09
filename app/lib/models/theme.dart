/// A category that groups related [Question]s together.
class QuizTheme {
  final String id;
  final String name;
  final String description;

  /// Optional path to a custom icon image for this theme.
  final String? iconUrl;

  QuizTheme({
    required this.id,
    required this.name,
    required this.description,
    this.iconUrl,
  });

  factory QuizTheme.fromJson(Map<String, dynamic> json) => QuizTheme(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        iconUrl: json['iconUrl'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'iconUrl': iconUrl,
      };

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
