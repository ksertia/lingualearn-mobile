import 'package:fasolingo/controller/apps/parcoure/parcoure_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:lottie/lottie.dart';
import 'package:fasolingo/helpers/services/module_service.dart';
import 'package:fasolingo/helpers/services/parcoure/parcoure_service.dart';
import 'package:fasolingo/models/modules/modul_model.dart';
import 'package:fasolingo/models/parcoure/parcour_model.dart';
import '../../../../widgets/parcourspage/ParcoursStepItem.dart';
import '../../../../widgets/stepsscreens/custom_app_bar.dart';

const Color _pCompleted = Color(0xFF22C55E);
const Color _pActive    = Color(0xFFFF7043);
const Color _pLocked    = Color(0xFF9E9E9E);

class ParcoursSelectionPage extends StatelessWidget {
  const ParcoursSelectionPage({super.key});

  static const List<String> _lotties = [
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

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ParcoursSelectionController());

    final dynamic args = Get.arguments;
    final String backgroundImage =
        (args is Map && args['backgroundImage'] != null)
            ? args['backgroundImage'].toString()
            : 'assets/images/app/plan3.png';

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: const CustomAppBar(title: 'Mes Parcours'),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(backgroundImage),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
                Colors.black.withValues(alpha: 0.18), BlendMode.darken),
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
                          color: _pActive.withValues(alpha: 0.10),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.map_outlined,
                            color: _pActive, size: 42),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Aucun parcours disponible',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Il n\'y a pas encore de parcours disponible.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                            height: 1.5),
                      ),
                      const SizedBox(height: 22),
                      GestureDetector(
                        onTap: controller.fetchPaths,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 28, vertical: 13),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [_pActive, Color(0xFFFFB74D)],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: _pActive.withValues(alpha: 0.30),
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

          // Grouper les items par module → une page par module
          final List<_PageData> pages = [];
          ModuleModel? currentModule;
          List<LearningPathModel> currentPaths = [];
          int moduleIdx = 0;

          for (final item in controller.items) {
            if (item is ModuleModel) {
              if (currentModule != null || currentPaths.isNotEmpty) {
                pages.add(_PageData(
                  module: currentModule,
                  paths: List.from(currentPaths),
                  lottie: _lotties[(moduleIdx - 1).clamp(0, _lotties.length - 1)],
                ));
              }
              currentModule = item;
              currentPaths = [];
              moduleIdx++;
            } else if (item is LearningPathModel) {
              currentPaths.add(item);
            }
          }
          // Dernier groupe
          if (currentModule != null || currentPaths.isNotEmpty) {
            pages.add(_PageData(
              module: currentModule,
              paths: List.from(currentPaths),
              lottie: _lotties[moduleIdx > 0 ? (moduleIdx - 1) % _lotties.length : 0],
            ));
          }

          if (pages.isEmpty) return const SizedBox.shrink();

          return RefreshIndicator(
            onRefresh: controller.fetchPaths,
            color: _pActive,
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
                    // Header global : progression totale
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _headerCard(pages),
                    ),
                    const SizedBox(height: 16),
                    // Navigation par pages + PageView
                    _pagesSection(context, pages, controller),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ─── Header global ──────────────────────────────────────────────────────────

  Widget _headerCard(List<_PageData> pages) {
    final totalPaths =
        pages.fold<int>(0, (s, p) => s + p.paths.length);
    final donePaths = pages.fold<int>(0, (s, p) {
      return s +
          p.paths.where((path) {
            final st =
                (path.progress?['status'] ?? path.status ?? 'locked')
                    .toString()
                    .toLowerCase();
            return st == 'completed';
          }).length;
    });
    final pct = totalPaths > 0 ? donePaths / totalPaths : 0.0;
    final lottie = pages.isNotEmpty ? pages[0].lottie : _lotties[0];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.93),
        borderRadius: BorderRadius.circular(24),
        border:
            Border.all(color: _pActive.withValues(alpha: 0.20), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mes parcours',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 7,
                    backgroundColor: Colors.grey.shade200,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(_pActive),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _pActive.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${(pct * 100).toInt()}%',
                        style: const TextStyle(
                          color: _pActive,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$donePaths / $totalPaths parcours',
                      style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _pActive.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Lottie.asset(lottie, fit: BoxFit.contain, repeat: true),
          ),
        ],
      ),
    );
  }

  // ─── Section paginée ────────────────────────────────────────────────────────

  Widget _pagesSection(BuildContext context, List<_PageData> pages,
      ParcoursSelectionController controller) {
    if (pages.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        if (pages.length > 1)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Obx(() => Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
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
                        'Module ${controller.currentPage.value + 1} / ${pages.length}',
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
            itemBuilder: (_, i) => _pathsPage(pages[i], controller),
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
              ? _pActive.withValues(alpha: 0.12)
              : Colors.grey.withValues(alpha: 0.10),
          shape: BoxShape.circle,
        ),
        child: Icon(icon,
            size: 16,
            color: enabled ? _pActive : Colors.grey.shade400),
      ),
    );
  }

  // ─── Page d'un module ───────────────────────────────────────────────────────

  Widget _pathsPage(
      _PageData page, ParcoursSelectionController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (page.module != null) _moduleHeader(page.module!, page.lottie),
          if (page.module == null) _fallbackHeader(),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 4, bottom: 16),
              itemCount: page.paths.length,
              itemBuilder: (context, i) {
                final path = page.paths[i];
                final pathStatus =
                    (path.progress != null && path.progress!['status'] != null)
                        ? path.progress!['status'].toString().toLowerCase()
                        : (path.status ?? 'locked').toLowerCase();
                final isCompleted = pathStatus == 'completed';
                final isActive = pathStatus == 'unlocked' ||
                    pathStatus == 'started' ||
                    pathStatus == 'in_progress' ||
                    isCompleted;

                return Align(
                  alignment: i % 2 == 0
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: 0.92,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: ParcoursStepItem(
                        number: '${i + 1}',
                        title: path.title,
                        statusText: isCompleted
                            ? 'Terminé'
                            : (isActive ? 'En cours' : 'Verrouillé'),
                        subtitle: isActive
                            ? path.description
                            : 'Terminez le parcours précédent',
                        color: isActive
                            ? (isCompleted ? _pCompleted : _pActive)
                            : _pLocked,
                        isCompleted: isCompleted,
                        isActive: isActive,
                        icon: !isActive
                            ? Icons.lock_rounded
                            : (isCompleted
                                ? Icons.check_rounded
                                : Icons.play_arrow_rounded),
                        onTap: isActive
                            ? () async {
                                final a = Get.arguments;
                                final userId =
                                    (a is Map && a['userId'] != null)
                                        ? a['userId'].toString()
                                        : '';
                                if (userId.isNotEmpty &&
                                    pathStatus == 'unlocked') {
                                  await LearningPathService.startPath(
                                    userId: userId,
                                    pathId: path.id,
                                  );
                                }
                                final res = await Get.toNamed(
                                  '/stepsscreens',
                                  arguments: {
                                    'moduleId': path.moduleId,
                                    'pathId': path.id,
                                    'userId': userId,
                                    'moduleLottie': page.lottie,
                                  },
                                );
                                if (res == true ||
                                    res == 'completed' ||
                                    res == 'finished') {
                                  await controller.fetchPaths();
                                  final allPaths = controller.items
                                      .whereType<LearningPathModel>()
                                      .where((p) =>
                                          p.moduleId == path.moduleId)
                                      .toList();
                                  final allDone = allPaths.isNotEmpty &&
                                      allPaths.every((p) {
                                        final st = (p.progress != null &&
                                                p.progress!['status'] != null)
                                            ? p.progress!['status']
                                                .toString()
                                                .toLowerCase()
                                            : (p.status ?? 'locked')
                                                .toLowerCase();
                                        return st == 'completed';
                                      });
                                  if (userId.isNotEmpty &&
                                      path.moduleId.isNotEmpty &&
                                      allDone) {
                                    await ModuleService.completeModule(
                                      userId: userId,
                                      moduleId: path.moduleId,
                                    );
                                  }
                                  Get.back(result: true);
                                }
                              }
                            : () => Get.snackbar(
                                  'Parcours Verrouillé 🔒',
                                  'Terminez le parcours précédent pour débloquer celui-ci.',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.black87,
                                  colorText: Colors.white,
                                  margin: const EdgeInsets.all(15),
                                  borderRadius: 16,
                                ),
                      ),
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

  Widget _moduleHeader(ModuleModel module, String lottie) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
        border:
            Border.all(color: _pActive.withValues(alpha: 0.22), width: 1.5),
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
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _pActive.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Lottie.asset(lottie, fit: BoxFit.contain),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              module.title,
              style: const TextStyle(
                fontSize: 16,
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
      child: const Text(
        'Parcours disponibles',
        style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A1A1A)),
      ),
    );
  }

  // ─── Shimmer ────────────────────────────────────────────────────────────────

  Widget _shimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 100, 16, 20),
        itemCount: 5,
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Row(
            children: [
              const CircleAvatar(radius: 24, backgroundColor: Colors.white),
              const SizedBox(width: 14),
              Expanded(
                child: Container(
                  height: 88,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Modèle de page ───────────────────────────────────────────────────────────

class _PageData {
  final ModuleModel? module;
  final List<LearningPathModel> paths;
  final String lottie;

  _PageData({
    required this.module,
    required this.paths,
    required this.lottie,
  });
}
