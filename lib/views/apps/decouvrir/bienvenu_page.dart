import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class BienvenuPage extends StatelessWidget {
  const BienvenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          children: [
            const Spacer(),

            // --- BULLE DE DIALOGUE (Style Racines) ---
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 25),
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 25,
                        offset: const Offset(0, 10),
                      ),
                    ],
                    // Bordure légèrement colorée pour rappeler la terre/racines
                    border: Border.all(color: Colors.orange.shade200, width: 2.5),
                  ),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 20,
                        color: Color(0xFF2D3436),
                        height: 1.5,
                      ),
                      children: [
                        const TextSpan(text: "Bienvenue sur "),
                        TextSpan(
                          text: "LinguaLearn\n",
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: Colors.orange.shade800,
                          ),
                        ),
                        const TextSpan(
                          text: "Les langues de nos racines. ✨\n",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const TextSpan(
                          text: "Choisis tes langues.",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
                // Le petit triangle (la flèche de la bulle)
                Positioned(
                  bottom: 10,
                  child: RotationTransition(
                    turns: const AlwaysStoppedAnimation(45 / 360),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.orange.shade200, width: 2.5),
                      ),
                    ),
                  ),
                ),
                // Cache pour la base du triangle
                Positioned(
                  bottom: 24,
                  child: Container(
                    width: 45,
                    height: 20,
                    color: Colors.white,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // --- MASCOTTE ---
            Lottie.asset(
              'assets/lottie/Sad mascot.json', 
              width: 260,
              height: 260,
              fit: BoxFit.contain,
            ),

            const Spacer(flex: 2),

            // --- BOUTON D'ACTION ---
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () => Get.toNamed('/selection'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8F00),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 65),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "CONTINUER",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}