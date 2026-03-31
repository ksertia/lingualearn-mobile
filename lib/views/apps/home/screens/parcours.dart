import 'package:fasolingo/controller/apps/parcoure/parcoure_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:lottie/lottie.dart';
import 'package:fasolingo/helpers/services/module_service.dart';
import 'package:fasolingo/models/modules/modul_model.dart';
import '../../../../widgets/parcourspage/ParcoursStepItem.dart';
import '../../../../widgets/stepsscreens/custom_app_bar.dart';

class ParcoursSelectionPage extends StatelessWidget {
  const ParcoursSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ParcoursSelectionController controller =
      Get.put(ParcoursSelectionController());

    final dynamic _args = Get.arguments;
    final String? moduleLottieArg = (_args is Map && _args['moduleLottie'] != null) ? _args['moduleLottie'].toString() : null;
    final String backgroundImage = (_args is Map && _args['backgroundImage'] != null) ? _args['backgroundImage'].toString() : 'assets/images/app/plan3.png';

    final Future<List<ModuleModel>> _modulesFuture = ModuleService.getAllModules();

    final List<String> _moduleLotties = const [
      'assets/lottie/poulet.json',
      'assets/lottie/elephant.json',
      'assets/lottie/cat.json',
      'assets/lottie/Chicken.json',
      'assets/lottie/dino.json',
      'assets/lottie/Dog.json',
      'assets/lottie/Lion.json',
      'assets/lottie/croco.json',
      'assets/lottie/tiger.json',
      'assets/lottie/panda.json',
      'assets/lottie/koala.json',
      'assets/lottie/snake.json',
      'assets/lottie/toucan.json',
      'assets/lottie/rhino.json',
      'assets/lottie/leopard.json',
      'assets/lottie/buffalo.json',
    ];

    String _resolveLottieFromModule(List<ModuleModel> modules, String moduleId) {
      try {
        final pos = modules.indexWhere((m) => m.id == moduleId);
        if (pos != -1) {
          return _moduleLotties[pos % _moduleLotties.length];
        }
      } catch (_) {}
      return 'assets/lottie/Lion.json';
    }

    const Color primaryBlue = Color(0xFF00CED1);
    const Color colorCompleted = Color(0xFF81C784); // Vert clair pour terminé
    const Color orangeAccent = Color(0xFFFF9800); // Orange pour en cours
    const Color colorLocked = Color(0xFF9E9E9E); // Gris pour verrouillé

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: "Suivez votre parcours"),
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

        return FutureBuilder<List<ModuleModel>>(
          future: _modulesFuture,
          builder: (context, modulesSnap) {
            final String moduleLottie = moduleLottieArg ?? (modulesSnap.hasData ? _resolveLottieFromModule(modulesSnap.data!, controller.moduleId) : 'assets/lottie/Lion.json');

            return Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(backgroundImage),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.22), BlendMode.darken),
                ),
              ),
              child: RefreshIndicator(
                onRefresh: () => controller.fetchPaths(),
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 110, bottom: 20, left: 15, right: 15),
                  itemCount: controller.paths.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      String title = "MODULE";
                      String description = "";
                      if (modulesSnap.hasData && modulesSnap.data!.isNotEmpty) {
                        final found = modulesSnap.data!.where((m) => m.id == controller.moduleId).toList();
                        if (found.isNotEmpty) {
                          title = found.first.title;
                          description = found.first.description;
                        }
                      }

                      final int total = controller.paths.length;
                      final int completed = controller.paths.where((p) => (p.status ?? "") == "completed").length;
                      final double progress = total > 0 ? (completed / total) : 0.0;

                      return _buildHeaderCard(title, description, progress, completed, total, moduleLottie);
                    }

                    final path = controller.paths[index - 1];

                    debugPrint("=== PATH ${index - 1} ===");
                    debugPrint("ID: ${path.id}");
                    debugPrint("Title: ${path.title}");
                    debugPrint("Status: ${path.status}");
                    debugPrint("Progress: ${path.progress}");
                    debugPrint("ProgressPercentage: ${path.progressPercentage}");
                    debugPrint("IsActive: ${path.isActive}");
                    debugPrint("==================");

                    // TA LOGIQUE DE STATUT
                    String pathStatus = path.status ?? "locked";
                    bool isCompleted = pathStatus == "completed";
                    bool isUnlocked = pathStatus == "unlocked" || pathStatus == "completed";

                    if (pathStatus == "locked") {
                      bool allPathsLocked = controller.paths.every((p) => (p.status ?? "locked") == "locked");
                      if (allPathsLocked && index == 1) {
                        pathStatus = "unlocked";
                        isUnlocked = true;
                        print("🔓 [FALLBACK] Premier parcours débloqué automatiquement");
                      }
                    }

                    bool isActive = isUnlocked;
                    print("Path $index: Status='$pathStatus' → isCompleted=$isCompleted, isActive=$isActive");

                    return Align(
                      alignment: index % 2 == 0 ? Alignment.centerRight : Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: 0.92,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                            child: ParcoursStepItem(
                              number: "${path.index + 1}",
                              title: path.title,
                              statusText: isCompleted ? 'Terminé' : (isActive ? 'En cours' : 'Verrouillé'),
                              subtitle: isActive ? path.description : "Verrouillé : Terminez le parcours précédent",
                              color: isActive ? (isCompleted ? colorCompleted : orangeAccent) : colorLocked,
                              isCompleted: isCompleted,
                              isActive: isActive,
                              icon: !isActive ? Icons.lock_rounded : (isCompleted ? Icons.check : Icons.play_arrow_rounded),
                              onTap: isActive
                                  ? () => Get.toNamed('/stepsscreens', arguments: {
                                        'moduleId': controller.moduleId,
                                        'pathId': path.id,
                                        'moduleLottie': moduleLottie,
                                      })
                                  : () {
                                      Get.snackbar(
                                        "Parcours Verrouillé 🔒",
                                        "Terminez le parcours précédent pour débloquer celui-ci.",
                                        snackPosition: SnackPosition.BOTTOM,
                                        backgroundColor: Colors.black87,
                                        colorText: Colors.white,
                                        icon: const Icon(Icons.lock, color: Colors.orangeAccent),
                                        margin: const EdgeInsets.all(15),
                                      );
                                    },
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
                 },
        );
      }),
    );
  }

  Widget _buildHeaderCard(String title, String description, double progress, int completed, int total, String lottieAsset) {
    final int displayTotal = total <= 0 ? 0 : total;
    final int percent = (progress * 100).clamp(0, 100).toInt();

    return Container(
      margin: const EdgeInsets.only(bottom: 30),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color.fromARGB(181, 251, 138, 0), Color(0xFF00A3A3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(description, style: const TextStyle(color: Colors.white70, fontSize: 15), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(value: progress, backgroundColor: Colors.white24, valueColor: const AlwaysStoppedAnimation<Color>(Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text("$percent%", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text("$completed/$displayTotal Parcours", style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 88,
              height: 88,
              color: Colors.white24,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Lottie.asset(
                  lottieAsset,
                  fit: BoxFit.contain,
                  repeat: true,
                ),
              ),
            ),
          ),
        ],
      ),
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
                child: Container(height: 90, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20))),
              )
            ],
          ),
        ),
      ),
    );
  }
}