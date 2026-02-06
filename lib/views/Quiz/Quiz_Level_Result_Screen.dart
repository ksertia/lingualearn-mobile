
import 'package:flutter/material.dart';

class QuizLevelResultScreen extends StatelessWidget {
  final bool levelValidated;
  final int score;

  const QuizLevelResultScreen({
    super.key,
    required this.levelValidated,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Résultat du niveau")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              levelValidated ? Icons.emoji_events : Icons.lock_outline,
              size: 110,
              color: levelValidated ? Colors.amber : Colors.redAccent,
            ),
            const SizedBox(height: 20),
            Text(
              levelValidated ? "Niveau validé 🎉" : "Niveau non validé",
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              "Score : $score%",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Continuer ou reprendre
              },
              child: Text(
                levelValidated
                    ? "Passer au niveau suivant"
                    : "Reprendre le niveau",
              ),
            ),
            if (!levelValidated)
              TextButton(
                onPressed: () {
                  // Revoir les leçons
                },
                child: const Text("Revoir les leçons"),
              ),
          ],
        ),
      ),
    );
  }
}
