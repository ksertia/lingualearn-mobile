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
    final String? moduleLottieArg =
        (args is Map && args['moduleLottie'] != null)
            ? args['moduleLottie'].toString()
            : null;
    final String backgroundImage =
        (args is Map && args['backgroundImage'] != null)
            ? args['backgroundImage'].toString()
            : 'assets/images/app/plan3.png';

    final Future<List<ModuleModel>> modulesFuture =
        ModuleService.getAllModules();

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: const CustomAppBar(title: 'Mes Parcours'),
      body: Obx(() {
        if (controller.isLoading.value) return _shimmer();

        if (controller.items.isEmpty) {
          return Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(backgroundImage),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                    Colors.black.withValues(alpha: 0.18), BlendMode.darken),
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.map_outlined,
                        size: 40, color: Colors.grey.shade400),
                  ),
                  const SizedBox(height: 14),
                  const Text('Aucun parcours disponible.',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: controller.fetchPaths,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _pActive,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
          );
        }

        return FutureBuilder<List<ModuleModel>>(
          future: modulesFuture,
          builder: (context, snap) {
            final String lottie = moduleLottieArg ??
                (snap.hasData
                    ? _resolveLottie(snap.data!, controller.moduleId)
                    : 'assets/lottie/Lion.json');

            return Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(backgroundImage),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                      Colors.black.withValues(alpha: 0.18), BlendMode.darken),
                ),
              ),
              child: RefreshIndicator(
                onRefresh: controller.fetchPaths,
                color: _pActive,
                child: ListView.builder(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    MediaQuery.of(context).padding.top + kToolbarHeight + 16,
                    16,
                    32,
                  ),
                  itemCount: controller.items.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      String title = controller.showAllPaths
                          ? 'Mes parcours'
                          : 'MODULE';
                      String description = controller.showAllPaths
                          ? 'Parcours adaptés à ta langue et ton niveau'
                          : '';
                      if (!controller.showAllPaths &&
                          snap.hasData &&
                          snap.data!.isNotEmpty) {
                        final found = snap.data!
                            .where((m) => m.id == controller.moduleId)
                            .toList();
                        if (found.isNotEmpty) {
                          title = found.first.title;
                          description = found.first.description;
                        }
                      }
                      final paths = controller.items
                          .whereType<LearningPathModel>()
                          .toList();
                      final total = paths.length;
                      final completed = paths
                          .where((p) =>
                              (p.status ?? '').toLowerCase() == 'completed')
                          .length;
                      final progress =
                          total > 0 ? completed / total : 0.0;
                      return _headerCard(title, description,
                          progress, completed, total, lottie);
                    }

                    final item = controller.items[index - 1];
                    if (item is ModuleModel) return _moduleHeader(item);
                    if (item is LearningPathModel) {
                      final path = item;
                      final pathStatus = (path.progress != null &&
                              path.progress!['status'] != null)
                          ? path.progress!['status'].toString().toLowerCase()
                          : (path.status ?? 'locked').toLowerCase();
                      final isCompleted = pathStatus == 'completed';
                      final isActive = pathStatus == 'unlocked' ||
                          pathStatus == 'started' ||
                          pathStatus == 'in_progress' ||
                          isCompleted;
                      final pathList = controller.items
                          .whereType<LearningPathModel>()
                          .toList();
                      final pathIndex = pathList.indexOf(path);

                      return Align(
                        alignment: pathIndex % 2 == 0
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: 0.92,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: ParcoursStepItem(
                              number: '${pathIndex + 1}',
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
                                      final userId = (a is Map &&
                                              a['userId'] != null)
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
                                          'moduleLottie': lottie,
                                        },
                                      );
                                      if (res == true ||
                                          res == 'completed' ||
                                          res == 'finished') {
                                        await controller.fetchPaths();
                                        final ps = controller.items
                                            .whereType<LearningPathModel>()
                                            .toList();
                                        final tot = ps.length;
                                        final comp = ps.where((p) {
                                          final st = (p.progress != null &&
                                                  p.progress!['status'] != null)
                                              ? p.progress!['status']
                                                  .toString()
                                                  .toLowerCase()
                                              : (p.status ?? 'locked')
                                                  .toLowerCase();
                                          return st == 'completed';
                                        }).length;
                                        if (userId.isNotEmpty &&
                                            controller.moduleId.isNotEmpty &&
                                            tot > 0 &&
                                            comp == tot) {
                                          await ModuleService.completeModule(
                                            userId: userId,
                                            moduleId: controller.moduleId,
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
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            );
          },
        );
      }),
    );
  }

  String _resolveLottie(List<ModuleModel> modules, String moduleId) {
    try {
      final pos = modules.indexWhere((m) => m.id == moduleId);
      if (pos != -1) return _lotties[pos % _lotties.length];
    } catch (_) {}
    return 'assets/lottie/Lion.json';
  }

  Widget _headerCard(String title, String description, double progress,
      int completed, int total, String lottie) {
    final percent = (progress * 100).clamp(0, 100).toInt();

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.93),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: _pActive.withValues(alpha: 0.20), width: 1.5),
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
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Colors.grey.shade500, fontSize: 13),
                  ),
                ],
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
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
                        '$percent%',
                        style: const TextStyle(
                          color: _pActive,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$completed / $total parcours',
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

  Widget _moduleHeader(ModuleModel module) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
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
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _pActive.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.menu_book_rounded,
                color: _pActive, size: 22),
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
              const CircleAvatar(
                  radius: 24, backgroundColor: Colors.white),
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
