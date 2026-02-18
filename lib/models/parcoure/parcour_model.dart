class LearningPathModel {
  final String id;
  final String moduleId;
  final String title;
  final String description;
  final String? status; 
  final Map<String, dynamic>? progress; 
  final String? progressPercentage;
  final int? currentStepIndex;
  final int? totalXp;
  final int? timeSpentMinutes;
  final dynamic quizScore;
  final int index;
  final int tempResaListime;
  final String? thumbnailUrl;
  final String difficulty;
  final int estimatedHours;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<StepModel> steps;

  LearningPathModel({
    required this.id,
    required this.moduleId,
    required this.title,
    required this.description,
    required this.index,
    required this.tempResaListime,
    this.status,
    this.progress,
    this.progressPercentage,
    this.currentStepIndex,
    this.totalXp,
    this.timeSpentMinutes,
    this.quizScore,
    this.thumbnailUrl,
    required this.difficulty,
    required this.estimatedHours,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
    required this.steps,
  });

  factory LearningPathModel.fromJson(Map<String, dynamic> json) {
    return LearningPathModel(
      id: json['id']?.toString() ?? '',
      moduleId: json['moduleId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
        index: _toInt(json['index']),
      tempResaListime: _toInt(json['tempResaListime']),

      status: json['status']?.toString(),
      progress: json['progress'] != null ? Map<String, dynamic>.from(json['progress']) : null,
      progressPercentage: json['progressPercentage']?.toString(),
      currentStepIndex: _toInt(json['currentStepIndex']),
      totalXp: _toInt(json['totalXp']),
      timeSpentMinutes: _toInt(json['timeSpentMinutes']),
      quizScore: json['quizScore'],
      
      thumbnailUrl: json['thumbnailUrl']?.toString(),
      difficulty: json['difficulty']?.toString() ?? 'easy',
      estimatedHours: _toInt(json['estimatedHours']),
      isActive: json['isActive'] == true,
      
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'].toString()) : null,
      
      steps: (json['steps'] as List?)
              ?.map((step) => StepModel.fromJson(step))
              .toList() ?? [],
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

class StepModel {
  final String id;
  final String title;
  final String description;
  final String stepType;
  final int index;
  final int estimatedMinutes;
  final bool isActive;
  final String? status; // 'locked' | 'unlocked' | 'completed'
  final Map<String, dynamic>? progress;
  final String? progressPercentage;

  StepModel({
    required this.id,
    required this.title,
    required this.description,
    required this.stepType,
    required this.index,
    required this.estimatedMinutes,
    required this.isActive,
    this.status,
    this.progress,
    this.progressPercentage,
  });

  factory StepModel.fromJson(Map<String, dynamic> json) {
    return StepModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      stepType: json['stepType']?.toString() ?? 'lesson',
      index: _toInt(json['index']),
      estimatedMinutes: _toInt(json['estimatedMinutes']),
      isActive: json['isActive'] == true,
      status: json['status']?.toString(),
      progress: json['progress'] != null ? Map<String, dynamic>.from(json['progress']) : null,
      progressPercentage: json['progressPercentage']?.toString(),
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}