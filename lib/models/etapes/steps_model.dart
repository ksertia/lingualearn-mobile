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
