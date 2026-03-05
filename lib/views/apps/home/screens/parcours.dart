import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:lottie/lottie.dart'; // 👈 Ajout de l'import Lottie
import 'package:fasolingo/controller/apps/parcoure/parcoure_controller.dart';

class ParcoursSelectionPage extends StatelessWidget {
  const ParcoursSelectionPage({super.key});

  /// 🦊 Mapping des animaux Lottie par index
  static const Map<int, String> moduleAnimals = {
    0: 'assets/lottie/poulet.json',
    1: 'assets/lottie/elephant.json',
    2: 'assets/lottie/cat.json',
    3: 'assets/lottie/Chicken.json',
    4: 'assets/lottie/dino.json',
    5: 'assets/lottie/Dog.json',
    6: 'assets/lottie/Lion.json',
    7: 'assets/lottie/croco.json',
    8: 'assets/lottie/tiger.json',
    9: 'assets/lottie/panda.json',
    10: 'assets/lottie/koala.json',
    11: 'assets/lottie/snake.json',
    12: 'assets/lottie/toucan.json',
    13: 'assets/lottie/rhino.json',
    14: 'assets/lottie/leopard.json',
    15: 'assets/lottie/buffalo.json',
  };

  @override
  Widget build(BuildContext context) {
    final ParcoursSelectionController controller = Get.put(ParcoursSelectionController());

    return Scaffold(
      body: Stack(
        children: [
          /// 🌄 FOND D'ÉCRAN
          Positioned.fill(
            child: Image.asset(
              "assets/images/quiz/brousse.jpeg",
              fit: BoxFit.cover,
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                /// 🔵 HEADER FIXE
                _buildSavaneHeader(),

                /// 📜 CONTENU DYNAMIQUE
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return _buildShimmerEffect();
                    }

                    if (controller.paths.isEmpty) {
                      return _buildEmptyState(controller);
                    }

                    return RefreshIndicator(
                      onRefresh: () => controller.fetchPaths(),
                      color: Colors.orange,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        itemCount: controller.paths.length,
                        itemBuilder: (context, index) {
                          final path = controller.paths[index];
                          final bool isLast = index == controller.paths.length - 1;

                          String pathStatus = path.status ?? "locked";
                          bool isCompleted = pathStatus == "completed";
                          bool isUnlocked = pathStatus == "unlocked" || pathStatus == "completed";

                          if (pathStatus == "locked") {
                            bool allPathsLocked = controller.paths.every((p) => (p.status ?? "locked") == "locked");
                            if (allPathsLocked && index == 0) isUnlocked = true;
                          }

                          // 🟢 Sélection de l'animal selon l'index
                          final String lottieAsset = moduleAnimals[index] ?? 'assets/lottie/Lion.json';

                          return _SavaneStepRow(
                            path: path,
                            isLast: isLast,
                            isUnlocked: isUnlocked,
                            isCompleted: isCompleted,
                            lottieAsset: lottieAsset, // 👈 On passe l'asset à la rangée
                            onTap: () => _handleNavigation(isUnlocked, controller, path),
                          );
                        },
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🏎 LOGIQUE DE NAVIGATION
  void _handleNavigation(bool isUnlocked, dynamic controller, dynamic path) {
    if (isUnlocked) {
      Get.toNamed('/stepsscreens', arguments: {
        'moduleId': controller.moduleId,
        'pathId': path.id,
      });
    } else {
      Get.snackbar(
        "Parcours Verrouillé 🔒",
        "Terminez le parcours précédent pour débloquer celui-ci.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
        icon: const Icon(Icons.lock, color: Colors.orangeAccent),
        margin: const EdgeInsets.all(15),
      );
    }
  }

  /// ✨ EFFET SHIMMER
  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.white.withOpacity(0.3),
      highlightColor: Colors.white.withOpacity(0.1),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        itemCount: 5,
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.only(bottom: 25),
          child: Row(
            children: [
              const CircleAvatar(radius: 22, backgroundColor: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🏜 ÉTAT VIDE
  Widget _buildEmptyState(ParcoursSelectionController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.map_outlined, size: 60, color: Colors.white70),
          const SizedBox(height: 10),
          const Text("Aucun parcours disponible.",
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          TextButton(
            onPressed: () => controller.fetchPaths(),
            child: const Text("Réessayer", style: TextStyle(color: Colors.orangeAccent, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  /// 🔵 HEADER SAVANE
  Widget _buildSavaneHeader() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Get.back(),
                child: const CircleAvatar(
                  backgroundColor: Colors.orange,
                  child: Icon(Icons.arrow_back, color: Colors.white),
                ),
              ),
              const SizedBox(width: 15),
              const Expanded(
                child: Text(
                  "Suivez votre parcours",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const Icon(Icons.star_border, color: Colors.white, size: 26),
              const Icon(Icons.star_border, color: Colors.white, size: 26),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF39C12).withOpacity(0.95),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("MODULE 1 : Dibi 🇧🇫",
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                  const Icon(Icons.pets, color: Colors.white, size: 30),
                ],
              ),
              const SizedBox(height: 15),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: const LinearProgressIndicator(
                  value: 0.7,
                  minHeight: 10,
                  backgroundColor: Colors.black12,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 🦁 ITEM DE LA LISTE
class _SavaneStepRow extends StatelessWidget {
  final dynamic path;
  final bool isLast;
  final bool isUnlocked;
  final bool isCompleted;
  final String lottieAsset; // 👈 Ajout du chemin Lottie
  final VoidCallback onTap;

  const _SavaneStepRow({
    required this.path,
    required this.isLast,
    required this.isUnlocked,
    required this.isCompleted,
    required this.lottieAsset, // 👈 Requis
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 50,
            child: Column(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: !isUnlocked ? Colors.grey.shade400 : (isCompleted ? Colors.cyan : Colors.orange),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: Icon(
                    !isUnlocked ? Icons.lock : (isCompleted ? Icons.check : Icons.play_arrow),
                    color: Colors.white, size: 20,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 5,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: Colors.orange.withOpacity(0.8),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 25),
              child: GestureDetector(
                onTap: onTap,
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(isUnlocked ? (isCompleted ? "TERMINÉ" : "EN COURS") : "VERROUILLÉ",
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isUnlocked ? Colors.orange : Colors.grey)),
                            Text((path.title ?? "").toUpperCase(),
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isUnlocked ? const Color(0xFF1A237E) : Colors.grey.shade400)),
                          ],
                        ),
                      ),

                      /// 🐣 AFFICHAGE LOTTIE DYNAMIQUE
                      SizedBox(
                        height: 60,
                        width: 60,
                        child: Opacity(
                          opacity: isUnlocked ? 1.0 : 0.3,
                          child: Lottie.asset(
                            lottieAsset,
                            repeat: isUnlocked, // L'animal bouge seulement si débloqué
                            animate: isUnlocked,
                            errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.pets, color: Colors.black12, size: 40),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}