class QuestionModel {
  final String id;
  final String questionText;
  final List<String> options;
  final int correctIndex;
  final String? explanation;

  QuestionModel({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctIndex,
    this.explanation,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] ?? '',
      questionText: json['questionText'] ?? '',
      options: (json['options'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
      correctIndex: json['correctIndex'] ?? 0,
      explanation: json['explanation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'questionText': questionText,
      'options': options,
      'correctIndex': correctIndex,
      'explanation': explanation,
    };
  }
}