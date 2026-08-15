class StepMasterResponse {
  final bool success;
  final StepData data;

  StepMasterResponse({required this.success, required this.data});

  factory StepMasterResponse.fromJson(Map<String, dynamic> json) {
    return StepMasterResponse(
      success: json['success'] ?? false,
      data: StepData.fromJson(Map<String, dynamic>.from(json['data'] as Map? ?? {})),
    );
  }
}

class StepData {
  final String id;
  final String title;
  final String type;
  final String format;
  final Content content;

  StepData({
    required this.id,
    required this.title,
    required this.type,
    required this.format,
    required this.content,
  });

  factory StepData.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> stepInfo = json['step'] is Map
        ? Map<String, dynamic>.from(json['step'] as Map)
        : {};

    final Map<String, dynamic> contentJson = json['content'] is Map
        ? Map<String, dynamic>.from(json['content'] as Map)
        : {};

    final String rawType =
        stepInfo['stepType']?.toString() ??
        json['contentType']?.toString() ??
        'lesson';

    String detectedFormat = 'text';
    // Simple détection de motif sur la chaîne brute — jamais décodée ici :
    // le contenu peut être du texte libre (pas une URL), et Uri.decodeFull
    // plante avec "Illegal percent encoding" dès qu'il contient un "%".
    final String? rawUrl = contentJson['content']?.toString();

    if (rawType == 'quiz' || contentJson['questions'] != null) {
      detectedFormat = 'quiz';
    } else if (rawUrl != null) {
      final lowerUrl = rawUrl.toLowerCase();
      if (lowerUrl.contains('.mp3') || lowerUrl.contains('/audios/')) {
        detectedFormat = 'audio';
      } else if (lowerUrl.contains('.mp4') || lowerUrl.contains('/videos/')) {
        detectedFormat = 'video';
      } else if (lowerUrl.contains('.pdf')) {
        detectedFormat = 'pdf';
      } else if (lowerUrl.contains('.png') ||
          lowerUrl.contains('.jpg') ||
          lowerUrl.contains('.jpeg') ||
          lowerUrl.contains('.webp')) {
        detectedFormat = 'image';
      }
    }

    return StepData(
      id: stepInfo['id']?.toString() ?? '',
      title: stepInfo['title']?.toString() ?? 'Sans titre',
      type: rawType,
      format: detectedFormat,
      content: Content.fromJson(contentJson, detectedFormat),
    );
  }
}

class Content {
  final String? text;
  final String? mediaUrl;
  final List<Question>? questions;

  Content({this.text, this.mediaUrl, this.questions});

  factory Content.fromJson(Map<String, dynamic> json, String format) {
    // Le champ "content" de l'API porte soit l'URL du média (audio/video/image/pdf),
    // soit le texte brut d'une leçon textuelle — jamais les deux à la fois.
    final String? rawValue = json['content']?.toString();
    final bool isMedia = format == 'audio' ||
        format == 'video' ||
        format == 'image' ||
        format == 'pdf';

    String? decodedMediaUrl;
    if (isMedia && rawValue != null) {
      try {
        decodedMediaUrl = Uri.decodeFull(rawValue);
      } catch (_) {
        decodedMediaUrl = rawValue;
      }
    }

    return Content(
      text: isMedia ? null : rawValue,
      mediaUrl: decodedMediaUrl,
      questions: json['questions'] is List
          ? (json['questions'] as List)
              .map((q) => Question.fromJson(
                  q is Map ? Map<String, dynamic>.from(q) : {}))
              .toList()
          : null,
    );
  }
}

class Question {
  final String text;
  final String type;
  final List<String> options;
  final String answer;

  Question({
    required this.text,
    required this.type,
    required this.options,
    required this.answer,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      text: json['questionText']?.toString() ?? '',
      type: json['questionType']?.toString() ?? 'multiple_choice',
      options: json['options'] is List
          ? List<String>.from(json['options'] as List)
          : [],
      answer: json['correctAnswer']?.toString() ?? '',
    );
  }
}

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

/// Réponse de GET /courses/step/{stepId}/lessons — une leçon composée de
/// plusieurs blocs de contenu (texte/vidéo/image/audio), groupés par section.
class LessonContent {
  final String id;
  final String title;
  final String? summary;
  final String stepId;
  final bool isActive;
  final List<LessonBlock> blocks;
  final StepInfo stepInfo;
  final LessonUserProgress? userProgress;

  LessonContent({
    required this.id,
    required this.title,
    this.summary,
    required this.stepId,
    required this.isActive,
    required this.blocks,
    required this.stepInfo,
    this.userProgress,
  });

  factory LessonContent.fromJson(Map<String, dynamic> json) {
    final List blocksRaw = json['blocks'] is List ? json['blocks'] as List : [];
    final blocks = blocksRaw
        .map((b) => LessonBlock.fromJson(Map<String, dynamic>.from(b as Map)))
        .toList()
      ..sort((a, b) => a.index.compareTo(b.index));

    return LessonContent(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Sans titre',
      summary: json['summary']?.toString(),
      stepId: json['stepId']?.toString() ?? '',
      isActive: json['isActive'] == true,
      blocks: blocks,
      stepInfo: StepInfo.fromJson(json['stepInfo'] is Map
          ? Map<String, dynamic>.from(json['stepInfo'] as Map)
          : {}),
      userProgress: json['userProgress'] is Map
          ? LessonUserProgress.fromJson(
              Map<String, dynamic>.from(json['userProgress'] as Map))
          : null,
    );
  }
}

class LessonBlock {
  final String id;
  final String sectionType;
  final String contentType;
  final String content;
  final String? caption;
  final int index;

  LessonBlock({
    required this.id,
    required this.sectionType,
    required this.contentType,
    required this.content,
    this.caption,
    required this.index,
  });

  factory LessonBlock.fromJson(Map<String, dynamic> json) {
    return LessonBlock(
      id: json['id']?.toString() ?? '',
      sectionType: json['sectionType']?.toString() ?? 'main',
      contentType: json['contentType']?.toString() ?? 'text',
      content: json['content']?.toString() ?? '',
      caption: json['caption']?.toString(),
      index: _toInt(json['index']),
    );
  }
}

class StepInfo {
  final String id;
  final String title;
  final String description;
  final int estimatedMinutes;

  StepInfo({
    required this.id,
    required this.title,
    required this.description,
    required this.estimatedMinutes,
  });

  factory StepInfo.fromJson(Map<String, dynamic> json) {
    return StepInfo(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      estimatedMinutes: _toInt(json['estimatedMinutes']),
    );
  }
}

class LessonUserProgress {
  final String status;
  final double progressPercentage;
  final double? score;
  final DateTime? startedAt;
  final DateTime? completedAt;

  LessonUserProgress({
    required this.status,
    required this.progressPercentage,
    this.score,
    this.startedAt,
    this.completedAt,
  });

  factory LessonUserProgress.fromJson(Map<String, dynamic> json) {
    return LessonUserProgress(
      status: json['status']?.toString() ?? 'not_started',
      progressPercentage:
          double.tryParse(json['progressPercentage']?.toString() ?? '') ?? 0,
      score: json['score'] == null
          ? null
          : double.tryParse(json['score'].toString()),
      startedAt: json['startedAt'] != null
          ? DateTime.tryParse(json['startedAt'].toString())
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'].toString())
          : null,
    );
  }
}
