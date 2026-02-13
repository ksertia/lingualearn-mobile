
import 'dart:convert';

enum ExerciseType {
  multipleChoice,
  trueFalse,
  fillBlank,
  matching,
  listening,
  writing,
}

ExerciseType exerciseTypeFromString(String type) {
  switch (type) {
    case 'multiple_choice':
      return ExerciseType.multipleChoice;
    case 'true_false':
      return ExerciseType.trueFalse;
    case 'fill_blank':
      return ExerciseType.fillBlank;
    case 'matching':
      return ExerciseType.matching;
    case 'listening':
      return ExerciseType.listening;
    case 'writing':
      return ExerciseType.writing;
    default:
      return ExerciseType.multipleChoice;
  }
}

String exerciseTypeToString(ExerciseType type) {
  switch (type) {
    case ExerciseType.multipleChoice:
      return 'multiple_choice';
    case ExerciseType.trueFalse:
      return 'true_false';
    case ExerciseType.fillBlank:
      return 'fill_blank';
    case ExerciseType.matching:
      return 'matching';
    case ExerciseType.listening:
      return 'listening';
    case ExerciseType.writing:
      return 'writing';
  }
}

class ExerciseModel {
  final String lessonId;
  final String title;
  final ExerciseType exerciseType;
  final String instructions;

  final Map<String, dynamic> content;
  final Map<String, dynamic> correctAnswers;
  final Map<String, dynamic>? hints;

  final String explanation;

  final int points;
  final int xpReward;
  final int coinReward;

  final int maxAttempts;
  final int timeLimitSeconds;
  final int sortOrder;

  final bool isActive;

  ExerciseModel({
    required this.lessonId,
    required this.title,
    required this.exerciseType,
    required this.instructions,
    required this.content,
    required this.correctAnswers,
    this.hints,
    required this.explanation,
    required this.points,
    required this.xpReward,
    required this.coinReward,
    required this.maxAttempts,
    required this.timeLimitSeconds,
    required this.sortOrder,
    required this.isActive,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      lessonId: json['lessonId'],
      title: json['title'],
      exerciseType: exerciseTypeFromString(json['exerciseType']),
      instructions: json['instructions'],
      content: Map<String, dynamic>.from(json['content'] ?? {}),
      correctAnswers: Map<String, dynamic>.from(json['correctAnswers'] ?? {}),
      hints: json['hints'] != null
          ? Map<String, dynamic>.from(json['hints'])
          : null,
      explanation: json['explanation'] ?? '',
      points: json['points'] ?? 0,
      xpReward: json['xpReward'] ?? 0,
      coinReward: json['coinReward'] ?? 0,
      maxAttempts: json['maxAttempts'] ?? 0,
      timeLimitSeconds: json['timeLimitSeconds'] ?? 0,
      sortOrder: json['sortOrder'] ?? 0,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lessonId': lessonId,
      'title': title,
      'exerciseType': exerciseTypeToString(exerciseType),
      'instructions': instructions,
      'content': content,
      'correctAnswers': correctAnswers,
      'hints': hints,
      'explanation': explanation,
      'points': points,
      'xpReward': xpReward,
      'coinReward': coinReward,
      'maxAttempts': maxAttempts,
      'timeLimitSeconds': timeLimitSeconds,
      'sortOrder': sortOrder,
      'isActive': isActive,
    };
  }

  String toRawJson() => jsonEncode(toJson());
}