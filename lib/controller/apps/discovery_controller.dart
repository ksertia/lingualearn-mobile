import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:confetti/confetti.dart';

class DiscoveryController extends GetxController {
  var currentPage = 0.obs;
  final int totalPages = 8;
  late PageController pageController;
  
  // AJOUT : Contrôleur de confettis
  late ConfettiController confettiController;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
    // Initialisation des confettis
    confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void onClose() {
    pageController.dispose();
    confettiController.dispose(); // Important pour la mémoire
    super.onClose();
  }

  double get progress => (currentPage.value + 1) / totalPages;

  void nextPage() {
    if (currentPage.value < totalPages - 1) {
      pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void previousPage() {
    if (currentPage.value > 0) {
      pageController.previousPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  // Lancé quand le quiz de drag est fini
  void selectResponse() {
    confettiController.play(); // On lance les confettis
    Future.delayed(const Duration(milliseconds: 500), () {
      nextPage();
    });
  }

  bool get showNavButtons => currentPage.value < 3;
}