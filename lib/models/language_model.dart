import 'package:fasolingo/models/level_model.dart';

class LanguageModel {
  final String id;
  final String? code;
  final String? name;
  final String? description;
  final String? iconUrl;
  final bool? isActive;
  final int? index;
  final String? flagUrl;
  final List<LevelModel> levels;

  const LanguageModel({
    required this.id,
    this.code,
    this.name,
    this.description,
    this.iconUrl,
    this.isActive,
    this.index,
    this.flagUrl,
    this.levels = const [],
  });

  factory LanguageModel.fromJson(Map<String, dynamic> json) {
    final rawLevels = json['levels'];
    final parsedLevels = <LevelModel>[];

    if (rawLevels is List) {
      for (final e in rawLevels) {
        if (e is Map<String, dynamic>) {
          parsedLevels.add(LevelModel.fromJson(e));
        } else if (e is Map) {
          parsedLevels.add(LevelModel.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }

    return LanguageModel(
      id: (json['id'] ?? '').toString(),
      code: json['code']?.toString(),
      name: json['name']?.toString(),
      description: json['description']?.toString(),
      iconUrl: json['iconUrl']?.toString(),
      flagUrl: json['flagUrl']?.toString(),
      isActive: json['isActive'] as bool?,
      index: json['index'] is int ? json['index'] as int : int.tryParse('${json['index']}'),
      levels: parsedLevels,
    );
  }
}
