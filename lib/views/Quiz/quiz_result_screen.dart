import 'package:flutter/material.dart';
import 'package:fasolingo/widgets/quiz/circular_score.dart';
import 'package:fasolingo/widgets/quiz/confetti_widget.dart';
import 'package:fasolingo/widgets/quiz/stars_animation.dart';

class QuizResultScreen extends StatelessWidget {
  final int correctAnswers;
  final int total;
  final int totalXP;

  final Color bleuFonce = const Color(0xFF000099);
  final Color orange = const Color(0xFFFF7F00);
  final Color grisClair = const Color(0xFFC0C0C0);
  final Color blanc = const Color(0xFFFFFFFF);

  const QuizResultScreen({
    super.key,
    required this.correctAnswers,
    required this.total,
    required this.totalXP,
  });

  @override
  Widget build(BuildContext context) {
    final double score = correctAnswers / total;
    final bool isPassed = score >= 0.7;
    int stars = score == 1.0 ? 3 : (score >= 0.85 ? 2 : (score >= 0.7 ? 1 : 0));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          if (isPassed) const ConfettiWidget(),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 50),
                Text(
                  isPassed ? "SUCCÈS !" : "ESSAYE ENCORE",
                  style: TextStyle(
                    fontSize: 28,
                    // Changé FontWeight.black par FontWeight.w900 pour éviter l'avertissement
                    fontWeight: FontWeight.w900,
                    color: bleuFonce,
                    letterSpacing: 1.5,
                  ),
                ),
                const Spacer(),
                CircularScore(value: score),
                const SizedBox(height: 30),
                StarsAnimation(stars: stars),
                const SizedBox(height: 40),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: blanc,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: grisClair.withOpacity(0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bolt, color: orange),
                      const SizedBox(width: 8),
                      Text(
                        "+$totalXP XP GAGNÉS",
                        style: TextStyle(
                          color: bleuFonce,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                Padding(
                  padding: const EdgeInsets.all(30),
                  child: SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: bleuFonce,
                        foregroundColor: blanc,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 0,
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("CONTINUER", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}