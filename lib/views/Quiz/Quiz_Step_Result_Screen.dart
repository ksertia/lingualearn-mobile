
import 'package:flutter/material.dart';

class QuizStepResultScreen extends StatelessWidget {
  final int score;
  final int total;
  final bool isSuccess;

  const QuizStepResultScreen({
    super.key,
    required this.score,
    required this.total,
    required this.isSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Résultat de l’étape")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              size: 100,
              color: isSuccess ? Colors.green : Colors.orange,
            ),
            const SizedBox(height: 16),
            Text(
              "$score / $total",
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              isSuccess
                  ? "Bonne progression 👏"
                  : "Encore un effort 💪",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Aller à l’étape suivante
              },
              child: const Text("Continuer"),
            ),
            if (!isSuccess)
              TextButton(
                onPressed: () {
                  // Recommencer l’étape
                },
                child: const Text("Recommencer l’étape"),
              ),
          ],
        ),
      ),
    );
  }
}
