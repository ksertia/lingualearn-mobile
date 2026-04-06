enum DiscoveryType { audio, video, qcm, drag }

class DiscoveryStep {
  final String id;
  final DiscoveryType type;

  // --- CONTENU AUDIO ---
  final String? texteOriginal; 
  final String? traduction;

  // --- CONTENU VIDÉO ---
  final String? videoTitle;
  final String? videoUrl;

  // --- CONTENU QUIZ QCM ---
  final String? question;
  final List<String>? options;
  final String? correctOption;

  // --- CONTENU DRAG & DROP ---
  final List<Map<String, String>>? choix;

  DiscoveryStep({
    required this.id,
    required this.type,
    this.texteOriginal,
    this.traduction,
    this.videoTitle,
    this.videoUrl,
    this.question,
    this.options,
    this.correctOption,
    this.choix,
  });

  factory DiscoveryStep.fromJson(Map<String, dynamic> json) {
    return DiscoveryStep(
      id: json['id']?.toString() ?? '',
      type: _parseType(json['type']),
      
      // Récupération des textes
      texteOriginal: json['texteOriginal'],
      traduction: json['traduction'],
      
      // Vidéo
      videoTitle: json['videoTitle'],
      videoUrl: json['videoUrl'],
      
      // QCM
      question: json['question'],
      options: json['options'] != null ? List<String>.from(json['options']) : null,
      correctOption: json['correctOption'],

      // Drag & Drop (on garde ton format List<Map>)
      choix: json['choix'] != null 
          ? List<Map<String, String>>.from(
              (json['choix'] as List).map((e) => Map<String, String>.from(e))
            )
          : null,
    );
  }

  static DiscoveryType _parseType(String? type) {
    switch (type) {
      case 'video': return DiscoveryType.video;
      case 'qcm': return DiscoveryType.qcm;
      case 'drag': return DiscoveryType.drag;
      default: return DiscoveryType.audio;
    }
  }
}