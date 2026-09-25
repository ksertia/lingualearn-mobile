// Modèle pour un élément de GET /discover/languages
class DiscoverLanguage {
  final String id;
  final String code;
  final String name;
  final String description;
  final String? flagUrl;

  DiscoverLanguage({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    this.flagUrl,
  });

  factory DiscoverLanguage.fromJson(Map<String, dynamic> json) {
    return DiscoverLanguage(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      flagUrl: json['flagUrl']?.toString(),
    );
  }
}

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

class DemoLanguageData {
  final DemoSubTheme subTheme;
  final List<DemoContent> contents;

  DemoLanguageData({required this.subTheme, required this.contents});

  String get language => subTheme.theme.title.isNotEmpty ? subTheme.theme.title : 'Langue';

  factory DemoLanguageData.fromJson(Map<String, dynamic> json) {
    final contentsJson = json['contents'] is List ? json['contents'] as List : const [];

    return DemoLanguageData(
      subTheme: DemoSubTheme.fromJson(
        json['subTheme'] is Map
            ? Map<String, dynamic>.from(json['subTheme'])
            : {},
      ),
      contents: contentsJson
          .map((item) => DemoContent.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
    );
  }
}

class DemoSubTheme {
  final String id;
  final String title;
  final String description;
  final DemoTheme theme;

  DemoSubTheme({
    required this.id,
    required this.title,
    required this.description,
    required this.theme,
  });

  factory DemoSubTheme.fromJson(Map<String, dynamic> json) {
    return DemoSubTheme(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      theme: DemoTheme.fromJson(
        json['theme'] is Map ? Map<String, dynamic>.from(json['theme']) : {},
      ),
    );
  }
}

class DemoTheme {
  final String id;
  final String title;

  DemoTheme({required this.id, required this.title});

  factory DemoTheme.fromJson(Map<String, dynamic> json) {
    return DemoTheme(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
    );
  }
}

class DemoContent {
  final String id;
  final String contentType;
  final String title;
  final int index;
  final String? summary;
  final String? statement;
  final String? question;
  final List<String>? possibleAnswers;
  final List<DemoBlock> blocks;

  DemoContent({
    required this.id,
    required this.contentType,
    required this.title,
    required this.index,
    this.summary,
    this.statement,
    this.question,
    this.possibleAnswers,
    required this.blocks,
  });

  factory DemoContent.fromJson(Map<String, dynamic> json) {
    final blocksJson = json['blocks'] is List ? json['blocks'] as List : const [];
    return DemoContent(
      id: json['id']?.toString() ?? '',
      contentType: json['contentType']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      index: json['index'] is int ? json['index'] as int : int.tryParse('${json['index']}') ?? 0,
      summary: json['summary']?.toString(),
      statement: json['statement']?.toString(),
      question: json['question']?.toString(),
      possibleAnswers: json['possibleAnswers'] is List
          ? List<String>.from(json['possibleAnswers'].map((e) => e.toString()))
          : null,
      blocks: blocksJson
          .map((item) => DemoBlock.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
    );
  }
}

class DemoBlock {
  final String id;
  final String sectionType;
  final String blockType;
  final String content;
  final String? caption;
  final int index;

  DemoBlock({
    required this.id,
    required this.sectionType,
    required this.blockType,
    required this.content,
    this.caption,
    required this.index,
  });

  factory DemoBlock.fromJson(Map<String, dynamic> json) {
    return DemoBlock(
      id: json['id']?.toString() ?? '',
      sectionType: json['sectionType']?.toString() ?? '',
      blockType: json['blockType']?.toString() ?? 'text',
      content: json['content']?.toString() ?? '',
      caption: json['caption']?.toString(),
      index: json['index'] is int ? json['index'] as int : int.tryParse('${json['index']}') ?? 0,
    );
  }
}

// Résultat de POST /discover/demo/{contentId}/try
class DemoTryResult {
  final bool isCorrect;
  final String? explanation;

  DemoTryResult({required this.isCorrect, this.explanation});

  factory DemoTryResult.fromJson(Map<String, dynamic> json) {
    return DemoTryResult(
      isCorrect: json['isCorrect'] == true,
      explanation: json['explanation']?.toString(),
    );
  }
}

// Modèle pour GET /discover/languages/{code}/preview
class LanguagePreview {
  final String id;
  final String code;
  final String name;
  final String description;
  final String? flagUrl;
  final List<PreviewLevel> levels;

  LanguagePreview({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    this.flagUrl,
    required this.levels,
  });

  factory LanguagePreview.fromJson(Map<String, dynamic> json) {
    final levelsJson = json['levels'] is List ? json['levels'] as List : const [];
    return LanguagePreview(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      flagUrl: json['flagUrl']?.toString(),
      levels: levelsJson
          .map((item) => PreviewLevel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
    );
  }
}

class PreviewLevel {
  final String id;
  final String name;
  final String code;
  final String description;
  final int index;
  final List<PreviewModule> modules;

  PreviewLevel({
    required this.id,
    required this.name,
    required this.code,
    required this.description,
    required this.index,
    required this.modules,
  });

  factory PreviewLevel.fromJson(Map<String, dynamic> json) {
    final modulesJson = json['modules'] is List ? json['modules'] as List : const [];
    return PreviewLevel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      index: json['index'] is int ? json['index'] as int : int.tryParse('${json['index']}') ?? 0,
      modules: modulesJson
          .map((item) => PreviewModule.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
    );
  }
}

class PreviewModule {
  final String id;
  final String levelId;
  final String title;
  final String description;
  final int index;
  final List<PreviewTheme> themes;

  PreviewModule({
    required this.id,
    required this.levelId,
    required this.title,
    required this.description,
    required this.index,
    required this.themes,
  });

  factory PreviewModule.fromJson(Map<String, dynamic> json) {
    final themesJson = json['themes'] is List ? json['themes'] as List : const [];
    return PreviewModule(
      id: json['id']?.toString() ?? '',
      levelId: json['levelId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      index: json['index'] is int ? json['index'] as int : int.tryParse('${json['index']}') ?? 0,
      themes: themesJson
          .map((item) => PreviewTheme.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
    );
  }
}

class PreviewTheme {
  final String id;
  final String moduleId;
  final String title;
  final String description;
  final int index;

  PreviewTheme({
    required this.id,
    required this.moduleId,
    required this.title,
    required this.description,
    required this.index,
  });

  factory PreviewTheme.fromJson(Map<String, dynamic> json) {
    return PreviewTheme(
      id: json['id']?.toString() ?? '',
      moduleId: json['moduleId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      index: json['index'] is int ? json['index'] as int : int.tryParse('${json['index']}') ?? 0,
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
  final String? answerType;
  final String? answerValue;
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
      answerType: json['answerType'] as String?,
      answerValue: json['answerValue'] as String?,
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