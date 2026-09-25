// Reflète la réponse de POST .../modules/{moduleId}/start et .../complete :
// { id, userId, moduleId, progressPercentage, totalXp, timeSpentMinutes,
//   unlockedAt, startedAt, completedAt, lastAccessedAt, createdAt, updatedAt, state }
class ModuleProgress {
  final String? id;
  final String? userId;
  final String? moduleId;
  final String? state; // 'not_started' | 'in_progress' | 'completed'
  final String? status; // ancien champ, conservé en repli si présent
  final String? progressPercentage;
  final int? totalXp;
  final int? timeSpentMinutes;
  final DateTime? unlockedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? lastAccessedAt;

  ModuleProgress({
    this.id,
    this.userId,
    this.moduleId,
    this.state,
    this.status,
    this.progressPercentage,
    this.totalXp,
    this.timeSpentMinutes,
    this.unlockedAt,
    this.startedAt,
    this.completedAt,
    this.lastAccessedAt,
  });

  factory ModuleProgress.fromJson(Map<String, dynamic> json) {
    return ModuleProgress(
      id: json['id']?.toString(),
      userId: json['userId']?.toString(),
      moduleId: json['moduleId']?.toString(),
      state: json['state']?.toString(),
      status: json['status']?.toString(),
      progressPercentage: json['progressPercentage']?.toString(),
      totalXp: json['totalXp'] is int ? json['totalXp'] : (json['totalXp'] != null ? int.tryParse(json['totalXp'].toString()) : null),
      timeSpentMinutes: json['timeSpentMinutes'] is int ? json['timeSpentMinutes'] : (json['timeSpentMinutes'] != null ? int.tryParse(json['timeSpentMinutes'].toString()) : null),
      unlockedAt: json['unlockedAt'] != null ? DateTime.tryParse(json['unlockedAt']) : null,
      startedAt: json['startedAt'] != null ? DateTime.tryParse(json['startedAt']) : null,
      completedAt: json['completedAt'] != null ? DateTime.tryParse(json['completedAt']) : null,
      lastAccessedAt: json['lastAccessedAt'] != null ? DateTime.tryParse(json['lastAccessedAt']) : null,
    );
  }
}

class ModuleModel {
  final String id;
  final String levelId;
  final String title;
  final String description;
  final String? iconUrl;
  final int index;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  // Champ réel renvoyé par le backend : 'not_started' | 'in_progress' | 'completed'.
  // Le backend ne connaît pas de valeur 'locked' — le verrouillage se calcule
  // côté client à partir de la séquence des modules (voir HomeController).
  final String? state;
  final String? status; // ancien champ, conservé en repli si présent
  final ModuleProgress? progress;
  final int? totalXp;
  final int? timeSpentMinutes;
  final String? progressPercentage;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? lastAccessedAt;

  ModuleModel({
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
    this.status,
    this.progress,
    this.totalXp,
    this.timeSpentMinutes,
    this.progressPercentage,
    this.startedAt,
    this.completedAt,
    this.lastAccessedAt,
  });

  bool get isCompleted =>
      (state ?? progress?.state ?? progress?.status ?? status ?? '')
          .toLowerCase() ==
      'completed';

  bool get isStarted =>
      (state ?? '').toLowerCase() == 'in_progress' || startedAt != null;

  factory ModuleModel.fromJson(Map<String, dynamic> json) {
    return ModuleModel(
      id: json['id'] ?? "",
      levelId: json['levelId'] ?? "",
      title: json['title'] ?? "Sans titre",
      description: json['description'] ?? "",
      iconUrl: (json['thumbnailUrl'] != null && json['thumbnailUrl'].toString().isNotEmpty)
          ? json['thumbnailUrl']
          : (json['iconUrl'] != null && json['iconUrl'].toString().isNotEmpty ? json['iconUrl'] : null),
      index: json['index'] ?? 0,
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
      state: json['state']?.toString(),
      status: json['status']?.toString(),
      progress: json['progress'] != null ? ModuleProgress.fromJson(Map<String, dynamic>.from(json['progress'])) : null,
      totalXp: json['totalXp'] is int ? json['totalXp'] : (json['totalXp'] != null ? int.tryParse(json['totalXp'].toString()) : null),
      timeSpentMinutes: json['timeSpentMinutes'] is int ? json['timeSpentMinutes'] : (json['timeSpentMinutes'] != null ? int.tryParse(json['timeSpentMinutes'].toString()) : null),
      progressPercentage: json['progressPercentage']?.toString(),
      startedAt: json['startedAt'] != null ? DateTime.tryParse(json['startedAt']) : null,
      completedAt: json['completedAt'] != null ? DateTime.tryParse(json['completedAt']) : null,
      lastAccessedAt: json['lastAccessedAt'] != null ? DateTime.tryParse(json['lastAccessedAt']) : null,
    );
  }

  ModuleModel copyWith({
    String? state,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? lastAccessedAt,
    String? progressPercentage,
  }) {
    return ModuleModel(
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
      status: status,
      progress: progress,
      totalXp: totalXp,
      timeSpentMinutes: timeSpentMinutes,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
    );
  }
}