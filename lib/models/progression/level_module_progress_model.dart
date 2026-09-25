// Modèle pour GET /progress/user/{userId}/level/{levelId} — répartition des
// modules d'un niveau avec leur état réel (même champ `state` que partout
// ailleurs dans l'app : 'not_started' | 'in_progress' | 'completed').
class LevelModuleProgress {
  final String levelId;
  final String state;
  final num progressPercentage;
  final List<LevelModuleProgressItem> modules;

  LevelModuleProgress({
    required this.levelId,
    required this.state,
    required this.progressPercentage,
    required this.modules,
  });

  factory LevelModuleProgress.fromJson(Map<String, dynamic> json) {
    final modulesJson = json['modules'] is List ? json['modules'] as List : const [];
    return LevelModuleProgress(
      levelId: json['levelId']?.toString() ?? '',
      state: json['state']?.toString() ?? 'not_started',
      progressPercentage: _toNum(json['progressPercentage']),
      modules: modulesJson
          .map((m) => LevelModuleProgressItem.fromJson(Map<String, dynamic>.from(m as Map)))
          .toList(),
    );
  }
}

class LevelModuleProgressItem {
  final String id;
  final String title;
  final String state;
  final num progressPercentage;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? lastAccessedAt;

  LevelModuleProgressItem({
    required this.id,
    required this.title,
    required this.state,
    required this.progressPercentage,
    this.startedAt,
    this.completedAt,
    this.lastAccessedAt,
  });

  bool get isCompleted => state.toLowerCase() == 'completed';
  bool get isStarted => state.toLowerCase() == 'in_progress' || startedAt != null;

  factory LevelModuleProgressItem.fromJson(Map<String, dynamic> json) {
    return LevelModuleProgressItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      state: json['state']?.toString() ?? 'not_started',
      progressPercentage: _toNum(json['progressPercentage']),
      startedAt: json['startedAt'] != null ? DateTime.tryParse(json['startedAt'].toString()) : null,
      completedAt: json['completedAt'] != null ? DateTime.tryParse(json['completedAt'].toString()) : null,
      lastAccessedAt: json['lastAccessedAt'] != null ? DateTime.tryParse(json['lastAccessedAt'].toString()) : null,
    );
  }
}

num _toNum(dynamic value) {
  if (value is num) return value;
  return num.tryParse('$value') ?? 0;
}
