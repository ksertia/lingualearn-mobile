// Modèle pour la structure globale (Leçons + Exercices)
class LanguageData {
  final List<Section> lessons;
  final List<Section> exercises;

  LanguageData({required this.lessons, required this.exercises});

  factory LanguageData.fromJson(Map<String, dynamic> json) {
    return LanguageData(
      lessons: (json['lessons'] as List? ?? [])
          .map((item) => Section.fromJson(item))
          .toList(),
      exercises: (json['exercises'] as List? ?? [])
          .map((item) => Section.fromJson(item))
          .toList(),
    );
  }

}

// Modèle pour une Section (qu'elle soit leçon ou exercice)
class Section {
  final String id;
  final String title;
  final String type;
  final String language;
  final int order; // Ajouté
  final DateTime createdAt; // Ajouté
  final DateTime updatedAt; // Ajouté
  final List<Content> contents;

  Section({
    required this.id,
    required this.title,
    required this.type,
    required this.language,
    required this.order,
    required this.createdAt,
    required this.updatedAt,
    required this.contents,
  });

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      type: json['type'] ?? '',
      language: json['language'] ?? '',
      order: json['order'] ?? 0,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      contents: (json['contents'] as List? ?? [])
          .map((item) => Content.fromJson(item))
          .toList(),
    );
  }
}

// Modèle pour le contenu à l'intérieur d'une section
class Content {
  final String id;
  final String questionValue;
  final String answerValue;
  final int order; // Ajouté (présent dans ton JSON de contenu)
  final DateTime createdAt; // Ajouté
  final DateTime updatedAt; // Ajouté
  final List<Option> options;

  Content({
    required this.id,
    required this.questionValue,
    required this.answerValue,
    required this.order,
    required this.createdAt,
    required this.updatedAt,
    required this.options,
  });

  factory Content.fromJson(Map<String, dynamic> json) {
    return Content(
      id: json['id'] ?? '',
      questionValue: json['questionValue'] ?? '',
      answerValue: json['answerValue'] ?? '',
      order: json['order'] ?? 0,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      options: (json['options'] as List? ?? [])
          .map((item) => Option.fromJson(item))
          .toList(),
    );
  }
}

// Modèle pour les options (spécifique aux exercices)
class Option {
  final String id; // Ajouté car présent dans le JSON des options
  final String value;
  final bool isCorrect;
  final int order; // Ajouté

  Option({
    required this.id,
    required this.value, 
    required this.isCorrect,
    required this.order,
  });

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      id: json['id'] ?? '',
      value: json['value'] ?? '',
      isCorrect: json['isCorrect'] ?? false,
      order: json['order'] ?? 0,
    );
  }
}