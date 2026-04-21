class ChildProgressChildModel {
  final String id;
  final String? username;
  final String? email;

  const ChildProgressChildModel({
    required this.id,
    this.username,
    this.email,
  });

  factory ChildProgressChildModel.fromJson(Map<String, dynamic> json) {
    return ChildProgressChildModel(
      id: (json['id'] ?? '').toString(),
      username: json['username']?.toString(),
      email: json['email']?.toString(),
    );
  }
}

class ChildProgressLanguageModel {
  final String id;
  final String? name;
  final String? code;
  final String? flagUrl;
  final String? status;
  final double progressPercentage;
  final String? lastAccessedAt;

  const ChildProgressLanguageModel({
    required this.id,
    this.name,
    this.code,
    this.flagUrl,
    this.status,
    required this.progressPercentage,
    this.lastAccessedAt,
  });

  factory ChildProgressLanguageModel.fromJson(Map<String, dynamic> json) {
    final raw = json['progressPercentage'];
    final val = raw is num ? raw.toDouble() : double.tryParse('$raw') ?? 0;

    return ChildProgressLanguageModel(
      id: (json['id'] ?? '').toString(),
      name: json['name']?.toString(),
      code: json['code']?.toString(),
      flagUrl: json['flagUrl']?.toString(),
      status: json['status']?.toString(),
      progressPercentage: val,
      lastAccessedAt: json['lastAccessedAt']?.toString(),
    );
  }
}

class ChildProgressLevelModel {
  final String id;
  final String? name;
  final String? code;
  final String? status;
  final int? totalModules;
  final int? completedModules;
  final double progressPercentage;

  const ChildProgressLevelModel({
    required this.id,
    this.name,
    this.code,
    this.status,
    this.totalModules,
    this.completedModules,
    required this.progressPercentage,
  });

  factory ChildProgressLevelModel.fromJson(Map<String, dynamic> json) {
    final raw = json['progressPercentage'];
    final val = raw is num ? raw.toDouble() : double.tryParse('$raw') ?? 0;

    int? toInt(dynamic v) {
      if (v is int) return v;
      return int.tryParse('$v');
    }

    return ChildProgressLevelModel(
      id: (json['id'] ?? '').toString(),
      name: json['name']?.toString(),
      code: json['code']?.toString(),
      status: json['status']?.toString(),
      totalModules: toInt(json['totalModules']),
      completedModules: toInt(json['completedModules']),
      progressPercentage: val,
    );
  }
}

class ChildProgressItemModel {
  final ChildProgressLanguageModel? language;
  final ChildProgressLevelModel? level;
  final dynamic module;
  final dynamic path;
  final dynamic step;

  const ChildProgressItemModel({
    this.language,
    this.level,
    this.module,
    this.path,
    this.step,
  });

  factory ChildProgressItemModel.fromJson(Map<String, dynamic> json) {
    final languageJson = json['language'];
    final levelJson = json['level'];

    return ChildProgressItemModel(
      language: languageJson is Map<String, dynamic>
          ? ChildProgressLanguageModel.fromJson(languageJson)
          : languageJson is Map
              ? ChildProgressLanguageModel.fromJson(
                  Map<String, dynamic>.from(languageJson),
                )
              : null,
      level: levelJson is Map<String, dynamic>
          ? ChildProgressLevelModel.fromJson(levelJson)
          : levelJson is Map
              ? ChildProgressLevelModel.fromJson(
                  Map<String, dynamic>.from(levelJson),
                )
              : null,
      module: json['module'],
      path: json['path'],
      step: json['step'],
    );
  }
}

class ChildProgressResponseModel {
  final bool success;
  final ChildProgressChildModel? child;
  final List<ChildProgressItemModel> data;

  const ChildProgressResponseModel({
    required this.success,
    this.child,
    this.data = const [],
  });

  factory ChildProgressResponseModel.fromJson(Map<String, dynamic> json) {
    final childJson = json['child'];
    final dataJson = json['data'];
    final items = <ChildProgressItemModel>[];

    if (dataJson is List) {
      for (final e in dataJson) {
        if (e is Map<String, dynamic>) {
          items.add(ChildProgressItemModel.fromJson(e));
        } else if (e is Map) {
          items.add(
            ChildProgressItemModel.fromJson(Map<String, dynamic>.from(e)),
          );
        }
      }
    } else if (dataJson is Map<String, dynamic>) {
      items.add(ChildProgressItemModel.fromJson(dataJson));
    } else if (dataJson is Map) {
      items.add(
        ChildProgressItemModel.fromJson(Map<String, dynamic>.from(dataJson)),
      );
    }

    return ChildProgressResponseModel(
      success: json['success'] == true,
      child: childJson is Map<String, dynamic>
          ? ChildProgressChildModel.fromJson(childJson)
          : childJson is Map
              ? ChildProgressChildModel.fromJson(
                  Map<String, dynamic>.from(childJson),
                )
              : null,
      data: items,
    );
  }
}
