class LearningPathModel {
  final String id;
  final String moduleId;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String difficulty;
  final bool isActive;

  LearningPathModel({
    required this.id,
    required this.moduleId,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.difficulty,
    required this.isActive,
  });

  factory LearningPathModel.fromJson(Map<String, dynamic> json) {
    return LearningPathModel(
      id: json['id'] ?? '',
      moduleId: json['moduleId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      difficulty: json['difficulty'] ?? '',
      isActive: json['isActive'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'moduleId': moduleId,
      'title': title,
      'description': description,
      'thumbnailUrl': thumbnailUrl,
      'difficulty': difficulty,
      'isActive': isActive,
    };
  }
}
