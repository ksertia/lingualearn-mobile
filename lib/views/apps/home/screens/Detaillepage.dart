import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DetaillePage extends StatelessWidget {
  const DetaillePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Récupération du titre via les arguments GetX
    final data = Get.arguments;
    final String titreEtape = data != null ? data['titre'] : "Étape 1 : Salutations";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Column(
          children: [
            Text(
              titreEtape,
              style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Text(
              "Leçon 2 / 3",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            const Text(
              "Dire bonsoir",
              style: TextStyle(fontSize: 22, color: Colors.black87, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),

            // --- SECTION ILLUSTRATION (Image + Bulle) ---
            _buildIllustrationSection(),

            const SizedBox(height: 30),

            // --- SECTION TRADUCTION ---
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Traduction :",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Text(
                "Bonne soirée !",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),

            const Spacer(),

            // --- BOUTON ORANGE ---
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // Action pour passer à la suite
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B2C),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "Continuer la leçon",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildIllustrationSection() {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            // Cadre gris avec l'image intégrée
            Container(
              width: double.infinity,
              height: 280,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F6F9),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Image.asset(
                    'assets/img/8e4b0793efdb04971f43cf916a5f151e.jpg', // Chemin vers votre image
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            // Bulle de texte
            Positioned(
              top: 30,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE9F2FE),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
                  ],
                ),
                child: const Text(
                  "Bonsoir !",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 25),
        _buildAudioVisualizer(),
      ],
    );
  }

  Widget _buildAudioVisualizer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Bouton HP Turquoise
        Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            color: Color(0xFF00BFA5),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.volume_up, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 12),
        // Les points turquoise
        ...List.generate(4, (index) => Padding(
          padding: const EdgeInsets.only(right: 5),
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: index == 3 ? const Color(0xFF00BFA5) : const Color(0xFFB2EBF2),
              shape: BoxShape.circle,
            ),
          ),
        )),
        const SizedBox(width: 2),
        // Barre de progression
        Container(
          width: 100,
          height: 8,
          decoration: BoxDecoration(
            color: const Color(0xFFB2EBF2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: 0.6,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF00BFA5),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Symbole final demandé
        const Text(
          "+ ))",
          style: TextStyle(
            color: Color(0xFFB2EBF2),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}