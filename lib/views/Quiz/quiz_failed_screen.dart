
import 'package:flutter/material.dart';

class QuizFailedScreen extends StatelessWidget {
  const QuizFailedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.sentiment_dissatisfied, size: 80, color: Colors.red),
            const SizedBox(height: 16),
            const Text("Tu peux faire mieux", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text("Score insuffisant"),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: () {}, child: const Text("Recommencer le quizz")),
            TextButton(onPressed: () {}, child: const Text("Revoir la leçon")),
          ],
        ),
      ),
    );
  }
}
