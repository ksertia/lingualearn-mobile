class ContentModel {
  final String id;
  final String subThemeId;
  final String contentType;
  final String title;
  final int index;
  final bool isActive;
  final String? summary;
  final String? videoUrl;
  final String? description;
  final List<String>? keyPoints;
  final String? statement;
  final String? question;
  final List<String>? possibleAnswers;
  final String? correctAnswer;
  final String? explanation;
  final String? resourceType;
  final String? resourceUrl;
  final List<ContentBlockModel> blocks;

  ContentModel({
    required this.id,
    required this.subThemeId,
    required this.contentType,
    required this.title,
    required this.index,
    required this.isActive,
    this.summary,
    this.videoUrl,
    this.description,
    this.keyPoints,
    this.statement,
    this.question,
    this.possibleAnswers,
    this.correctAnswer,
    this.explanation,
    this.resourceType,
    this.resourceUrl,
    required this.blocks,
  });

  factory ContentModel.fromJson(Map<String, dynamic> json) {
    final blocksRaw = json['blocks'] is List ? json['blocks'] as List : [];
    final blocks = blocksRaw
        .map((b) =>
            ContentBlockModel.fromJson(Map<String, dynamic>.from(b as Map)))
        .toList()
      ..sort((a, b) => a.index.compareTo(b.index));

    return ContentModel(
      id: json['id']?.toString() ?? '',
      subThemeId: json['subThemeId']?.toString() ?? '',
      contentType: json['contentType']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      index: _toInt(json['index']),
      isActive: json['isActive'] == true,
      summary: json['summary']?.toString(),
      videoUrl: json['videoUrl']?.toString(),
      description: json['description']?.toString(),
      keyPoints:
          json['keyPoints'] is List ? List<String>.from(json['keyPoints']) : null,
      statement: json['statement']?.toString(),
      question: json['question']?.toString(),
      possibleAnswers: json['possibleAnswers'] is List
          ? List<String>.from(json['possibleAnswers'])
          : null,
      correctAnswer: json['correctAnswer']?.toString(),
      explanation: json['explanation']?.toString(),
      resourceType: json['resourceType']?.toString(),
      resourceUrl: json['resourceUrl']?.toString(),
      blocks: blocks,
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

class ContentBlockModel {
  final String id;
  final String contentId;
  final String sectionType;
  final String blockType;
  final String content;
  final String? caption;
  final int index;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ContentBlockModel({
    required this.id,
    required this.contentId,
    required this.sectionType,
    required this.blockType,
    required this.content,
    this.caption,
    required this.index,
    this.createdAt,
    this.updatedAt,
  });

  factory ContentBlockModel.fromJson(Map<String, dynamic> json) {
    return ContentBlockModel(
      id: json['id']?.toString() ?? '',
      contentId: json['contentId']?.toString() ?? '',
      sectionType: json['sectionType']?.toString() ?? 'main',
      blockType: json['blockType']?.toString() ?? 'text',
      content: json['content']?.toString() ?? '',
      caption: json['caption']?.toString(),
      index: ContentModel._toInt(json['index']),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }
}
