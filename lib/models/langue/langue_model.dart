// 1. On crée d'abord le modèle pour les niveaux
class LevelModel {
  final String id;
  final String name;
  final String code;
  final String description;

  LevelModel({
    required this.id,
    required this.name,
    required this.code,
    required this.description,
  });

  factory LevelModel.fromJson(Map<String, dynamic> json) {
    return LevelModel(
      id: json['id'] ?? "",
      name: json['name'] ?? "",
      code: json['code'] ?? "",
      description: json['description'] ?? "",
    );
  }
}

// 2. On met à jour le modèle de Langue
class LanguageModel {
  final String id; 
  final String code;
  final String name;
  final String description;
  final String? iconUrl;
  final bool isActive;
  final List<LevelModel> levels; 

  LanguageModel({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    this.iconUrl,
    this.isActive = true,
    required this.levels, 
  });

  factory LanguageModel.fromJson(Map<String, dynamic> json) {
    return LanguageModel(
      id: json['id'] ?? "",
      code: json['code'] ?? "",
      name: json['name'] ?? "",
      description: json['description'] ?? "",
      iconUrl: json['iconUrl'],
      isActive: json['isActive'] ?? true,
      levels: (json['levels'] as List? ?? [])
          .map((item) => LevelModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}