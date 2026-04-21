
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import 'package:fasolingo/controller/apps/moduls/home_controller.dart';
import 'package:fasolingo/helpers/services/module_service.dart';
import 'package:fasolingo/models/modules/modul_model.dart';

const Color colorProBlue = Color(0xFF00008B);
const Color primaryBlue = Color(0xFF00CED1);
const Color colorCompleted = Color(0xFF81C784);
const Color orangeAccent = Color(0xFFFF9800);
const Color colorLocked = Color(0xFF9E9E9E);

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  final Map<int, String> moduleAnimals = const {
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

  String _getAnimal(int index) =>
      moduleAnimals[index % moduleAnimals.length] ?? 'assets/lottie/Lion.json';

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.put(HomeController());

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.orangeAccent,
        foregroundColor: Colors.black87,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Liste des modules',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Choisis le prochain défi',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/app/plan1.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 20, 25, 10),
              child: Text(
                'Les modules',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: colorProBlue,
                ),
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return _buildShimmerLoading();
                }

                if (controller.filteredModules.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.info_outline,
                            size: 50, color: Colors.grey),
                        const SizedBox(height: 10),
                        const Text("Aucun module trouvé."),
                        const SizedBox(height: 15),
                        ElevatedButton(
                            onPressed: () => controller.loadModules(),
                            child: const Text("Réessayer"))
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => controller.onRefresh(),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(25, 35, 25, 40),
                    itemCount: controller.filteredModules.length,
                    itemBuilder: (context, index) {
                      final module = controller.filteredModules[index];
                      bool isLast =
                          index == controller.filteredModules.length - 1;

                      final String moduleStatus =
                          (controller.moduleDisplayStatus[module.id] ?? 'locked')
                              .toLowerCase();

                      bool isCompleted = moduleStatus == "completed";
                      bool isUnlocked = moduleStatus == "unlocked" ||
                          moduleStatus == "started" ||
                          moduleStatus == "completed";
                      bool isLocked = moduleStatus == "locked";

                      return IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                _buildTimelineIcon(moduleStatus),
                                if (!isLast)
                                  Expanded(
                                    child: Container(
                                      width: 6,
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isUnlocked
                                            ? (isCompleted
                                                    ? primaryBlue
                                                    : orangeAccent)
                                                .withOpacity(0.3)
                                            : colorLocked.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 40),
                                child: _buildKidCard(
                                    controller, module, moduleStatus, index),
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
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineIcon(String moduleStatus) {
    IconData iconData = Icons.lock_rounded;
    Color iconColor = colorLocked;

    if (moduleStatus == "completed") {
      iconData = Icons.check_circle_rounded;
      iconColor = colorCompleted;
    } else if (moduleStatus == "unlocked") {
      iconData = Icons.play_circle_filled_rounded;
      iconColor = orangeAccent;
    }

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          if (moduleStatus != "locked")
            BoxShadow(
                color: iconColor.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5))
        ],
      ),
      child: Icon(iconData, color: iconColor, size: 42),
    );
  }

  Widget _buildKidCard(HomeController controller, ModuleModel module,
      String moduleStatus, int index) {
    final String status = moduleStatus.toLowerCase();

    Color mainColor;
    if (status == "completed") {
      mainColor = colorCompleted;
    } else if (status == "unlocked" ||
        status == "started" ||
        status == "en cours") {
      mainColor = orangeAccent;
    } else {
      mainColor = colorLocked;
    }

    bool isUnlocked = status == "unlocked" ||
        status == "started" ||
        status == "completed" ||
        status == "en cours";

    return GestureDetector(
      onTap: !isUnlocked
          ? () => Get.snackbar("Oups ! 🔒",
              "Termine le module précédent pour débloquer celui-ci.")
          : () async {
              final userId = controller.session.userId.value.isNotEmpty
                  ? controller.session.userId.value
                  : (controller.session.user?.id ?? '');

              if (userId.isNotEmpty && status == 'unlocked') {
                await ModuleService.startModule(userId: userId, moduleId: module.id);
              }

              final res = await Get.toNamed('/parcoursselectionpage',
                  arguments: {
                    'moduleId': module.id,
                    'userId': userId,
                    'moduleLottie': _getAnimal(index),
                  });
              if (res == true || res == 'completed' || res == 'finished') {
                controller.onModuleCompleted(module.id);
              }
            },
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: mainColor.withOpacity(0.5), width: 2.5),
          boxShadow: [
            BoxShadow(
              color: mainColor.withOpacity(0.15),
              offset: const Offset(0, 10),
              blurRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 80),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              status == "completed"
                                  ? "BIEN JOUÉ !"
                                  : isUnlocked
                                      ? "EN COURS"
                                      : "À DÉBLOQUER",
                              style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  color: mainColor,
                                  letterSpacing: 1),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              module.title.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                  color:
                                      isUnlocked ? colorProBlue : colorLocked),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              isUnlocked
                                  ? module.description
                                  : "Continue pour découvrir...",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Positioned(
                right: 8,
                bottom: 10,
                child: Container(
                  width: 110,
                  alignment: Alignment.bottomCenter,
                  child: Opacity(
                    opacity: isUnlocked ? 1.0 : 0.2,
                    child: ColorFiltered(
                      colorFilter: isUnlocked
                          ? const ColorFilter.mode(
                              Colors.transparent, BlendMode.multiply)
                          : const ColorFilter.mode(
                              Colors.grey, BlendMode.srcIn),
                      child: Lottie.asset(
                        _getAnimal(index),
                        height: 90,
                        animate: isUnlocked,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),

              if (!isUnlocked)
                Positioned(
                  right: 35,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.lock_rounded,
                          color: Colors.grey, size: 22),
                    ),
                  ),
                ),

              if (status == "unlocked" || status == "en cours")
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                        color: Colors.white.withAlpha(200),
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 4)
                        ]),
                    child: Icon(Icons.play_circle_fill,
                        color: mainColor, size: 35),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(25, 35, 25, 40),
      itemCount: 5,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 40),
          child: Row(
            children: [
              const CircleAvatar(radius: 20, backgroundColor: Colors.white),
              const SizedBox(width: 20),
              Expanded(
                  child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25)))),
            ],
          ),
        ),
      ),
    );
  }
}
