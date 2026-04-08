import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:confetti/confetti.dart';
import 'package:lottie/lottie.dart';

class DiscoveryController extends GetxController {
  var currentPage = 0.obs;

  final int totalPages = 8;


  late PageController pageController;
  
  late ConfettiController confettiController;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
    confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void onClose() {
    pageController.dispose();
    confettiController.dispose(); 
    super.onClose();
  }

  // Calcul de la progression pour la barre LinearProgressIndicator
  double get progress => (currentPage.value + 1) / totalPages;

  // Logique de navigation
  void nextPage() {
    if (currentPage.value < totalPages - 1) {
      pageController.nextPage(
          duration: const Duration(milliseconds: 300), 
          curve: Curves.easeInOut
      );
    } else {
      _showFinalCelebration();
    }
  }

  void previousPage() {
    if (currentPage.value > 0) {
      pageController.previousPage(
          duration: const Duration(milliseconds: 300), 
          curve: Curves.easeInOut
      );
    }
  }

  // --- POPUP DE FIN AVEC CONFETTIS ---
  void _showFinalCelebration() {
    confettiController.play();

    Get.dialog(
      barrierDismissible: false,
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 20),
                  Lottie.asset(
                    'assets/lottie/Happy mascot.json',
                    height: 150,
                    repeat: false,
                  ),
                  const Text(
                    "Etape terminée !",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF58CC02),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Félicitations ! Tu as terminé toutes les étapes de cette leçon.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 30),
                  // Bouton pour débloquer/quitter
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        confettiController.stop();
                        Get.back();
                        Get.back(); 
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF8F00),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 4,
                      ),
                      child: const Text(
                        "CONTINUER",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ConfettiWidget(
              confettiController: confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
            ),
          ],
        ),
      ),
    );
  }

  bool get showNavButtons => currentPage.value < 3;
}