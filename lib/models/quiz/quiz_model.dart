
import 'dart:convert';

import 'package:fasolingo/models/quiz/question_model.dart';

class QuizModel {
  final String stepId;
  final String title;
  final String description;
  final List<QuestionModel> questions;

  final int passingScore;
  final int maxAttempts;
  final int timeLimitMinutes;
  final int xpReward;
  final int coinReward;

  final bool isActive;

  QuizModel({
    required this.stepId,
    required this.title,
    required this.description,
    required this.questions,
    required this.passingScore,
    required this.maxAttempts,
    required this.timeLimitMinutes,
    required this.xpReward,
    required this.coinReward,
    required this.isActive,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      stepId: json['stepId'],
      title: json['title'],
      description: json['description'] ?? '',
      questions: (json['questions'] as List<dynamic>?)
          ?.map((q) => QuestionModel.fromJson(q))
          .toList() ??
          [],
      passingScore: json['passingScore'] ?? 0,
      maxAttempts: json['maxAttempts'] ?? 0,
      timeLimitMinutes: json['timeLimitMinutes'] ?? 0,
      xpReward: json['xpReward'] ?? 0,
      coinReward: json['coinReward'] ?? 0,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stepId': stepId,
      'title': title,
      'description': description,
      'questions': questions.map((q) => q.toJson()).toList(),
      'passingScore': passingScore,
      'maxAttempts': maxAttempts,
      'timeLimitMinutes': timeLimitMinutes,
      'xpReward': xpReward,
      'coinReward': coinReward,
      'isActive': isActive,
    };
  }

  String toRawJson() => jsonEncode(toJson());
}