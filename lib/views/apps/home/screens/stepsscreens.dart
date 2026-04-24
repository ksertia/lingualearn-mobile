import 'package:fasolingo/controller/apps/etapes/etapes_controller.dart';
import 'package:fasolingo/helpers/services/etapes/etape_service.dart';
import 'package:fasolingo/helpers/services/parcoure/parcoure_service.dart';
import 'package:fasolingo/views/apps/home/StepContentScreen.dart';
import 'package:fasolingo/widgets/stepsscreens/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import 'package:fasolingo/models/parcoure/parcour_model.dart';
import '../../../../widgets/stepsscreens/parcours_item.dart';

const Color _sCompleted = Color(0xFF22C55E);
const Color _sActive    = Color(0xFFFF7043);
const Color _sLocked    = Color(0xFF9E9E9E);

void _showSubscriptionRequired(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF7043), Color(0xFFFFB74D)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0xFFFF7043).withValues(alpha: 0.35),
                  blurRadius: 18,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(Icons.workspace_premium_rounded,
                color: Colors.white, size: 36),
          ),
          const SizedBox(height: 20),
          const Text(
            'Abonnement requis',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Accédez à toutes les étapes en illimité.\nSouscrivez dès maintenant et commencez à apprendre.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.55),
              fontSize: 13,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Get.toNamed('/subscription_plans');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF7043),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text(
                'Voir les forfaits',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Plus tard',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.35),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class StepsScreensPages extends StatelessWidget {
  const StepsScreensPages({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StepsController());

    final dynamic args = Get.arguments;
    final String moduleLottie =
        (args is Map && args['moduleLottie'] != null)
            ? args['moduleLottie'].toString()
            : 'assets/lottie/Lion.json';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const CustomAppBar(title: "Mes Étapes"),
      body: Container(
        constraints: const BoxConstraints.expand(),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/app/plan2.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Obx(() {
          if (controller.isLoading.value) return _shimmer();

          if (controller.items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.97),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: _sActive.withValues(alpha: 0.10),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.flag_outlined,
                            color: _sActive, size: 42),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Aucune etape disponible',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Il n\'y a pas encore d\'etape disponible pour ce parcours.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                            height: 1.5),
                      ),
                      const SizedBox(height: 22),
                      GestureDetector(
                        onTap: controller.onRefresh,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 28, vertical: 13),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [_sActive, Color(0xFFFFB74D)],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: _sActive.withValues(alpha: 0.30),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Text(
                            'Reessayer',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          // Group items into pages (one page per path)
          final List<_PageData> pages = [];
          LearningPathModel? currentPath;
          List<StepModel> currentSteps = [];
          for (final item in controller.items) {
            if (item is LearningPathModel) {
              if (currentPath != null) {
                pages.add(_PageData(path: currentPath, steps: [...currentSteps]));
              }
              currentPath = item;
              currentSteps = [];
            } else if (item is StepModel) {
              currentSteps.add(item);
            }
          }
          if (currentPath != null) {
            pages.add(_PageData(path: currentPath, steps: [...currentSteps]));
          } else if (currentSteps.isNotEmpty) {
            pages.add(_PageData(path: null, steps: currentSteps));
          }

          return Stack(
            children: [
              RefreshIndicator(
                onRefresh: controller.onRefresh,
                color: _sActive,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height,
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).padding.top +
                              kToolbarHeight +
                              16,
                        ),
                        // Header card with lottie
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _headerCard(moduleLottie, pages),
                        ),
                        const SizedBox(height: 16),
                        // Page nav + steps
                        _pagesSection(context, pages, controller),
                        const SizedBox(height: 90),
                      ],
                    ),
                  ),
                ),
              ),
              // Sticky "Terminé" button
              Positioned(
                left: 0, right: 0, bottom: 0,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Obx(() {
                      if (pages.isEmpty) return const SizedBox.shrink();
                      final pageIdx = controller.currentPage.value
                          .clamp(0, pages.length - 1);
                      final page = pages[pageIdx];
                      if (page.path == null) return const SizedBox.shrink();

                      final allDone = page.steps.isNotEmpty &&
                          page.steps.every((s) {
                            final st = (s.progress != null &&
                                    s.progress!['status'] != null)
                                ? s.progress!['status'].toString().toLowerCase()
                                : (s.status ?? 'locked').toLowerCase();
                            return st == 'completed';
                          });
                      if (!allDone) return const SizedBox.shrink();

                      final a = Get.arguments;
                      final userId = (a is Map && a['userId'] != null)
                          ? a['userId'].toString()
                          : '';

                      return Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [_sActive, Color(0xFFFFB74D)]),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: _sActive.withValues(alpha: 0.40),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: userId.isEmpty
                              ? null
                              : () async {
                                  final ok =
                                      await LearningPathService.completePath(
                                    userId: userId,
                                    pathId: page.path!.id,
                                  );
                                  if (ok) Get.back(result: true);
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            minimumSize: const Size(double.infinity, 52),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_rounded,
                                  color: Colors.white, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Parcours terminé !',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
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

  Widget _headerCard(String lottie, List<_PageData> pages) {
    final totalSteps =
        pages.fold<int>(0, (sum, p) => sum + p.steps.length);
    final doneSteps = pages.fold<int>(0, (sum, p) {
      return sum +
          p.steps.where((s) {
            final st = (s.progress != null && s.progress!['status'] != null)
                ? s.progress!['status'].toString().toLowerCase()
                : (s.status ?? 'locked').toLowerCase();
            return st == 'completed';
          }).length;
    });
    final pct = totalSteps > 0 ? doneSteps / totalSteps : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.93),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
            color: _sActive.withValues(alpha: 0.20), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _sActive.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Lottie.asset(lottie, fit: BoxFit.contain),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mon chemin',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation(_sActive),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '$doneSteps / $totalSteps étapes',
                  style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pagesSection(BuildContext context, List<_PageData> pages,
      StepsController controller) {
    if (pages.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        if (pages.length > 1)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Obx(() => Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _navBtn(
                        Icons.arrow_back_ios_new,
                        controller.currentPage.value > 0,
                        () => controller
                            .goToPage(controller.currentPage.value - 1),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Parcours ${controller.currentPage.value + 1} / ${pages.length}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _navBtn(
                        Icons.arrow_forward_ios,
                        controller.currentPage.value < pages.length - 1,
                        () => controller
                            .goToPage(controller.currentPage.value + 1),
                      ),
                    ],
                  ),
                )),
          ),
        const SizedBox(height: 8),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.72,
          child: PageView.builder(
            controller: controller.pageController,
            onPageChanged: controller.onPageChanged,
            itemCount: pages.length,
            itemBuilder: (_, i) => _stepsPage(pages[i], controller),
          ),
        ),
      ],
    );
  }

  Widget _navBtn(IconData icon, bool enabled, VoidCallback onTap) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: enabled
              ? _sActive.withValues(alpha: 0.12)
              : Colors.grey.withValues(alpha: 0.10),
          shape: BoxShape.circle,
        ),
        child: Icon(icon,
            size: 16,
            color: enabled ? _sActive : Colors.grey.shade400),
      ),
    );
  }

  Widget _stepsPage(_PageData page, StepsController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (page.path != null) _pathHeader(page.path!),
          if (page.path == null) _fallbackHeader(),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 4, bottom: 16),
              itemCount: page.steps.length,
              itemBuilder: (context, i) {
                final step = page.steps[i];
                final stepStatus = (step.progress != null &&
                        step.progress!['status'] != null)
                    ? step.progress!['status'].toString().toLowerCase()
                    : (step.status ?? 'locked').toLowerCase();
                final isCompleted = stepStatus == 'completed';
                final isActive = stepStatus == 'unlocked' ||
                    stepStatus == 'started' ||
                    stepStatus == 'in_progress' ||
                    isCompleted;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ParcoursItem(
                    label: 'Etape ${i + 1} : ${step.title}',
                    status: isCompleted
                        ? 'Terminé'
                        : (isActive ? 'En cours' : 'Verrouillé'),
                    mainColor: isActive
                        ? (isCompleted ? _sCompleted : _sActive)
                        : _sLocked,
                    isCompleted: isCompleted,
                    isActive: isActive,
                    icon: !isActive
                        ? Icons.lock_rounded
                        : (isCompleted
                            ? Icons.check_rounded
                            : Icons.play_arrow_rounded),
                    onTap: isActive
                        ? () async {
                            if (!controller.isSubscriptionActive.value) {
                              _showSubscriptionRequired(context);
                              return;
                            }
                            final a = Get.arguments;
                            final userId = (a is Map && a['userId'] != null)
                                ? a['userId'].toString()
                                : (controller.session?.userId.value ?? '');
                            if (userId.isNotEmpty && stepStatus == 'unlocked') {
                              await StepsService.startStep(
                                  userId: userId, stepId: step.id);
                            }
                            final res = await Get.to(
                              () => StepContentScreen(
                                  stepId: step.id, userId: userId),
                              transition: Transition.rightToLeft,
                            );
                            if (res == true) await controller.onRefresh();
                          }
                        : () => Get.snackbar(
                              'Étape verrouillée 🔒',
                              'Complète les étapes précédentes pour débloquer celle-ci.',
                              backgroundColor: Colors.black87,
                              colorText: Colors.white,
                              snackPosition: SnackPosition.BOTTOM,
                              margin: const EdgeInsets.all(16),
                              borderRadius: 16,
                            ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _pathHeader(LearningPathModel path) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: _sActive.withValues(alpha: 0.22), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _sActive.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child:
                const Icon(Icons.route_rounded, color: _sActive, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              path.title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallbackHeader() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Text('Étapes du parcours',
          style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A1A))),
    );
  }

  Widget _shimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 100, 16, 20),
        itemCount: 5,
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
      ),
    );
  }
}

class _PageData {
  final LearningPathModel? path;
  final List<StepModel> steps;
  _PageData({required this.path, required this.steps});
}
