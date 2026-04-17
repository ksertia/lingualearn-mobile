import 'dart:convert';

// --- RÉPONSE GLOBALE DE L'API ---
class StepMasterResponse {
  final bool success;
  final StepData data;

  StepMasterResponse({required this.success, required this.data});

  factory StepMasterResponse.fromJson(Map<String, dynamic> json) {
    return StepMasterResponse(
      success: json['success'] ?? false,
      // On parse l'objet "data" qui contient "step" et "content"
      data: StepData.fromJson(json['data'] ?? {}),
    );
  }
}

// --- DONNÉES DE L'ÉTAPE (STEP + CONTENT) ---
class StepData {
  final String id;
  final String title;
  final String type;   // 'lesson' ou 'quiz'
  final String format; // calculé : 'video', 'audio', 'pdf', 'quiz' ou 'text'
  final Content content;

  StepData({
    required this.id,
    required this.title,
    required this.type,
    required this.format,
    required this.content,
  });

  factory StepData.fromJson(Map<String, dynamic> json) {
    // On sépare les deux blocs du JSON
    final stepInfo = json['step'] ?? {};
    final contentJson = json['content'] ?? {};

    // On récupère le type (soit depuis stepType, soit depuis contentType)
    final String rawType = stepInfo['stepType'] ?? json['contentType'] ?? 'lesson';

    // LOGIQUE DE DÉTECTION DU FORMAT
    String detectedFormat = 'text';
    // On récupère l'URL et on la décode pour gérer les caractères spéciaux (Cloudinary)
    String? url = contentJson['videoUrl'] != null
        ? Uri.decodeFull(contentJson['videoUrl'])
        : null;

    if (rawType == 'quiz' || contentJson['questions'] != null) {
      detectedFormat = 'quiz';
    } else if (url != null) {
      String lowerUrl = url.toLowerCase();
      if (lowerUrl.contains('.mp3') || lowerUrl.contains('/audios/')) {
        detectedFormat = 'audio';
      } else if (lowerUrl.contains('.mp4') || lowerUrl.contains('/videos/')) {
        detectedFormat = 'video';
      } else if (lowerUrl.contains('.pdf')) {
        detectedFormat = 'pdf';
      }
    }

    return StepData(
      id: stepInfo['id']?.toString() ?? '',
      title: stepInfo['title'] ?? 'Sans titre',
      type: rawType,
      format: detectedFormat,
      content: Content.fromJson(contentJson, detectedFormat),
    );
  }
}

// --- LE CONTENU (TEXTE, MÉDIA OU QUESTIONS) ---
class Content {
  final String? text;
  final String? mediaUrl;
  final List<Question>? questions;

  Content({this.text, this.mediaUrl, this.questions});

  factory Content.fromJson(Map<String, dynamic> json, String format) {
    return Content(
      text: json['content'], // Le champ 'content' contient souvent le texte de la leçon
      mediaUrl: json['videoUrl'] != null ? Uri.decodeFull(json['videoUrl']) : null,
      questions: json['questions'] != null
          ? (json['questions'] as List)
          .map((q) => Question.fromJson(q))
          .toList()
          : null,
    );
  }
}

// --- LES QUESTIONS DU QUIZ ---
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
      text: json['questionText'] ?? '',
      type: json['questionType'] ?? 'multiple_choice',
      // On convertit proprement la liste dynamique en List<String>
      options: json['options'] != null
          ? List<String>.from(json['options'])
          : [],
      answer: json['correctAnswer'] ?? '',
    );
  }
}