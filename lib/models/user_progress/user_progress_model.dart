class ProgressLanguageInfo {
  final String id;
  final String name;
  final String code;
  final String? flagUrl;
  final String status;
  final int progressPercentage;
  final DateTime? lastAccessedAt;

  ProgressLanguageInfo({
    required this.id,
    required this.name,
    required this.code,
    this.flagUrl,
    required this.status,
    required this.progressPercentage,
    this.lastAccessedAt,
  });

  factory ProgressLanguageInfo.fromJson(Map<String, dynamic> json) {
    return ProgressLanguageInfo(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      flagUrl: json['flagUrl'] as String?,
      status: json['status'] as String? ?? '',
      progressPercentage: (json['progressPercentage'] as num?)?.toInt() ?? 0,
      lastAccessedAt: json['lastAccessedAt'] != null
          ? DateTime.tryParse(json['lastAccessedAt'] as String)
          : null,
    );
  }
}

class ProgressLevelInfo {
  final String id;
  final String name;
  final String code;
  final String status;
  final int totalModules;
  final int completedModules;
  final int progressPercentage;

  ProgressLevelInfo({
    required this.id,
    required this.name,
    required this.code,
    required this.status,
    required this.totalModules,
    required this.completedModules,
    required this.progressPercentage,
  });

  factory ProgressLevelInfo.fromJson(Map<String, dynamic> json) {
    return ProgressLevelInfo(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      status: json['status'] as String? ?? '',
      totalModules: (json['totalModules'] as num?)?.toInt() ?? 0,
      completedModules: (json['completedModules'] as num?)?.toInt() ?? 0,
      progressPercentage: (json['progressPercentage'] as num?)?.toInt() ?? 0,
    );
  }
}

class ProgressModuleInfo {
  final String id;
  final String title;
  final String status;
  final int totalPaths;
  final int completedPaths;
  final int progressPercentage;

  ProgressModuleInfo({
    required this.id,
    required this.title,
    required this.status,
    required this.totalPaths,
    required this.completedPaths,
    required this.progressPercentage,
  });

  factory ProgressModuleInfo.fromJson(Map<String, dynamic> json) {
    return ProgressModuleInfo(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      status: json['status'] as String? ?? '',
      totalPaths: (json['totalPaths'] as num?)?.toInt() ?? 0,
      completedPaths: (json['completedPaths'] as num?)?.toInt() ?? 0,
      progressPercentage: (json['progressPercentage'] as num?)?.toInt() ?? 0,
    );
  }
}

class ProgressPathInfo {
  final String id;
  final String title;
  final String status;
  final int totalSteps;
  final int completedSteps;
  final int progressPercentage;

  ProgressPathInfo({
    required this.id,
    required this.title,
    required this.status,
    required this.totalSteps,
    required this.completedSteps,
    required this.progressPercentage,
  });

  factory ProgressPathInfo.fromJson(Map<String, dynamic> json) {
    return ProgressPathInfo(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      status: json['status'] as String? ?? '',
      totalSteps: (json['totalSteps'] as num?)?.toInt() ?? 0,
      completedSteps: (json['completedSteps'] as num?)?.toInt() ?? 0,
      progressPercentage: (json['progressPercentage'] as num?)?.toInt() ?? 0,
    );
  }
}

class ProgressStepInfo {
  final String id;
  final String title;
  final String stepType;
  final String status;
  final int progressPercentage;
  final int? score;

  ProgressStepInfo({
    required this.id,
    required this.title,
    required this.stepType,
    required this.status,
    required this.progressPercentage,
    this.score,
  });

  factory ProgressStepInfo.fromJson(Map<String, dynamic> json) {
    return ProgressStepInfo(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      stepType: json['stepType'] as String? ?? '',
      status: json['status'] as String? ?? '',
      progressPercentage: (json['progressPercentage'] as num?)?.toInt() ?? 0,
      score: (json['score'] as num?)?.toInt(),
    );
  }
}

class UserProgressEntry {
  final ProgressLanguageInfo language;
  final ProgressLevelInfo level;
  final ProgressModuleInfo? module;
  final ProgressPathInfo? path;
  final ProgressStepInfo? step;

  UserProgressEntry({
    required this.language,
    required this.level,
    this.module,
    this.path,
    this.step,
  });

  factory UserProgressEntry.fromJson(Map<String, dynamic> json) {
    final moduleJson = json['module'];
    final pathJson = json['path'];
    final stepJson = json['step'];
    return UserProgressEntry(
      language: ProgressLanguageInfo.fromJson(
          Map<String, dynamic>.from(json['language'] as Map)),
      level: ProgressLevelInfo.fromJson(
          Map<String, dynamic>.from(json['level'] as Map)),
      module: moduleJson != null
          ? ProgressModuleInfo.fromJson(Map<String, dynamic>.from(moduleJson as Map))
          : null,
      path: pathJson != null
          ? ProgressPathInfo.fromJson(Map<String, dynamic>.from(pathJson as Map))
          : null,
      step: stepJson != null
          ? ProgressStepInfo.fromJson(Map<String, dynamic>.from(stepJson as Map))
          : null,
    );
  }
}
