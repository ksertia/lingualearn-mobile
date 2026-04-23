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
    final String? rawUrl = contentJson['videoUrl']?.toString();
    final String? url = rawUrl != null ? Uri.decodeFull(rawUrl) : null;

    if (rawType == 'quiz' || contentJson['questions'] != null) {
      detectedFormat = 'quiz';
    } else if (url != null) {
      final lowerUrl = url.toLowerCase();
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
    return Content(
      text: json['content']?.toString(),
      mediaUrl: json['videoUrl'] != null
          ? Uri.decodeFull(json['videoUrl'].toString())
          : null,
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
