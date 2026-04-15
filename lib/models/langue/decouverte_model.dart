// Modèle pour la structure globale (Leçons + Exercices)
class LanguageData {
  final List<Section> lessons;
  final List<Section> exercises;

  LanguageData({required this.lessons, required this.exercises});

  String get language {
    if (lessons.isNotEmpty) return lessons.first.language;
    if (exercises.isNotEmpty) return exercises.first.language;
    return "Langue";
  }

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

class Section {
  final String id;
  final String title;
  final String type;
  final String language;
  final int order;
  final DateTime createdAt;
  final DateTime updatedAt;
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

class Content {
  final String id;
  final String questionType; 
  final String questionValue;
  final String answerType;
  final String answerValue;
  final int order;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Option> options;

  Content({
    required this.id,
    required this.questionType,
    required this.questionValue,
    required this.answerType,
    required this.answerValue,
    required this.order,
    required this.createdAt,
    required this.updatedAt,
    required this.options,
  });

  factory Content.fromJson(Map<String, dynamic> json) {
    return Content(
      id: json['id'] ?? '',
      questionType: json['questionType'] ?? 'text',
      questionValue: json['questionValue'] ?? '',
      answerType: json['answerType'] ?? 'text',
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

class Option {
  final String id;
  final String value;
  final bool isCorrect;
  final int order;

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