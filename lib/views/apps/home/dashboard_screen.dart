import 'package:fasolingo/controller/apps/langue/langue_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import 'package:fasolingo/controller/apps/moduls/home_controller.dart';
import 'package:fasolingo/controller/apps/session_controller.dart';
import 'package:fasolingo/helpers/storage/local_storage.dart';
import 'package:fasolingo/models/modules/modul_model.dart';
import 'package:fasolingo/models/langue/langue_model.dart';

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
    final SessionController session = Get.find<SessionController>();
    final LanguagesController langController = Get.put(LanguagesController());

    String firstName = LocalStorage.getUserName() ?? "Champion";
    String greeting = "Salut";

    String langueId = session.selectedLanguageId.value.isNotEmpty
        ? session.selectedLanguageId.value
        : (session.user?.selectedLanguageId ?? "");

    final LanguageModel? selectedLang =
        langController.allLanguages.firstWhereOrNull((l) => l.id == langueId);
    String langueNom = selectedLang?.name ?? "ta langue";

    if (langueNom.toLowerCase().contains("mooré")) {
      greeting = "Ne y windiga";
    } else if (langueNom.toLowerCase().contains("dioula")) {
      greeting = "I ni sogoma";
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                const Color(0xFFF8FBFF),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: colorProBlue.withOpacity(0.08),
                offset: const Offset(0, 2),
                blurRadius: 12,
                spreadRadius: 0,
              ),
            ],
          ),
          child: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            toolbarHeight: 70,
            leadingWidth: 0,
            leading: const SizedBox.shrink(),
            title: Row(
              children: [
                Lottie.asset(
                  'assets/lottie/Happy mascot.json',
                  width: 60,
                  height: 60,
                  repeat: true,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'TiBi',
                        style: TextStyle(
                          color: colorProBlue,
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        'Apprendre • Progresser • Réussir',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: primaryBlue.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.stars_rounded,
                            color: primaryBlue,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            '1250',
                            style: TextStyle(
                              color: primaryBlue,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => _showSettingsBottomSheet(
                          context, firstName, langueNom),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: colorProBlue.withOpacity(0.2),
                              offset: const Offset(0, 2),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: colorProBlue,
                          child: Text(
                            firstName.isNotEmpty
                                ? firstName[0].toUpperCase()
                                : "U",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 15),
            ],
          ),
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
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                      color: colorProBlue.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10)),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(25, 10, 25, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$greeting, $firstName ! 🇧🇫",
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2D3436)),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Prêt pour ton aventure en $langueNom ?",
                    style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 15),
                ],
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

                      debugPrint("=== MODULE $index ===");
                      debugPrint("ID: ${module.id}");
                      debugPrint("Title: ${module.title}");
                      debugPrint("Description: ${module.description}");
                      debugPrint("Status: ${module.status}");
                      debugPrint("Progress: ${module.progressPercentage}%");
                      debugPrint("Index: ${module.index}");
                      debugPrint("IsActive: ${module.isActive}");
                      if (module.progress != null) {
                        debugPrint(
                            "Progress Object - Status: ${module.progress!.status}");
                        debugPrint(
                            "Progress Object - Percentage: ${module.progress!.progressPercentage}");
                        debugPrint(
                            "Progress Object - CompletedAt: ${module.progress!.completedAt}");
                        debugPrint(
                            "Progress Object - UnlockedAt: ${module.progress!.unlockedAt}");
                      } else {
                        debugPrint("Progress Object: null");
                      }
                      debugPrint("==================");

                      String moduleStatus = module.status ?? "locked";

                      if (moduleStatus == "locked" && index == 0) {
                        bool allModulesLocked = controller.filteredModules
                            .every((m) => (m.status ?? "locked") == "locked");
                        if (allModulesLocked) {
                          moduleStatus = "unlocked";
                          print(
                              " [FALLBACK] Premier module débloqué automatiquement (tous les statuts sont null)");
                        }
                      }

                      bool isCompleted = moduleStatus == "completed";
                      bool isUnlocked = moduleStatus == "unlocked" ||
                          moduleStatus == "completed";
                      bool isLocked = moduleStatus == "locked";

                      print(
                          "Module ${index + 1}: Status='$moduleStatus' → isCompleted=$isCompleted, isUnlocked=$isUnlocked");

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
    // 1. GESTION DES COULEURS (Fix pour éviter le rouge si débloqué)
    // On force le statut en minuscule pour éviter les erreurs de casse ("Completed" vs "completed")
    final String status = moduleStatus.toLowerCase();

    Color mainColor;
    if (status == "completed") {
      mainColor = colorCompleted;
    } else if (status == "unlocked" || status == "en cours") {
      mainColor = orangeAccent;
    } else {
      mainColor =
          colorLocked; // C'est ici que ton rouge arrive si le statut est inconnu
    }

    bool isUnlocked =
        status == "unlocked" || status == "completed" || status == "en cours";

    return GestureDetector(
      onTap: !isUnlocked
          ? () => Get.snackbar("Oups ! 🔒",
              "Termine le module précédent pour débloquer celui-ci.")
          : () async {
              final res = await Get.toNamed('/parcoursselectionpage',
                  arguments: module.id);
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
              // --- 2. LE CONTENU TEXTE (texte à gauche, Lottie positionné à droite) ---
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        // on réserve de l'espace à droite pour le Lottie (évite chevauchement)
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

              // Lottie positionné à droite, collé vers le bord du container
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

              // --- ICONES DE STATUT (Cadenas ou Play) ---
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

  void _showSettingsBottomSheet(
      BuildContext context, String firstName, String langueNom) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(25),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: colorProBlue,
                      child: Text(
                        firstName.isNotEmpty ? firstName[0].toUpperCase() : "U",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            firstName,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: colorProBlue,
                            ),
                          ),
                          Text(
                            "Apprenant en $langueNom",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  children: [
                    _buildSettingsItem(
                      icon: Icons.language_outlined,
                      title: "Langue d'apprentissage",
                      subtitle: langueNom,
                      onTap: () {},
                    ),
                    _buildSettingsItem(
                      icon: Icons.notifications_outlined,
                      title: "Notifications",
                      subtitle: "Gérer les rappels",
                      onTap: () {},
                    ),
                    _buildSettingsItem(
                      icon: Icons.bar_chart_outlined,
                      title: "Statistiques",
                      subtitle: "Voir vos progrès",
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDestructive
              ? Colors.red.withOpacity(0.1)
              : colorProBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isDestructive ? Colors.red : colorProBlue,
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: isDestructive ? Colors.red : Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 13,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Colors.grey.shade400,
      ),
      onTap: onTap,
    );
  }
}
