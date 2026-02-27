import 'package:fasolingo/models/quiz/question_model.dart';
import 'package:flutter/material.dart';
import 'package:fasolingo/views/ui/dialogs/quiz_correct_dialog.dart';
import 'package:fasolingo/views/ui/dialogs/quiz_wrong_dialog.dart';
import 'package:fasolingo/views/Quiz/quiz_result_screen.dart';

class QuizQuestionScreen extends StatefulWidget {
  const QuizQuestionScreen({super.key});

  @override
  State<QuizQuestionScreen> createState() => _QuizQuestionScreenState();
}

class _QuizQuestionScreenState extends State<QuizQuestionScreen> {
  final List<QuestionModel> questions = [
    QuestionModel(
      id: "q1",
      question: "Quelle est la bonne traduction de 'Bonjour' en Mooré?",
      answers: ["Zaabré", "ne y windga", "Yiisi", "ne y beoogo"],
      correctIndex: 3,
    ),
    QuestionModel(
      id: "q2",
      question: "Quelle est la traduction de 'Enfant' en Mooré?",
      answers: ["Rakoore", "Pugdenga", "Biiga", "Paaga"],
      correctIndex: 2,
    ),
    QuestionModel(
      id: "q3",
      question: "Quelle est la traduction de 'Maison' en Mooré ?",
      answers: ["Zaka", "Roogo", "Samande", "Rapoore"],
      correctIndex: 1,
    ),
  ];

  int currentIndex = 0;
  int score = 0;
  int totalXP = 0;
  int? selectedIndex;
  bool isLoading = false;

  Future<void> _validateAnswer() async {
    if (selectedIndex == null || isLoading) return;

    setState(() => isLoading = true);

    final question = questions[currentIndex];
    final bool isCorrect = selectedIndex == question.correctIndex;

    const int correctXP = 10;
    const int wrongXP = 0;

    if (isCorrect) {
      score++;
      totalXP += correctXP;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const QuizCorrectDialog(xpReward: correctXP),
      );
    } else {
      totalXP += wrongXP;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => QuizWrongDialog(
          correction:
          "La bonne réponse est : ${question.answers[question.correctIndex]}",
          xpReward: wrongXP,
        ),
      );
    }

    if (!mounted) return;

    // ✅ Navigation finale ou question suivante
    if (currentIndex == questions.length - 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => QuizResultScreen(
            correctAnswers: score,
            total: questions.length,
            totalXP: totalXP,
          ),
        ),
      );
    } else {
      setState(() {
        currentIndex++;
        selectedIndex = null;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = questions[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text("Question ${currentIndex + 1} / ${questions.length}"),
        backgroundColor: const Color(0xFF1E61D5),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value: (currentIndex + 1) / questions.length,
              backgroundColor: const Color(0xFFE0E0E0),
              color: Colors.orange,
              minHeight: 8,
            ),
            const SizedBox(height: 30),

            Text(
              question.question,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 20),

            ...List.generate(
              question.answers.length,
                  (index) => _buildOption(
                index,
                question.answers[index],
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                selectedIndex != null && !isLoading
                    ? _validateAnswer
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding:
                  const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  "Valider",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(int index, String text) {
    final bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: isLoading
          ? null
          : () => setState(() => selectedIndex = index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF1E61D5)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF1E61D5)
                : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color:
              isSelected ? Colors.white : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
