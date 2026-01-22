import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DiscoveryController extends GetxController {
  var currentPage = 0.obs;
  final int totalPages = 7;
  late PageController pageController;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
  }

  double get progress => (currentPage.value + 1) / totalPages;

  void nextPage() {
    if (currentPage.value < totalPages - 1) {
      pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void previousPage() {
    if (currentPage.value > 0) {
      pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  // NOUVEAU : Changement automatique après une réponse au Quiz
  void selectResponse() {
    // On attend un tout petit peu pour que l'utilisateur voie son choix
    Future.delayed(const Duration(milliseconds: 500), () {
      nextPage();
    });
  }

  // Savoir si on doit afficher les boutons de navigation (Seulement pour les 3 premières pages)
  bool get showNavButtons => currentPage.value < 3;
}