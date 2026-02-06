
import 'package:flutter/material.dart';
import 'package:fasolingo/widgets/quiz/circular_score.dart';
import 'package:fasolingo/widgets/quiz/confetti_widget.dart';
import 'package:fasolingo/widgets/quiz/stars_animation.dart';

class QuizSuccessDialog extends StatelessWidget {
  final int score;
  final int total;

  const QuizSuccessDialog({
    super.key,
    required this.score,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final double percent = score / total;
    final int stars = percent >= 0.8 ? 3 : percent >= 0.6 ? 2 : 1;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Stack(
        children: [
          const ConfettiWidget(),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularScore(value: percent),
                const SizedBox(height: 12),
                StarsAnimation(stars: stars),
                const SizedBox(height: 12),
                const Text(
                  "Bravo !",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text("Niveau suivant"),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
