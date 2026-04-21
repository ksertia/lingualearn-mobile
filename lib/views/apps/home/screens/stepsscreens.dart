import 'package:fasolingo/controller/apps/etapes/etapes_controller.dart';
import 'package:fasolingo/helpers/services/etapes/etape_service.dart';
import 'package:fasolingo/helpers/services/parcoure/parcoure_service.dart';
import 'package:fasolingo/views/apps/home/StepContentScreen.dart';
import 'package:fasolingo/views/apps/home/dashboard_screen.dart';
import 'package:fasolingo/widgets/stepsscreens/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import 'package:fasolingo/models/parcoure/parcour_model.dart';
import '../../../../widgets/stepsscreens/parcours_item.dart';

class StepsScreensPages extends StatelessWidget {
  const StepsScreensPages({super.key});

  static const Color primaryBlue = Color(0xFF00CED1);
  static const Color colorCompleted = Color(0xFF81C784);
  static const Color orangeAccent = Color(0xFFFF9800);
  static const Color colorLocked = Color(0xFF9E9E9E);

  @override
  Widget build(BuildContext context) {
    final StepsController controller = Get.put(StepsController());

    final dynamic _args = Get.arguments;
    final String moduleLottie = (_args is Map && _args['moduleLottie'] != null)
        ? _args['moduleLottie'].toString()
        : 'assets/lottie/Lion.json';

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

          if (controller.items.isEmpty) {
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

          final List<_StepsPageData> pages = [];
          LearningPathModel? currentPath;
          List<StepModel> currentSteps = [];

          for (final dynamic item in controller.items) {
            if (item is LearningPathModel) {
              if (currentPath != null) {
                pages.add(_StepsPageData(
                    path: currentPath, steps: [...currentSteps]));
              }
              currentPath = item;
              currentSteps = [];
            } else if (item is StepModel) {
              currentSteps.add(item);
            }
          }

          if (currentPath != null) {
            pages.add(
                _StepsPageData(path: currentPath, steps: [...currentSteps]));
          } else if (currentSteps.isNotEmpty) {
            pages.add(_StepsPageData(path: null, steps: currentSteps));
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
                              children: [
                                Lottie.asset(
                                  moduleLottie,
                                  height: 45,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    "Mon chemin magique",
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: primaryBlue,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        _buildStepsPagesSection(context, pages, controller),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Obx(() {
                      if (pages.isEmpty) return const SizedBox.shrink();
                      final int pageIndex = controller.currentPage.value
                          .clamp(0, pages.length - 1);
                      final page = pages[pageIndex];
                      if (page.path == null) return const SizedBox.shrink();

                      final allCompleted = page.steps.isNotEmpty &&
                          page.steps.every((s) {
                            final st = (s.progress != null &&
                                    s.progress!['status'] != null)
                                ? s.progress!['status'].toString().toLowerCase()
                                : (s.status ?? 'locked')
                                    .toString()
                                    .toLowerCase();
                            return st == 'completed';
                          });

                      if (!allCompleted) return const SizedBox.shrink();

                      final args = Get.arguments;
                      final userId = (args is Map && args['userId'] != null)
                          ? args['userId'].toString()
                          : '';

                      return SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: userId.isEmpty
                              ? null
                              : () async {
                                  final ok =
                                      await LearningPathService.completePath(
                                    userId: userId,
                                    pathId: page.path!.id,
                                  );
                                  if (ok) {
                                    Get.back(result: true);
                                  }
                                },
                          child: const Text('Terminé'),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildStepsPagesSection(BuildContext context,
      List<_StepsPageData> pages, StepsController controller) {
    if (pages.isEmpty) {
      return const Center(
        child: Text(
          "Aucune étape disponible.",
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (pages.length > 1)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  color: Colors.white,
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: controller.currentPage.value > 0
                      ? () =>
                          controller.goToPage(controller.currentPage.value - 1)
                      : null,
                ),
                Text(
                  "Parcours ${controller.currentPage.value + 1} / ${pages.length}",
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  color: Colors.white,
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: controller.currentPage.value < pages.length - 1
                      ? () =>
                          controller.goToPage(controller.currentPage.value + 1)
                      : null,
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: PageView.builder(
            controller: controller.pageController,
            onPageChanged: controller.onPageChanged,
            itemCount: pages.length,
            itemBuilder: (context, pageIndex) {
              final page = pages[pageIndex];
              return _buildStepsPage(page, controller);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStepsPage(_StepsPageData page, StepsController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (page.path != null) _buildPathHeader(page.path!),
          if (page.path == null)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: primaryBlue.withOpacity(0.3), width: 2),
              ),
              child: Text(
                'Étapes du parcours',
                style: TextStyle(
                  color: primaryBlue,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 12),
              itemCount: page.steps.length,
              itemBuilder: (context, stepIndex) {
                final StepModel step = page.steps[stepIndex];

                String stepStatus =
                    (step.progress != null && step.progress!['status'] != null)
                        ? step.progress!['status'].toString().toLowerCase()
                        : (step.status ?? 'locked').toString().toLowerCase();

                final bool isCompleted = stepStatus == 'completed';
                final bool isUnlocked = stepStatus == 'unlocked' ||
                    stepStatus == 'started' ||
                    stepStatus == 'in_progress' ||
                    stepStatus == 'completed';

                final bool isActive = isUnlocked;
                final String label =
                    'Étape ${stepIndex + 1}: ${step.title ?? ''}';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ParcoursItem(
                    label: label,
                    status: isActive
                        ? (isCompleted ? 'Terminé' : 'En cours')
                        : 'Verrouillé',
                    mainColor: isActive
                        ? (isCompleted ? colorCompleted : orangeAccent)
                        : colorLocked,
                    isCompleted: isCompleted,
                    isActive: isActive,
                    icon: !isActive
                        ? Icons.lock_outline
                        : (isCompleted
                            ? Icons.check
                            : Icons.play_arrow_rounded),
                    onTap: isActive
                        ? () async {
                            final args = Get.arguments;
                            final String currentUserId =
                                (args is Map && args['userId'] != null)
                                    ? args['userId'].toString()
                                    : (controller.session?.userId.value ?? '');

                            if (currentUserId.isNotEmpty &&
                                stepStatus == 'unlocked') {
                              await StepsService.startStep(
                                userId: currentUserId,
                                stepId: step.id,
                              );
                            }

                            final res = await Get.to(
                              () => StepContentScreen(
                                stepId: step.id,
                                userId: currentUserId,
                              ),
                              transition: Transition.rightToLeft,
                            );

                            if (res == true) {
                              await controller.onRefresh();
                            }
                          }
                        : () {
                            Get.snackbar(
                              'Verrouillé',
                              'Complète les étapes précédentes pour débloquer celle-ci.',
                            );
                          },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPathHeader(LearningPathModel path) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryBlue.withOpacity(0.3), width: 2),
      ),
      child: Row(
        children: [
          Icon(Icons.route, color: primaryBlue, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              path.title,
              style: TextStyle(
                color: primaryBlue,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerEffect(Color primaryColor) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: const SizedBox(),
    );
  }
}

class _StepsPageData {
  final LearningPathModel? path;
  final List<StepModel> steps;

  _StepsPageData({required this.path, required this.steps});
}
