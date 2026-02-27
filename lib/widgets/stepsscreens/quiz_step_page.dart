import 'package:fasolingo/views/Quiz/quiz_question_screen.dart';
import 'package:flutter/material.dart';

class QuizStepPage extends StatelessWidget {
  final dynamic data;
  const QuizStepPage({super.key,this.data});

  static const Color bleuFonce = Color(0xFF000099);
  static const Color cyanTurquoise = Color(0xFF00CED1);
  static const Color orangeVif = Color(0xFFFF7F00);
  static const Color grisTresClair = Color(0xFFC0C0C0);
  static const Color blancPure = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: blancPure,
      appBar: AppBar(
        title: const Text(
          "PRÊT POUR LE TEST ?",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: bleuFonce,
        centerTitle: true,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [

            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24.0, vertical: 20.0),
              child: Column(
                children: [

                  const SizedBox(height: 20),

                  const Text(
                    "Quiz récapitulatif",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: bleuFonce,
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    "Vérifie tes connaissances sur ce parcour avant de passer à la suite !",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 40),

                  Row(
                    children: [
                      _buildInfoCard(
                        "5 Questions",
                        'assets/images/quiz/clipboard.png',
                        const Color(0xFFE8F0FE),
                      ),
                      const SizedBox(width: 12),
                      _buildInfoCard(
                        "2 minutes",
                        'assets/images/quiz/super-intelligence.png',
                        const Color(0xFFFFF4E5),
                      ),
                      const SizedBox(width: 12),
                      _buildInfoCard(
                        "Objectif 70%",
                        'assets/images/quiz/light-bulb.png',
                        const Color(0xFFE0F7F8),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // ===== IMAGE FULL WIDTH ENTRE CARDS ET BOUTONS =====
            ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Image.asset(
                'assets/images/quiz/creative.jpg',
                width: double.infinity,
                height: 190,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 190,
                    width: double.infinity,
                    color: Colors.grey.shade200,
                    child: const Icon(
                      Icons.image_not_supported,
                      size: 80,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),

      // ===== BOUTONS =====
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: blancPure,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPrimaryButton(
                context,
                "C'EST PARTI !",
                    () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const QuizQuestionScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildSecondaryButton(
                "Revoir les étapes",
                    () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== INFO CARD =====
  Widget _buildInfoCard(String text, String imagePath, Color bgColor) {
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 90,
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.bolt, color: bleuFonce),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF444444),
            ),
          ),
        ],
      ),
    );
  }

  // ===== BOUTON PRINCIPAL =====
  Widget _buildPrimaryButton(
      BuildContext context, String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bleuFonce,
          foregroundColor: blancPure,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  // ===== BOUTON SECONDAIRE =====
  Widget _buildSecondaryButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: orangeVif, width: 2),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18)),
        ),
        child: Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 15,
            color: orangeVif,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}