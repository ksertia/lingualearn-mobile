class LanguageDiscover {
  final String id;
  final String code;
  final String name;
  final String? description;
  final String? iconUrl;
  final bool isActive;
  final int index;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<LanguageLevel> levels;

  LanguageDiscover({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    this.iconUrl,
    required this.isActive,
    required this.index,
    required this.createdAt,
    required this.updatedAt,
    required this.levels,
  });

  factory LanguageDiscover.fromJson(Map<String, dynamic> json) {
    return LanguageDiscover(
      // On utilise .toString() et ?? "" pour éviter les crashs si le champ est null
      id: json['id']?.toString() ?? "",
      code: json['code']?.toString() ?? "",
      name: json['name']?.toString() ?? "Sans nom",
      description: json['description']?.toString(),
      iconUrl: json['iconUrl']?.toString(),
      isActive: json['isActive'] ?? false,
      // On s'assure que index est bien un int
      index: json['index'] is int ? json['index'] : (int.tryParse(json['index']?.toString() ?? "0") ?? 0),
      // On vérifie que la date existe avant de parser
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
      // On ajoute un check sur la liste des niveaux
      levels: (json['levels'] as List? ?? [])
          .map((l) => LanguageLevel.fromJson(l))
          .toList(),
    );
  }
}

class LanguageLevel {
  final String id;
  final String languageId;
  final String code;
  final String name;
  final String? description;
  final int index;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  LanguageLevel({
    required this.id,
    required this.languageId,
    required this.code,
    required this.name,
    this.description,
    required this.index,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LanguageLevel.fromJson(Map<String, dynamic> json) {
    return LanguageLevel(
      id: json['id']?.toString() ?? "",
      languageId: json['languageId']?.toString() ?? "",
      code: json['code']?.toString() ?? "",
      name: json['name']?.toString() ?? "Niveau",
      description: json['description']?.toString(),
      index: json['index'] is int ? json['index'] : (int.tryParse(json['index']?.toString() ?? "0") ?? 0),
      isActive: json['isActive'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
    );
  }
}