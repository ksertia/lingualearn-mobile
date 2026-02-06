import 'package:flutter/material.dart';
import 'quiz_question_screen.dart'; // Assure-toi que le chemin est correct

class QuizIntroScreen extends StatelessWidget {
  const QuizIntroScreen({super.key});

  // Couleurs de la charte graphique (Codes RVB fournis)
  static const Color bleuFonce = Color(0xFF000099);      // (0, 0, 153)
  static const Color cyanTurquoise = Color(0xFF00CED1);  // (0, 206, 209)
  static const Color orangeVif = Color(0xFFFF7F00);      // (255, 127, 0)
  static const Color grisTresClair = Color(0xFFC0C0C0);  // (192, 192, 192)
  static const Color blancPure = Color(0xFFFFFFFF);      // (255, 255, 255)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: blancPure,
      appBar: AppBar(
        title: const Text(
          "Quizz récapitulatif – Étape 3",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: bleuFonce,
        foregroundColor: blancPure,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // TITRE PRINCIPAL
              const Text(
                "Quizz récapitulatif –\nÉtape 3",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Teste ce que tu as appris avant de continuer.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),
              const SizedBox(height: 35),

              // CARTES D'INFOS (L'encadré central avec ombres douces)
              Row(
                children: [
                  _buildInfoCard(
                    "5 Questions",
                    Icons.assignment_outlined,
                    const Color(0xFFE8F0FE), // Bleu très pâle
                  ),
                  const SizedBox(width: 10),
                  _buildInfoCard(
                    "Temps estimé\n2 min",
                    Icons.psychology_outlined,
                    const Color(0xFFFFF4E5), // Orange très pâle
                  ),
                  const SizedBox(width: 10),
                  _buildInfoCard(
                    "Score minimum\n70%",
                    Icons.lightbulb_outline,
                    const Color(0xFFE0F7F8), // Cyan très pâle
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // ILLUSTRATION CENTRALE
              Center(
                child: Image.network(
                  'https://cdn-icons-png.flaticon.com/512/5692/5692030.png',
                  height: 160,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.quiz,
                      size: 100,
                      color: orangeVif
                  ),
                ),
              ),

              const SizedBox(height: 50),

              // BOUTONS D'ACTION
              _buildPrimaryButton(
                context,
                "Commencer le quizz",
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const QuizQuestionScreen()),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildSecondaryButton(
                "Revoir la leçon",
                    () {
                  // Action pour revenir en arrière ou vers le cours
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget utilitaire pour les cartes du haut
  Widget _buildInfoCard(String text, IconData icon, Color bgColor) {
    return Expanded(
      child: Container(
        height: 110,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: blancPure,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 22, color: bleuFonce),
            ),
            const SizedBox(height: 8),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Bouton Principal (Bleu Foncé)
  Widget _buildPrimaryButton(BuildContext context, String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bleuFonce,
          foregroundColor: blancPure,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // Bouton Secondaire (Bordure Grise)
  Widget _buildSecondaryButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: grisTresClair, width: 1.2),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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