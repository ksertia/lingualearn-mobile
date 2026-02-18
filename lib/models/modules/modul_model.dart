import 'package:fasolingo/models/parcoure/parcour_model.dart';


class ModuleProgress {
  final String? id;
  final String? userId;
  final String? moduleId;
  final String? status;
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
  final List<LearningPathModel>? paths;
  final String? status; // 'locked' | 'unlocked' | 'completed'
  final ModuleProgress? progress;
  final int? totalXp;
  final int? timeSpentMinutes;
  final String? progressPercentage;

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
    this.paths,
    this.status,
    this.progress,
    this.totalXp,
    this.timeSpentMinutes,
    this.progressPercentage,
  });

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
      paths: json['paths'] != null
          ? (json['paths'] as List).map((p) => LearningPathModel.fromJson(Map<String, dynamic>.from(p))).toList()
          : null,
      status: json['status']?.toString(),
      progress: json['progress'] != null ? ModuleProgress.fromJson(Map<String, dynamic>.from(json['progress'])) : null,
      totalXp: json['totalXp'] is int ? json['totalXp'] : (json['totalXp'] != null ? int.tryParse(json['totalXp'].toString()) : null),
      timeSpentMinutes: json['timeSpentMinutes'] is int ? json['timeSpentMinutes'] : (json['timeSpentMinutes'] != null ? int.tryParse(json['timeSpentMinutes'].toString()) : null),
      progressPercentage: json['progressPercentage']?.toString(),
    );
  }
}