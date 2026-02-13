//  Modèle pour les Niveaux
class LevelModel {
  final String id;
  final String languageId;
  final String name;
  final String code;
  final String description;
  final int index;
  final bool isActive;
  final LanguageModel? language; 

  LevelModel({
    required this.id,
    required this.languageId,
    required this.name,
    required this.code,
    required this.description,
    required this.index,
    required this.isActive,
    this.language,
  });

  factory LevelModel.fromJson(Map<String, dynamic> json) {
    return LevelModel(
      id: json['id']?.toString() ?? "",
      languageId: json['languageId']?.toString() ?? "",
      name: json['name']?.toString() ?? "",
      code: json['code']?.toString() ?? "",
      description: json['description']?.toString() ?? "",
      index: json['index'] is int ? json['index'] : int.tryParse(json['index']?.toString() ?? "0") ?? 0,
      isActive: json['isActive'] ?? true,
      language: (json['language'] != null && json['language'] is Map<String, dynamic>)
          ? LanguageModel.fromJson(json['language'])
          : null,
    );
  }
}

class LanguageModel {
  final String id;
  final String code;
  final String name;
  final String description;
  final String? iconUrl;
  final bool isActive;
  final int index;
  final List<LevelModel> levels;

  LanguageModel({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    this.iconUrl,
    this.isActive = true,
    required this.index,
    required this.levels,
  });

  factory LanguageModel.fromJson(Map<String, dynamic> json) {
    return LanguageModel(
      id: json['id']?.toString() ?? "",
      code: json['code']?.toString() ?? "",
      name: json['name']?.toString() ?? "",
      description: json['description']?.toString() ?? "",
      iconUrl: json['iconUrl'] ?? json['flagUrl'],
      isActive: json['isActive'] ?? true,
      index: json['index'] is int ? json['index'] : int.tryParse(json['index']?.toString() ?? "0") ?? 0,
      levels: (json['levels'] as List? ?? [])
          .map((item) => LevelModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}