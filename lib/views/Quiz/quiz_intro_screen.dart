import 'package:flutter/material.dart';
import 'package:fasolingo/models/quiz/quiz_model.dart';
import 'quiz_question_screen.dart';

class QuizIntroScreen extends StatelessWidget {
  final QuizModel quiz;

  const QuizIntroScreen({
    super.key,
    required this.quiz,
  });

  static const Color bleuFonce = Color(0xFF000099);
  static const Color orangeVif = Color(0xFFFF7F00);
  static const Color grisTresClair = Color(0xFFC0C0C0);
  static const Color blancPure = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: blancPure,
      appBar: AppBar(
        title: Text(
          quiz.title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        backgroundColor: bleuFonce,
        foregroundColor: blancPure,
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding:
        const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
        child: Column(
          children: [
            Text(
              quiz.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              quiz.description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: Colors.grey),
            ),
            const SizedBox(height: 35),

            Row(
              children: [
                _buildInfoCard(
                  "${quiz.questions.length} Questions",
                  Icons.assignment_outlined,
                  const Color(0xFFE8F0FE),
                ),
                const SizedBox(width: 10),
                _buildInfoCard(
                  "Temps estimé\n${quiz.timeLimitMinutes} min",
                  Icons.timer_outlined,
                  const Color(0xFFFFF4E5),
                ),
                const SizedBox(width: 10),
                _buildInfoCard(
                  "Score minimum\n${quiz.passingScore}%",
                  Icons.lightbulb_outline,
                  const Color(0xFFE0F7F8),
                ),
              ],
            ),
            const Spacer(),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPrimaryButton(
                context,
                "Commencer le quiz",
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          QuizQuestionScreen(quiz: quiz),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildSecondaryButton(
                "Revoir la leçon",
                    () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
      String text, IconData icon, Color bgColor) {
    return Expanded(
      child: Column(
        children: [
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, size: 30, color: bleuFonce),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton(
      BuildContext context,
      String label,
      VoidCallback onPressed,
      ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bleuFonce,
          foregroundColor: blancPure,
          padding:
          const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(
      String label,
      VoidCallback onPressed,
      ) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(
              color: grisTresClair, width: 1.2),
          padding:
          const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 17,
            color: Color(0xFF555555),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}