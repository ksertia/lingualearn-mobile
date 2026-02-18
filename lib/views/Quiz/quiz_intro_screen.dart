import 'package:flutter/material.dart';
import 'quiz_question_screen.dart';

class QuizIntroScreen extends StatelessWidget {
  const QuizIntroScreen({super.key});

  // Ta palette officielle
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
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.2),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent, // AppBar plus moderne
        foregroundColor: bleuFonce,
        centerTitle: true,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ===== ILLUSTRATION CENTRALE =====
              Center(
                child: Image.asset(
                  'assets/images/quiz_hero.png', // Image stylisée (ex: un perso qui réfléchit)
                  height: 200,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.psychology, size: 120, color: orangeVif),
                ),
              ),
              const SizedBox(height: 30),

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
                "Vérifie tes connaissances sur ce module avant de passer à la suite !",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.grey, height: 1.5),
              ),
              const SizedBox(height: 40),

              // ===== CARTES INFOS HARMONISÉES =====
              Row(
                children: [
                  _buildInfoCard(
                    "5 Questions",
                    'assets/images/quiz/clipboard.png', // Remplace par ton image
                    const Color(0xFFE8F0FE),
                  ),
                  const SizedBox(width: 12),
                  _buildInfoCard(
                    "2 minutes",
                    'assets/images/quiz/super-intelligence.png', // Remplace par ton image
                    const Color(0xFFFFF4E5),
                  ),
                  const SizedBox(width: 12),
                  _buildInfoCard(
                    "Objectif 70%",
                    'assets/images/quiz/light-bulb.png', // Remplace par ton image
                    const Color(0xFFE0F7F8),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      // ================= BOUTONS FIXÉS EN BAS =================
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: blancPure,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPrimaryButton(
                context,
                "C'EST PARTI !",
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuizQuestionScreen())),
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

  // ================= INFO CARD (Version Image) =================
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
              border: Border.all(color: Colors.black.withOpacity(0.03)),
            ),
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Icon(Icons.bolt, color: bleuFonce),
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

  // ================= BOUTON PRINCIPAL (Bleu Foncé) =================
  Widget _buildPrimaryButton(BuildContext context, String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bleuFonce,
          foregroundColor: blancPure,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 0,
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.1),
        ),
      ),
    );
  }

  // ================= BOUTON SECONDAIRE (Orange) =================
  Widget _buildSecondaryButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: orangeVif, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        child: Text(
          label.toUpperCase(),
          style: const TextStyle(fontSize: 15, color: orangeVif, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}