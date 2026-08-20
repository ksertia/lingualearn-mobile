class ThemeModel {
  final String id;
  final String moduleId;
  final String title;
  final String description;
  final String? iconUrl;
  final int index;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ThemeModel({
    required this.id,
    required this.moduleId,
    required this.title,
    required this.description,
    this.iconUrl,
    required this.index,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory ThemeModel.fromJson(Map<String, dynamic> json) {
    return ThemeModel(
      id: json['id']?.toString() ?? '',
      moduleId: json['moduleId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      iconUrl: json['iconUrl']?.toString(),
      index: _toInt(json['index']),
      isActive: json['isActive'] == true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
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
