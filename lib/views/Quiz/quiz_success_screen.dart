
import 'package:flutter/material.dart';

class QuizSuccessScreen extends StatelessWidget {
  const QuizSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_events, size: 80, color: Colors.amber),
            const SizedBox(height: 16),
            const Text("Félicitations !", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text("Étape validée ! +50 XP"),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: () {}, child: const Text("Passer à l'étape suivante")),
            TextButton(onPressed: () {}, child: const Text("Revoir mes réponses")),
          ],
        ),
      ),
    );
  }
}
