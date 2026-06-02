import 'package:intl/intl.dart';

// ── Top-level model ───────────────────────────────────────────────────────────

class ProgressionDetailModel {
  final String userId;
  final ProgLanguage language;
  final ProgOverall overallProgress;
  final List<ProgLevel> levels;

  const ProgressionDetailModel({
    required this.userId,
    required this.language,
    required this.overallProgress,
    required this.levels,
  });

  factory ProgressionDetailModel.fromJson(Map<String, dynamic> j) {
    return ProgressionDetailModel(
      userId:          j['user']?.toString() ?? '',
      language:        ProgLanguage.fromJson(j['language'] ?? {}),
      overallProgress: ProgOverall.fromJson(j['overallProgress'] ?? {}),
      levels: (j['levels'] as List? ?? [])
          .map((l) => ProgLevel.fromJson(l as Map<String, dynamic>))
          .toList(),
    );
  }

  // ── Computed totals across all levels ──────────────────────────────────────

  int get totalModules =>
      levels.fold(0, (s, l) => s + l.modules.length);

  int get completedModules =>
      levels.fold(0, (s, l) => s + l.completedModuleCount);

  int get inProgressModules =>
      levels.fold(0, (s, l) => s + l.inProgressModuleCount);

  int get lockedModules =>
      levels.fold(0, (s, l) => s + l.lockedModuleCount);

  /// Average quiz score across all non-null path scores (0–100)
  int get avgQuizScore {
    final scores = levels
        .expand((l) => l.modules)
        .expand((m) => m.paths)
        .map((p) => p.userProgress?.quizScore)
        .whereType<num>()
        .map((v) => v.toDouble())
        .toList();
    if (scores.isEmpty) return 0;
    return (scores.reduce((a, b) => a + b) / scores.length).round();
  }
}

// ── Language ──────────────────────────────────────────────────────────────────

class ProgLanguage {
  final String id, code, name, description;
  final String? iconUrl, flagUrl;

  const ProgLanguage({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    this.iconUrl,
    this.flagUrl,
  });

  factory ProgLanguage.fromJson(Map<String, dynamic> j) => ProgLanguage(
        id:          j['id']?.toString() ?? '',
        code:        j['code']?.toString() ?? '',
        name:        j['name']?.toString() ?? '',
        description: j['description']?.toString() ?? '',
        iconUrl:     j['iconUrl']?.toString(),
        flagUrl:     j['flagUrl']?.toString(),
      );
}

// ── Overall progress ──────────────────────────────────────────────────────────

class ProgOverall {
  final String id, status;
  final int totalXp, totalTimeMinutes;
  final String overallProgressPct;
  final DateTime? startedAt, completedAt, lastAccessedAt;

  const ProgOverall({
    required this.id,
    required this.status,
    required this.totalXp,
    required this.totalTimeMinutes,
    required this.overallProgressPct,
    this.startedAt,
    this.completedAt,
    this.lastAccessedAt,
  });

  factory ProgOverall.fromJson(Map<String, dynamic> j) => ProgOverall(
        id:                  j['id']?.toString() ?? '',
        status:              j['status']?.toString() ?? 'locked',
        totalXp:             (j['totalXp'] as num?)?.toInt() ?? 0,
        totalTimeMinutes:    (j['totalTimeMinutes'] as num?)?.toInt() ?? 0,
        overallProgressPct:  j['overallProgress']?.toString() ?? '0',
        startedAt:     _dt(j['startedAt']),
        completedAt:   _dt(j['completedAt']),
        lastAccessedAt: _dt(j['lastAccessedAt']),
      );

  int get progressPercent =>
      int.tryParse(overallProgressPct) ?? 0;
}

// ── Level ─────────────────────────────────────────────────────────────────────

class ProgLevel {
  final String id, code, name, description;
  final int index;
  final ProgLevelProgress? userProgress;
  final List<ProgModule> modules;

  const ProgLevel({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.index,
    this.userProgress,
    required this.modules,
  });

  factory ProgLevel.fromJson(Map<String, dynamic> j) => ProgLevel(
        id:          j['id']?.toString() ?? '',
        code:        j['code']?.toString() ?? '',
        name:        j['name']?.toString() ?? '',
        description: j['description']?.toString() ?? '',
        index:       (j['index'] as num?)?.toInt() ?? 0,
        userProgress: j['userProgress'] != null
            ? ProgLevelProgress.fromJson(j['userProgress'])
            : null,
        modules: (j['modules'] as List? ?? [])
            .map((m) => ProgModule.fromJson(m as Map<String, dynamic>))
            .toList(),
      );

  int get completedModuleCount =>
      modules.where((m) => m.isCompleted).length;

  int get inProgressModuleCount =>
      modules.where((m) => m.isInProgress).length;

  int get lockedModuleCount =>
      modules.where((m) => m.isLocked).length;

  int get totalXp => userProgress?.totalXp ?? 0;
  int get progressPercent =>
      int.tryParse(userProgress?.progressPercentage ?? '0') ?? 0;
}

class ProgLevelProgress {
  final String id, userId, levelId, status, progressPercentage;
  final int totalXp, timeSpentMinutes;
  final DateTime? unlockedAt, startedAt, completedAt, lastAccessedAt;

  const ProgLevelProgress({
    required this.id,
    required this.userId,
    required this.levelId,
    required this.status,
    required this.progressPercentage,
    required this.totalXp,
    required this.timeSpentMinutes,
    this.unlockedAt,
    this.startedAt,
    this.completedAt,
    this.lastAccessedAt,
  });

  factory ProgLevelProgress.fromJson(Map<String, dynamic> j) =>
      ProgLevelProgress(
        id:                 j['id']?.toString() ?? '',
        userId:             j['userId']?.toString() ?? '',
        levelId:            j['levelId']?.toString() ?? '',
        status:             j['status']?.toString() ?? 'locked',
        progressPercentage: j['progressPercentage']?.toString() ?? '0',
        totalXp:            (j['totalXp'] as num?)?.toInt() ?? 0,
        timeSpentMinutes:   (j['timeSpentMinutes'] as num?)?.toInt() ?? 0,
        unlockedAt:    _dt(j['unlockedAt']),
        startedAt:     _dt(j['startedAt']),
        completedAt:   _dt(j['completedAt']),
        lastAccessedAt: _dt(j['lastAccessedAt']),
      );
}

// ── Module ────────────────────────────────────────────────────────────────────

class ProgModule {
  final String id, levelId, title, description, iconUrl;
  final int index;
  final bool isActive;
  final String? thumbnailUrl;
  final ProgModuleProgress? userProgress;
  final List<ProgPath> paths;

  const ProgModule({
    required this.id,
    required this.levelId,
    required this.title,
    required this.description,
    required this.iconUrl,
    required this.index,
    required this.isActive,
    this.thumbnailUrl,
    this.userProgress,
    required this.paths,
  });

  factory ProgModule.fromJson(Map<String, dynamic> j) => ProgModule(
        id:          j['id']?.toString() ?? '',
        levelId:     j['levelId']?.toString() ?? '',
        title:       j['title']?.toString() ?? '',
        description: j['description']?.toString() ?? '',
        iconUrl:     j['iconUrl']?.toString() ?? '',
        index:       (j['index'] as num?)?.toInt() ?? 0,
        isActive:    j['isActive'] as bool? ?? false,
        thumbnailUrl: j['thumbnailUrl']?.toString(),
        userProgress: j['userProgress'] != null
            ? ProgModuleProgress.fromJson(j['userProgress'])
            : null,
        paths: (j['paths'] as List? ?? [])
            .map((p) => ProgPath.fromJson(p as Map<String, dynamic>))
            .toList(),
      );

  String get status => userProgress?.status ?? 'locked';
  bool get isCompleted  => status == 'completed';
  bool get isInProgress => status == 'started' || status == 'unlocked';
  bool get isLocked     => !isCompleted && !isInProgress;

  int get progressPercent =>
      int.tryParse(userProgress?.progressPercentage ?? '0') ?? 0;
  int get totalXp => userProgress?.totalXp ?? 0;

  int get totalSteps => paths.fold(0, (s, p) => s + p.steps.length);
  int get completedSteps =>
      paths.fold(0, (s, p) => s + p.completedStepCount);
}

class ProgModuleProgress {
  final String id, userId, moduleId, status, progressPercentage;
  final int totalXp, timeSpentMinutes;
  final DateTime? unlockedAt, startedAt, completedAt, lastAccessedAt;

  const ProgModuleProgress({
    required this.id,
    required this.userId,
    required this.moduleId,
    required this.status,
    required this.progressPercentage,
    required this.totalXp,
    required this.timeSpentMinutes,
    this.unlockedAt,
    this.startedAt,
    this.completedAt,
    this.lastAccessedAt,
  });

  factory ProgModuleProgress.fromJson(Map<String, dynamic> j) =>
      ProgModuleProgress(
        id:                 j['id']?.toString() ?? '',
        userId:             j['userId']?.toString() ?? '',
        moduleId:           j['moduleId']?.toString() ?? '',
        status:             j['status']?.toString() ?? 'locked',
        progressPercentage: j['progressPercentage']?.toString() ?? '0',
        totalXp:            (j['totalXp'] as num?)?.toInt() ?? 0,
        timeSpentMinutes:   (j['timeSpentMinutes'] as num?)?.toInt() ?? 0,
        unlockedAt:    _dt(j['unlockedAt']),
        startedAt:     _dt(j['startedAt']),
        completedAt:   _dt(j['completedAt']),
        lastAccessedAt: _dt(j['lastAccessedAt']),
      );
}

// ── Path ──────────────────────────────────────────────────────────────────────

class ProgPath {
  final String id, moduleId, title, description;
  final int index, estimatedHours;
  final int? estimatedMinutes;
  final String? thumbnailUrl, difficulty;
  final bool isActive;
  final ProgPathProgress? userProgress;
  final List<ProgStep> steps;

  const ProgPath({
    required this.id,
    required this.moduleId,
    required this.title,
    required this.description,
    required this.index,
    required this.estimatedHours,
    this.estimatedMinutes,
    this.thumbnailUrl,
    this.difficulty,
    required this.isActive,
    this.userProgress,
    required this.steps,
  });

  factory ProgPath.fromJson(Map<String, dynamic> j) => ProgPath(
        id:               j['id']?.toString() ?? '',
        moduleId:         j['moduleId']?.toString() ?? '',
        title:            j['title']?.toString() ?? '',
        description:      j['description']?.toString() ?? '',
        index:            (j['index'] as num?)?.toInt() ?? 0,
        estimatedHours:   (j['estimatedHours'] as num?)?.toInt() ?? 0,
        estimatedMinutes: (j['estimatedMinutes'] as num?)?.toInt(),
        thumbnailUrl:     j['thumbnailUrl']?.toString(),
        difficulty:       j['difficulty']?.toString(),
        isActive:         j['isActive'] as bool? ?? false,
        userProgress: j['userProgress'] != null
            ? ProgPathProgress.fromJson(j['userProgress'])
            : null,
        steps: (j['steps'] as List? ?? [])
            .map((s) => ProgStep.fromJson(s as Map<String, dynamic>))
            .toList(),
      );

  String get status => userProgress?.status ?? 'locked';
  bool get isCompleted  => status == 'completed';
  bool get isInProgress => status == 'started' || status == 'unlocked';

  int get completedStepCount =>
      steps.where((s) => s.isCompleted).length;
}

class ProgPathProgress {
  final String id, userId, pathId, status, progressPercentage;
  final int currentStepIndex, totalXp, timeSpentMinutes;
  final double? quizScore;
  final DateTime? unlockedAt, startedAt, completedAt, lastAccessedAt;

  const ProgPathProgress({
    required this.id,
    required this.userId,
    required this.pathId,
    required this.status,
    required this.progressPercentage,
    required this.currentStepIndex,
    required this.totalXp,
    required this.timeSpentMinutes,
    this.quizScore,
    this.unlockedAt,
    this.startedAt,
    this.completedAt,
    this.lastAccessedAt,
  });

  factory ProgPathProgress.fromJson(Map<String, dynamic> j) =>
      ProgPathProgress(
        id:                 j['id']?.toString() ?? '',
        userId:             j['userId']?.toString() ?? '',
        pathId:             j['pathId']?.toString() ?? '',
        status:             j['status']?.toString() ?? 'locked',
        progressPercentage: j['progressPercentage']?.toString() ?? '0',
        currentStepIndex:   (j['currentStepIndex'] as num?)?.toInt() ?? 0,
        totalXp:            (j['totalXp'] as num?)?.toInt() ?? 0,
        timeSpentMinutes:   (j['timeSpentMinutes'] as num?)?.toInt() ?? 0,
        quizScore:          (j['quizScore'] as num?)?.toDouble(),
        unlockedAt:    _dt(j['unlockedAt']),
        startedAt:     _dt(j['startedAt']),
        completedAt:   _dt(j['completedAt']),
        lastAccessedAt: _dt(j['lastAccessedAt']),
      );
}

// ── Step ──────────────────────────────────────────────────────────────────────

class ProgStep {
  final String id, pathId, title, description, stepType;
  final int index, estimatedMinutes;
  final bool isActive;
  final ProgStepProgress? userProgress;

  const ProgStep({
    required this.id,
    required this.pathId,
    required this.title,
    required this.description,
    required this.stepType,
    required this.index,
    required this.estimatedMinutes,
    required this.isActive,
    this.userProgress,
  });

  factory ProgStep.fromJson(Map<String, dynamic> j) => ProgStep(
        id:               j['id']?.toString() ?? '',
        pathId:           j['pathId']?.toString() ?? '',
        title:            j['title']?.toString() ?? '',
        description:      j['description']?.toString() ?? '',
        stepType:         j['stepType']?.toString() ?? 'lesson',
        index:            (j['index'] as num?)?.toInt() ?? 0,
        estimatedMinutes: (j['estimatedMinutes'] as num?)?.toInt() ?? 0,
        isActive:         j['isActive'] as bool? ?? false,
        userProgress: j['userProgress'] != null
            ? ProgStepProgress.fromJson(j['userProgress'])
            : null,
      );

  String get status => userProgress?.status ?? 'locked';
  bool get isCompleted  => status == 'completed';
  bool get isInProgress => status == 'started' || status == 'unlocked';
  bool get isLocked     => !isCompleted && !isInProgress;
}

class ProgStepProgress {
  final String id, userId, stepId, status, progressPercentage;
  final double? score;
  final int timeSpentMinutes, totalXp;
  final DateTime? startedAt, completedAt, unlockedAt, lastAccessedAt;

  const ProgStepProgress({
    required this.id,
    required this.userId,
    required this.stepId,
    required this.status,
    required this.progressPercentage,
    this.score,
    required this.timeSpentMinutes,
    required this.totalXp,
    this.startedAt,
    this.completedAt,
    this.unlockedAt,
    this.lastAccessedAt,
  });

  factory ProgStepProgress.fromJson(Map<String, dynamic> j) =>
      ProgStepProgress(
        id:                 j['id']?.toString() ?? '',
        userId:             j['userId']?.toString() ?? '',
        stepId:             j['stepId']?.toString() ?? '',
        status:             j['status']?.toString() ?? 'locked',
        progressPercentage: j['progressPercentage']?.toString() ?? '0',
        score:              (j['score'] as num?)?.toDouble(),
        timeSpentMinutes:   (j['timeSpentMinutes'] as num?)?.toInt() ?? 0,
        totalXp:            (j['totalXp'] as num?)?.toInt() ?? 0,
        startedAt:     _dt(j['startedAt']),
        completedAt:   _dt(j['completedAt']),
        unlockedAt:    _dt(j['unlockedAt']),
        lastAccessedAt: _dt(j['lastAccessedAt']),
      );
}

// ── Helper ────────────────────────────────────────────────────────────────────

DateTime? _dt(dynamic v) {
  if (v == null) return null;
  return DateTime.tryParse(v.toString());
}
