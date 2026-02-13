import 'package:flutter/material.dart';
import 'package:fasolingo/models/quiz/quiz_model.dart';
import 'package:fasolingo/views/ui/dialogs/quiz_correct_dialog.dart';
import 'package:fasolingo/views/ui/dialogs/quiz_wrong_dialog.dart';
import 'package:fasolingo/views/Quiz/quiz_result_screen.dart';

class QuizQuestionScreen extends StatefulWidget {
  final QuizModel quiz;

  const QuizQuestionScreen({
    super.key,
    required this.quiz,
  });

  @override
  State<QuizQuestionScreen> createState() => _QuizQuestionScreenState();
}

class _QuizQuestionScreenState extends State<QuizQuestionScreen> {
  int currentIndex = 0;
  int score = 0;
  int totalXP = 0;
  int? selectedIndex;
  bool isLoading = false;

  List get questions => widget.quiz.questions;

  Future<void> _validateAnswer() async {
    if (selectedIndex == null || isLoading) return;

    setState(() => isLoading = true);

    final question = questions[currentIndex];
    final isCorrect = selectedIndex == question.correctIndex;

    if (isCorrect) {
      score++;
      totalXP += 10;
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const QuizCorrectDialog(xpReward: 10),
      );
    } else {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => QuizWrongDialog(
          correction:
          "Bonne réponse : ${question.options[question.correctIndex]}",
          xpReward: 0,
        ),
      );
    }

    if (!mounted) return;

    if (currentIndex == questions.length - 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => QuizResultScreen(
            correctAnswers: score,
            total: questions.length,
            totalXP: widget.quiz.xpReward,
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
        title: Text(widget.quiz.title),
        backgroundColor: const Color(0xFF1E61D5),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value: (currentIndex + 1) / questions.length,
              minHeight: 8,
            ),
            const SizedBox(height: 30),

            Text(
              question.questionText,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),

            ...List.generate(
              question.options.length,
                  (index) => _buildOption(index, question.options[index]),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                selectedIndex != null && !isLoading ? _validateAnswer : null,
                child: const Text("Valider"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(int index, String text) {
    bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => setState(() => selectedIndex = index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E61D5) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
            isSelected ? const Color(0xFF1E61D5) : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: isSelected ? Colors.white : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}