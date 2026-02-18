
class QuestionModel {
  final String id;
  final String question;
  final List<String> answers;
  final int correctIndex;

  QuestionModel({
    required this.id,
    required this.question,
    required this.answers,
    required this.correctIndex,
  });

  /// Vérifie si la réponse sélectionnée est correcte
  bool isCorrect(int selectedIndex) {
    return selectedIndex == correctIndex;
  }

  /// Création depuis JSON (utile pour API)
  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] ?? '',
      question: json['question'] ?? '',
      answers: List<String>.from(json['answers'] ?? []),
      correctIndex: json['correctIndex'] ?? 0,
    );
  }

  /// Conversion vers JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'answers': answers,
      'correctIndex': correctIndex,
    };
  }
}
