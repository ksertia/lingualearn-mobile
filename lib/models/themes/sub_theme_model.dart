class SubThemeModel {
  final String id;
  final String themeId;
  final String title;
  final String description;
  final int index;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  // Présents seulement si `userId` est passé à GET /sub-themes/theme/{themeId}.
  final String? state; // 'not_started' | 'in_progress' | 'completed'
  final num? progressPercentage;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? lastAccessedAt;

  SubThemeModel({
    required this.id,
    required this.themeId,
    required this.title,
    required this.description,
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

  factory SubThemeModel.fromJson(Map<String, dynamic> json) {
    return SubThemeModel(
      id: json['id']?.toString() ?? '',
      themeId: json['themeId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
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

  SubThemeModel copyWith({
    String? state,
    num? progressPercentage,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? lastAccessedAt,
  }) {
    return SubThemeModel(
      id: id,
      themeId: themeId,
      title: title,
      description: description,
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

// Réponse attendue de POST /users/{userId}/sub-themes/{subThemeId}/start et
// .../complete — même forme que ModuleProgress, endpoints à faire développer
// côté backend sur ce modèle (le champ `progress` toujours null dans la
// réponse de liste laisse penser qu'une vraie table dédiée existe déjà,
// contrairement au Theme).
class SubThemeProgress {
  final String? id;
  final String? userId;
  final String? subThemeId;
  final String? state;
  final String? progressPercentage;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? lastAccessedAt;

  SubThemeProgress({
    this.id,
    this.userId,
    this.subThemeId,
    this.state,
    this.progressPercentage,
    this.startedAt,
    this.completedAt,
    this.lastAccessedAt,
  });

  factory SubThemeProgress.fromJson(Map<String, dynamic> json) {
    return SubThemeProgress(
      id: json['id']?.toString(),
      userId: json['userId']?.toString(),
      subThemeId: json['subThemeId']?.toString(),
      state: json['state']?.toString(),
      progressPercentage: json['progressPercentage']?.toString(),
      startedAt: json['startedAt'] != null ? DateTime.tryParse(json['startedAt'].toString()) : null,
      completedAt: json['completedAt'] != null ? DateTime.tryParse(json['completedAt'].toString()) : null,
      lastAccessedAt: json['lastAccessedAt'] != null ? DateTime.tryParse(json['lastAccessedAt'].toString()) : null,
    );
  }
}
