import 'package:fasolingo/controller/apps/etapes/etapes_controller.dart';
import 'package:fasolingo/views/apps/home/StepContentScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../widgets/stepsscreens/custom_app_bar.dart';
import '../../../../widgets/stepsscreens/parcours_item.dart';

class StepsScreensPages extends StatelessWidget {
  const StepsScreensPages({super.key});

  @override
  Widget build(BuildContext context) {
    final StepsController controller = Get.put(StepsController());

    final dynamic _args = Get.arguments;
    final String moduleLottie = (_args is Map && _args['moduleLottie'] != null)
        ? _args['moduleLottie'].toString()
        : 'assets/lottie/Lion.json';
    const Color primaryBlue = Color(0xFF00CED1);
    const Color colorCompleted = Color(0xFF81C784);

    const Color orangeAccent = Color(0xFFFF9800);
    const Color colorLocked = Color(0xFF9E9E9E);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const CustomAppBar(title: "Mon Parcours d'Apprentissage"),
      body: Container(
        constraints: const BoxConstraints.expand(),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/app/plan2.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Obx(() {
          if (controller.isLoading.value) {
            return _buildShimmerEffect(primaryBlue);
          }

          if (controller.steps.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.info_outline, size: 50, color: Colors.grey),
                  const SizedBox(height: 10),
                  const Text(
                    "Aucune étape disponible pour le moment.",
                    style: TextStyle(color: Colors.white),
                  ),
                  TextButton(
                    onPressed: () => controller.onRefresh(),
                    child: const Text(
                      "Réactualiser",
                      style: TextStyle(color: Colors.orange),
                    ),
                  )
                ],
              ),
            );
          }

          return Stack(
            children: [
              Positioned(
                left: 56,
                top: MediaQuery.of(context).padding.top + 30,
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height,
                    ),
                    child: Column(
                      children: [
                        SafeArea(
                          top: true,
                          bottom: false,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: primaryBlue.withOpacity(0.4),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Lottie.asset(
                                  moduleLottie,
                                  height: 45,
                                  repeat: true,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    "Mon chemin magique",
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: true,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: primaryBlue,
                                      letterSpacing: 0.5,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withOpacity(0.1),
                                          offset: const Offset(1, 1),
                                          blurRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        ListView.builder(
                          padding: const EdgeInsets.only(top: 16),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.steps.length,
                          itemBuilder: (context, index) {
                            final step = controller.steps[index];

                            String stepStatus = step.status ?? "locked";
                            if (stepStatus == "started") {
                              stepStatus = "unlocked";
                            }
                            bool isCompleted = stepStatus == "completed";
                            bool isUnlocked = stepStatus == "unlocked" ||
                                stepStatus == "started" ||
                                stepStatus == "completed";

                            if (stepStatus == "locked") {
                              bool allStepsLocked = controller.steps.every(
                                  (s) => (s.status ?? "locked") == "locked");
                              if (allStepsLocked && index == 0) {
                                stepStatus = "unlocked";
                                isUnlocked = true;
                              }
                            }

                            bool isActive = isUnlocked;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: ParcoursItem(
                                label: "Étape ${index + 1}: ${step.title}",
                                status: isActive
                                    ? (isCompleted ? "Terminé" : "En cours")
                                    : "Verrouillé",
                                mainColor: isActive
                                    ? (isCompleted
                                        ? colorCompleted
                                        : orangeAccent)
                                    : colorLocked,
                                isCompleted: isCompleted,
                                isActive: isActive,
                                icon: !isActive
                                    ? Icons.lock_outline
                                    : (isCompleted
                                        ? Icons.check
                                        : Icons.play_arrow_rounded),
                                onTap: isActive
                                    ? () {
                                        String currentUserId =
                                            "cmnehqt4j004fre9xtg45nu91";

                                        Get.to(
                                          () => StepContentScreen(
                                            stepId: step.id,
                                            userId: currentUserId,
                                          ),
                                          transition: Transition.rightToLeft,
                                        );
                                      }
                                    : () {
                                        Get.snackbar(
                                          "Verrouillé",
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
              ),
            ],
          );
        }),
      ),
    );
  }

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
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (_, __) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      const CircleAvatar(
                          radius: 25, backgroundColor: Colors.white),
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
