import 'package:fasolingo/views/Quiz/quizFinalExamenFinal.dart';
import 'package:fasolingo/views/apps/home/screens/parcours.dart';
import 'package:flutter/material.dart';
import 'package:fasolingo/widgets/quiz/confetti_widget.dart';
class QuizResultScreen extends StatelessWidget {
  final int correctAnswers;
  final int total;
  final int totalXP;

  const QuizResultScreen({
    super.key,
    required this.correctAnswers,
    required this.total,
    required this.totalXP,
  });

  static const Color bleuFonce = Color(0xFF000099); 
  static const Color orange = Color(0xFFFF7F00);      
  static const Color blanc = Color(0xFFFFFFFF);      

  @override
  Widget build(BuildContext context) {
    final double percentage = (correctAnswers / total) * 100;
    final bool isSuccess = percentage >= 70;

    return Scaffold(
      backgroundColor: blanc,
      body: Stack(
        children: [
          if (isSuccess) const Positioned.fill(child: ConfettiWidget()),

          SafeArea(
            child: Column(
              children: [
                const Spacer(),

                Text(
                  isSuccess ? "FÉLICITATIONS !" : "CONTINUE TES EFFORTS",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: bleuFonce,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 40),

                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 180,
                        height: 180,
                        child: CircularProgressIndicator(
                          value: correctAnswers / total,
                          strokeWidth: 15,
                          backgroundColor: bleuFonce.withOpacity(0.1),
                          color: isSuccess ? bleuFonce : orange,
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "${percentage.toInt()}%",
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              color: bleuFonce,
                            ),
                          ),
                          Text(
                            "$correctAnswers / $total",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: bleuFonce.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // 4. Badge XP gagnés
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: orange.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.bolt, color: orange, size: 28),
                      const SizedBox(width: 8),
                      Text(
                        "+$totalXP XP GAGNÉS",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: orange,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: bleuFonce,
                        foregroundColor: blanc,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ParcoursSelectionPage(),
                          ),
                        );
                      },
                      child: const Text(
                        "CONTINUER",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
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