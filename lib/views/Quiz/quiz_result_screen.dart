import 'package:flutter/material.dart';
import 'quiz_success_screen.dart';
import 'quiz_failed_screen.dart';

class QuizResultScreen extends StatelessWidget {
  final int correctAnswers;
  final int total;
  final int totalXP; // ← nouveau paramètre

  const QuizResultScreen({
    super.key,
    required this.correctAnswers,
    required this.total,
    required this.totalXP, // ← obligatoire dans le constructeur
  });

  @override
  Widget build(BuildContext context) {
    final int score = ((correctAnswers / total) * 100).round();
    final bool isPassed = score >= 70;

    return Scaffold(
      appBar: AppBar(title: const Text("Résultats du quiz")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// SCORE
            Text(
              "$score%",
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            /// MESSAGE
            Text(
              isPassed ? "Étape validée 🎉" : "Score insuffisant 😕",
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 20),

            /// TOTAL XP
            Text(
              "XP gagné : $totalXP",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),

            const SizedBox(height: 20),

            /// ACTION
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => isPassed
                        ? const QuizSuccessScreen()
                        : const QuizFailedScreen(),
                  ),
                );
              },
              child: Text(isPassed ? "Continuer" : "Recommencer"),
            ),
          ],
        ),
      ),
    );
  }
}
