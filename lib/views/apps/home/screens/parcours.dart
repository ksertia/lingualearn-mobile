import 'package:fasolingo/controller/apps/parcoure/parcoure_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../widgets/parcourspage/ParcoursStepItem.dart';
import '../../../../widgets/stepsscreens/custom_app_bar.dart';

class ParcoursSelectionPage extends StatelessWidget {
  const ParcoursSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ParcoursSelectionController controller =
        Get.put(ParcoursSelectionController());

    const Color primaryBlue = Color(0xFF00CED1);
    const Color orangeAccent = Color(0xFFFF8C00);
    const Color colorLocked = Color(0xFFBDC3C7);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: "Suivez Votre Parcours"),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildShimmerEffect();
        }

        if (controller.paths.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.map_outlined, size: 50, color: Colors.grey.shade400),
                const SizedBox(height: 10),
                const Text("Aucun parcours disponible.",
                    style: TextStyle(color: Colors.grey)),
                TextButton(
                    onPressed: () => controller.fetchPaths(),
                    child: const Text("Réessayer")),
              ],
            ),
          );
        }

        return Stack(
          children: [
            Positioned(
              left: 48,
              top: 0,
              bottom: 0,
              child: Container(width: 2, color: Colors.grey.shade200),
            ),
            RefreshIndicator(
              onRefresh: () => controller.fetchPaths(),
              child: ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                itemCount: controller.paths.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return const Padding(
                      padding: EdgeInsets.only(bottom: 30, left: 60),
                      child: Text(
                        "Complétez chaque parcours pour avancer.",
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                      ),
                    );
                  }

                  final path = controller.paths[index - 1];

                  // 🔍 LOGS DEBUG - Données des parcours
                  debugPrint("=== PATH ${index - 1} ===");
                  debugPrint("ID: ${path.id}");
                  debugPrint("Title: ${path.title}");
                  debugPrint("Status: ${path.status}");
                  debugPrint("Progress: ${path.progress}");
                  debugPrint("ProgressPercentage: ${path.progressPercentage}");
                  debugPrint("IsActive: ${path.isActive}");
                  debugPrint("==================");

                  // Utiliser les vrais statuts du backend
                  String pathStatus = path.status ?? "locked";
                  bool isCompleted = pathStatus == "completed";
                  bool isUnlocked = pathStatus == "unlocked" || pathStatus == "completed";
                  
                  // 🔧 FALLBACK AMÉLIORÉ: Logique basée sur l'index des parcours
                  if (pathStatus == "locked") {
                    bool allPathsLocked = controller.paths.every((p) => (p.status ?? "locked") == "locked");
                    
                    if (allPathsLocked) {
                      // Si tous les parcours sont locked, débloquer selon l'ordre séquentiel
                      if (index == 1) {
                        // Premier parcours toujours débloqué
                        pathStatus = "unlocked";
                        isUnlocked = true;
                        print("🔓 [FALLBACK] Premier parcours débloqué automatiquement");
                      } else {
                        // Parcours suivants restent locked pour progression séquentielle
                        pathStatus = "locked";
                        isUnlocked = false;
                      }
                    }
                  }
                  
                  bool isActive = isUnlocked;

                  // 📊 LOG du statut calculé
                  print("Path ${index}: Status='$pathStatus' → isCompleted=$isCompleted, isActive=$isActive");

                  return ParcoursStepItem(
                    number: "${path.index + 1}",
                    title: path.title,
                    subtitle: isActive
                        ? path.description
                        : "Verrouillé : Terminez le parcours précédent",
                    color: isActive
                        ? (isCompleted ? primaryBlue : orangeAccent)
                        : colorLocked,
                    isCompleted: isCompleted,
                    isActive: isActive,
                    icon: !isActive
                        ? Icons.lock_rounded
                        : (isCompleted
                            ? Icons.check
                            : Icons.play_arrow_rounded),
                    onTap: isActive
                        ? () => Get.toNamed('/stepsscreens', arguments: {
                              'moduleId': controller.moduleId,
                              'pathId': path.id,
                            })
                        : () {
                            Get.snackbar(
                              "Parcours Verrouillé 🔒",
                              "Terminez le parcours précédent pour débloquer celui-ci.",
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.black87,
                              colorText: Colors.white,
                              icon: const Icon(Icons.lock,
                                  color: Colors.orangeAccent),
                              margin: const EdgeInsets.all(15),
                            );
                          },
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: 5,
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.only(bottom: 25),
          child: Row(
            children: [
              const CircleAvatar(radius: 28, backgroundColor: Colors.white),
              const SizedBox(width: 20),
              Expanded(
                child: Container(
                  height: 90,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
