
class QuestionModel {
  final String id;
  final String question;
  final List<String> answers;
  final int correctIndex;
  final String? explanation; // optionnel (feedback)

  QuestionModel({
    required this.id,
    required this.question,
    required this.answers,
    required this.correctIndex,
    this.explanation,
  });

  /// Vérifie si la réponse est correcte
  bool isCorrect(int selectedIndex) {
    return selectedIndex == correctIndex;
  }

  /// Factory depuis JSON / API
  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] as String,
      question: json['question'] as String,
      answers: List<String>.from(json['answers']),
      correctIndex: json['correctIndex'] as int,
      explanation: json['explanation'] as String?,
    );
  }

  /// Conversion vers JSON (sauvegarde locale / API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'answers': answers,
      'correctIndex': correctIndex,
      'explanation': explanation,
    };
  }
}
