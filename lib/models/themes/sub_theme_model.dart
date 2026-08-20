class SubThemeModel {
  final String id;
  final String themeId;
  final String title;
  final String description;
  final int index;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SubThemeModel({
    required this.id,
    required this.themeId,
    required this.title,
    required this.description,
    required this.index,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory SubThemeModel.fromJson(Map<String, dynamic> json) {
    return SubThemeModel(
      id: json['id']?.toString() ?? '',
      themeId: json['themeId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
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
