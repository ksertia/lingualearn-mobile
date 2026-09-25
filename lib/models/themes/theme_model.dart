class ThemeModel {
  final String id;
  final String levelId;
  final String title;
  final String description;
  final String? iconUrl;
  final int index;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  // Présents seulement si `userId` est passé à GET /themes/level/{levelId} :
  // progression calculée à la volée (moyenne des sous-thèmes), pas de table dédiée.
  final String? state; // 'not_started' | 'in_progress' | 'completed'
  final num? progressPercentage;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? lastAccessedAt;

  ThemeModel({
    required this.id,
    required this.levelId,
    required this.title,
    required this.description,
    this.iconUrl,
    required this.index,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
    this.state,
    this.progressPercentage,
    this.startedAt,
    this.completedAt,
    this.lastAccessedAt,
  });

  bool get isCompleted => (state ?? '').toLowerCase() == 'completed';
  bool get isStarted => (state ?? '').toLowerCase() == 'in_progress' || startedAt != null;

  factory ThemeModel.fromJson(Map<String, dynamic> json) {
    return ThemeModel(
      id: json['id']?.toString() ?? '',
      levelId: json['levelId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      iconUrl: json['iconUrl']?.toString(),
      index: _toInt(json['index']),
      isActive: json['isActive'] == true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
      state: json['state']?.toString(),
      progressPercentage: json['progressPercentage'] is num
          ? json['progressPercentage'] as num
          : num.tryParse('${json['progressPercentage']}'),
      startedAt: json['startedAt'] != null ? DateTime.tryParse(json['startedAt'].toString()) : null,
      completedAt: json['completedAt'] != null ? DateTime.tryParse(json['completedAt'].toString()) : null,
      lastAccessedAt: json['lastAccessedAt'] != null ? DateTime.tryParse(json['lastAccessedAt'].toString()) : null,
    );
  }

  ThemeModel copyWith({
    String? state,
    num? progressPercentage,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? lastAccessedAt,
  }) {
    return ThemeModel(
      id: id,
      levelId: levelId,
      title: title,
      description: description,
      iconUrl: iconUrl,
      index: index,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: DateTime.now().toUtc(),
      state: state ?? this.state,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
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

// Réponse attendue de POST /users/{userId}/themes/{themeId}/start et
// .../complete — même forme que ModuleProgress (voir modul_model.dart),
// endpoints à faire développer côté backend sur ce modèle.
class ThemeProgress {
  final String? id;
  final String? userId;
  final String? themeId;
  final String? state;
  final String? progressPercentage;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? lastAccessedAt;

  ThemeProgress({
    this.id,
    this.userId,
    this.themeId,
    this.state,
    this.progressPercentage,
    this.startedAt,
    this.completedAt,
    this.lastAccessedAt,
  });

  factory ThemeProgress.fromJson(Map<String, dynamic> json) {
    return ThemeProgress(
      id: json['id']?.toString(),
      userId: json['userId']?.toString(),
      themeId: json['themeId']?.toString(),
      state: json['state']?.toString(),
      progressPercentage: json['progressPercentage']?.toString(),
      startedAt: json['startedAt'] != null ? DateTime.tryParse(json['startedAt'].toString()) : null,
      completedAt: json['completedAt'] != null ? DateTime.tryParse(json['completedAt'].toString()) : null,
      lastAccessedAt: json['lastAccessedAt'] != null ? DateTime.tryParse(json['lastAccessedAt'].toString()) : null,
    );
  }
}
