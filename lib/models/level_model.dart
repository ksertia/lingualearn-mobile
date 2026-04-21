class LevelModel {
  final String id;
  final String? languageId;
  final String? code;
  final String? name;
  final String? description;
  final int? index;
  final bool? isActive;

  const LevelModel({
    required this.id,
    this.languageId,
    this.code,
    this.name,
    this.description,
    this.index,
    this.isActive,
  });

  factory LevelModel.fromJson(Map<String, dynamic> json) {
    return LevelModel(
      id: (json['id'] ?? '').toString(),
      languageId: json['languageId']?.toString(),
      code: json['code']?.toString(),
      name: json['name']?.toString(),
      description: json['description']?.toString(),
      index: json['index'] is int ? json['index'] as int : int.tryParse('${json['index']}'),
      isActive: json['isActive'] as bool?,
    );
  }
}
