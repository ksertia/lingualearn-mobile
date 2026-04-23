import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import 'package:fasolingo/controller/apps/moduls/home_controller.dart';
import 'package:fasolingo/helpers/services/module_service.dart';
import 'package:fasolingo/models/modules/modul_model.dart';

// kept for backward compat (parcours.dart imports primaryBlue from here)
const Color colorProBlue = Color(0xFF00008B);
const Color primaryBlue = Color(0xFF00CED1);

const Color _kCompleted = Color(0xFF22C55E);
const Color _kActive = Color(0xFFFF7043);
const Color _kLocked = Color(0xFF9E9E9E);

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const Map<int, String> _animals = {
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

  String _animal(int i) =>
      _animals[i % _animals.length] ?? 'assets/lottie/Lion.json';

  Color _accent(String s) {
    if (s == 'completed') return _kCompleted;
    if (s == 'unlocked') return _kActive;
    return _kLocked;
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _appBar(),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/app/plan1.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Obx(() {
          if (controller.isLoading.value) return _shimmer();

          if (controller.filteredModules.isEmpty) {
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
                          color: _kActive.withValues(alpha: 0.10),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.menu_book_outlined,
                            color: _kActive, size: 42),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Aucun module disponible',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Il n\'y a pas encore de module disponible pour cette langue et ce niveau.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                            height: 1.5),
                      ),
                      const SizedBox(height: 22),
                      GestureDetector(
                        onTap: controller.loadModules,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 28, vertical: 13),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [_kActive, Color(0xFFFFB74D)],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: _kActive.withValues(alpha: 0.30),
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

          return RefreshIndicator(
            onRefresh: controller.onRefresh,
            color: _kActive,
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(
                20,
                MediaQuery.of(context).padding.top + kToolbarHeight + 18,
                20,
                40,
              ),
              itemCount: controller.filteredModules.length,
              itemBuilder: (_, index) {
                final module = controller.filteredModules[index];
                final bool isLast =
                    index == controller.filteredModules.length - 1;
                final String st =
                    (controller.moduleDisplayStatus[module.id] ?? 'locked')
                        .toLowerCase();
                final bool isUnlocked =
                    st == 'unlocked' || st == 'started' || st == 'completed';
                final accent = _accent(st);

                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 44,
                        child: Column(
                          children: [
                            _timelineNode(st, accent),
                            if (!isLast)
                              Expanded(
                                child: Center(
                                  child: Container(
                                    width: 3,
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          accent.withValues(alpha: 0.55),
                                          accent.withValues(alpha: 0.08),
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: _moduleCard(controller, module, st, isUnlocked,
                              accent, index),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }

  PreferredSizeWidget _appBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFF7043), Color(0xFFFFB74D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      leading: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: GestureDetector(
          onTap: Get.back,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white, size: 17),
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Mes Modules',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 18)),
          Text('Choisis ton prochain défi',
              style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _timelineNode(String status, Color accent) {
    IconData icon;
    if (status == 'completed') {
      icon = Icons.check_circle_rounded;
    } else if (status == 'unlocked') {
      icon = Icons.play_circle_filled_rounded;
    } else {
      icon = Icons.lock_rounded;
    }
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          if (status != 'locked')
            BoxShadow(
              color: accent.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Icon(icon, color: accent, size: 44),
    );
  }

  Widget _moduleCard(
    HomeController controller,
    ModuleModel module,
    String st,
    bool isUnlocked,
    Color accent,
    int index,
  ) {
    return GestureDetector(
      onTap: !isUnlocked
          ? () => Get.snackbar(
                'Oups ! 🔒',
                'Termine le module précédent pour débloquer celui-ci.',
                backgroundColor: Colors.black87,
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
                margin: const EdgeInsets.all(16),
                borderRadius: 16,
              )
          : () async {
              final userId = controller.session.userId.value.isNotEmpty
                  ? controller.session.userId.value
                  : (controller.session.user?.id ?? '');
              final raw = (module.progress?.status ?? module.status ?? '')
                  .toLowerCase();
              if (userId.isNotEmpty && raw == 'unlocked') {
                await ModuleService.startModule(
                    userId: userId, moduleId: module.id);
              }
              await Get.toNamed('/parcoursselectionpage', arguments: {
                'moduleId': module.id,
                'userId': userId,
                'moduleLottie': _animal(index),
              });
              await controller.loadModules();
            },
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.93),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: accent.withValues(alpha: 0.25), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.15),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(21),
          child: Stack(
            children: [
              // Left accent strip
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(width: 5, color: accent),
              ),
              // Text content
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 12, 98, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text(
                          st == 'completed'
                              ? 'TERMINÉ'
                              : isUnlocked
                                  ? 'EN COURS'
                                  : 'VERROUILLÉ',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: accent,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        module.title.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: isUnlocked
                              ? const Color(0xFF1A1A1A)
                              : Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isUnlocked
                            ? module.description
                            : 'Continue pour découvrir...',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                            height: 1.3),
                      ),
                    ],
                  ),
                ),
              ),
              // Lottie
              Positioned(
                right: 6,
                bottom: 6,
                top: 0,
                child: SizedBox(
                  width: 88,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Opacity(
                      opacity: isUnlocked ? 1.0 : 0.15,
                      child: ColorFiltered(
                        colorFilter: isUnlocked
                            ? const ColorFilter.mode(
                                Colors.transparent, BlendMode.multiply)
                            : const ColorFilter.mode(
                                Colors.grey, BlendMode.srcIn),
                        child: Lottie.asset(
                          _animal(index),
                          height: 86,
                          animate: isUnlocked,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Lock icon overlay
              if (!isUnlocked)
                Positioned(
                  right: 30,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: const BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.lock_rounded,
                          color: Colors.grey, size: 18),
                    ),
                  ),
                ),
              // Play button for unlocked
              if (st == 'unlocked')
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 4)
                      ],
                    ),
                    child:
                        Icon(Icons.play_circle_fill, color: accent, size: 32),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _shimmer() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 120, 20, 40),
      itemCount: 5,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Row(
            children: [
              const CircleAvatar(radius: 22, backgroundColor: Colors.white),
              const SizedBox(width: 14),
              Expanded(
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
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
