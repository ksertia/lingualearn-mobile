/*
import 'package:fasolingo/views/ui/dialogs/quiz_failed_dialog.dart';
import 'package:fasolingo/views/ui/dialogs/quiz_success_dialog.dart';
import 'package:flutter/material.dart';


class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentQuestion = 0;
  int score = 0;

  final List<Map<String, dynamic>> questions = [
    {
      "question": "Quelle est la capitale de la France ?",
      "answers": ["Paris", "Lyon", "Marseille"],
      "correct": 0,
    },
    {
      "question": "2 + 2 = ?",
      "answers": ["3", "4", "5"],
      "correct": 1,
    },
  ];

  void answerQuestion(int index) {
    final int correctAnswer =
    questions[currentQuestion]["correct"] as int;

    if (index == correctAnswer) {
      score++;
    }

    if (currentQuestion < questions.length - 1) {
      setState(() => currentQuestion++);
    } else {
      final bool success = score >= (questions.length / 2);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) =>
        success ? const QuizSuccessDialog() : const QuizFailedDialog(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> question = questions[currentQuestion];
    final List<String> answers =
    List<String>.from(question["answers"]);

    return Scaffold(
      appBar: AppBar(title: const Text("Quiz")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Question ${currentQuestion + 1}/${questions.length}",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Text(
              question["question"] as String,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            ...answers.asMap().entries.map(
                  (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ElevatedButton(
                  onPressed: () => answerQuestion(entry.key),
                  child: Text(entry.value),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/
