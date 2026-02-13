import 'package:fasolingo/controller/apps/etapes/etapes_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart'; // N'oublie pas d'ajouter shimmer dans ton pubspec.yaml
import '../../../../widgets/stepsscreens/custom_app_bar.dart';
import '../../../../widgets/stepsscreens/parcours_item.dart';

class StepsScreensPages extends StatelessWidget {
  const StepsScreensPages({super.key});

  @override
  Widget build(BuildContext context) {
    final StepsController controller = Get.put(StepsController());

    const Color primaryBlue = Color(0xFF00CED1);
    const Color orangeAccent = Color(0xFFFF8C00);
    const Color colorLocked = Colors.grey;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: "Mon Parcours d'Apprentissage"),
      body: Obx(() {
        // 1. Gestion de l'état de chargement avec Shimmer
        if (controller.isLoading.value) {
          return _buildShimmerEffect(primaryBlue);
        }

        // 2. Gestion de la liste vide
        if (controller.steps.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.info_outline, size: 50, color: Colors.grey),
                const SizedBox(height: 10),
                const Text("Aucune étape disponible pour le moment."),
                TextButton(
                  onPressed: () => controller.onRefresh(),
                  child: const Text("Réactualiser"),
                )
              ],
            ),
          );
        }

        return Stack(
          children: [
            // Ligne verticale décorative
            Positioned(
              left: 56,
              top: 30,
              bottom: 30,
              child: Container(
                width: 3,
                color: primaryBlue.withOpacity(0.2),
              ),
            ),

            RefreshIndicator(
              onRefresh: () => controller.onRefresh(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                child: Column(
                  children: [
                    const Text(
                      "Prochaines étapes",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 40),

                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.steps.length,
                      itemBuilder: (context, index) {
                        final step = controller.steps[index];
                        bool isUnlocked = (index == 0) ? true : step.isActive;
                        bool isCompleted = false; 

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 30),
                          child: ParcoursItem(
                            label: "Étape ${index + 1}: ${step.title}",
                            status: isUnlocked 
                                ? (isCompleted ? "Terminé" : "En cours") 
                                : "Verrouillé",
                            mainColor: isUnlocked 
                                ? (isCompleted ? primaryBlue : orangeAccent) 
                                : colorLocked,
                            icon: !isUnlocked 
                                ? Icons.lock_outline 
                                : (isCompleted ? Icons.check : Icons.play_arrow_rounded),
                            onTap: isUnlocked
                                ? () => Get.toNamed('/lessonselectionscreen', arguments: step.id)
                                : () {
                                    Get.snackbar(
                                      "🔒 Verrouillé",
                                      "Complète les étapes précédentes pour débloquer celle-ci.",
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: Colors.black87,
                                      colorText: Colors.white,
                                    );
                                  },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  // Widget Shimmer pour l'effet de chargement
  Widget _buildShimmerEffect(Color primaryColor) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          children: [
            Container(
              height: 30,
              width: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: ListView.builder(
                itemCount: 5, // Affiche 5 squelettes
                itemBuilder: (_, __) => Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: Row(
                    children: [
                      const CircleAvatar(radius: 25, backgroundColor: Colors.white),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}