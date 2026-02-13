import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';

class AppColors {
  static const Color bleuFonce = Color.fromRGBO(0, 0, 153, 1);     // (0, 0, 153)
  static const Color cyan = Color.fromRGBO(0, 206, 209, 1);          // (0, 206, 209)
  static const Color orange = Color.fromRGBO(255, 127, 0, 1);        // (255, 127, 0)
  static const Color grisClair = Color.fromRGBO(192, 192, 192, 1);   // (192, 192, 192)
  static const Color blanc = Color.fromRGBO(255, 255, 255, 1);       // (255, 255, 255)
}

class CertificationScreen extends StatefulWidget {
  final String userName;
  final String moduleName;

  const CertificationScreen({
    super.key,
    required this.userName,
    required this.moduleName,
  });

  @override
  State<CertificationScreen> createState() => _CertificationScreenState();
}

class _CertificationScreenState extends State<CertificationScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 4));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blanc,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // --- AFFICHAGE DU CERTIFICAT ---
                  _buildCertificateImage(),

                  const SizedBox(height: 32),

                  const Text(
                    "Certification obtenue 🎓",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.bleuFonce,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    widget.userName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: AppColors.bleuFonce,
                    ),
                  ),
                  const SizedBox(height: 8),

                  const Text("a validé le module", style: TextStyle(color: Colors.grey)),

                  const SizedBox(height: 8),
                  Text(
                    widget.moduleName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.cyan,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // --- BOUTONS D'ACTION ---
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.download_rounded, color: Colors.white),
                    label: const Text("Télécharger le certificat"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.bleuFonce,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                  const SizedBox(height: 12),

                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                      side: const BorderSide(color: AppColors.grisClair),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      "Module suivant",
                      style: TextStyle(color: AppColors.bleuFonce, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- ANIMATION DE CONFETTIS ---
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive, // Explosion tout autour
            shouldLoop: false,
            colors: const [
              AppColors.bleuFonce,
              AppColors.cyan,
              AppColors.orange,
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCertificateImage() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppColors.bleuFonce.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: AppColors.cyan.withOpacity(0.3), width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Remplace l'URL par ton image locale ou distante
            Image.network(
              'https://img.freepik.com/free-vector/professional-certificate-template_23-2148914389.jpg',
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            // Petit badge orange par-dessus l'image pour rappeler la palette
            Positioned(
              bottom: 10,
              right: 10,
              child: CircleAvatar(
                backgroundColor: AppColors.orange,
                radius: 20,
                child: const Icon(Icons.verified, color: Colors.white, size: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }
}