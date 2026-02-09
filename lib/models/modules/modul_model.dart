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
  });

  factory ModuleModel.fromJson(Map<String, dynamic> json) {
    return ModuleModel(
      id: json['id'] ?? "",
      levelId: json['levelId'] ?? "",
      title: json['title'] ?? "Sans titre",
      description: json['description'] ?? "",
      iconUrl: (json['iconUrl'] != null && json['iconUrl'].toString().isNotEmpty) 
                ? json['iconUrl'] 
                : null,
      index: json['index'] ?? 0,
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'levelId': levelId,
      'title': title,
      'description': description,
      'iconUrl': iconUrl,
      'index': index,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}