import 'package:fasolingo/controller/apps/langue/langue_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart'; 
import 'package:fasolingo/controller/apps/moduls/home_controller.dart';
import 'package:fasolingo/controller/apps/session_controller.dart';
import 'package:fasolingo/helpers/storage/local_storage.dart';
import 'package:fasolingo/models/modules/modul_model.dart';
import 'package:fasolingo/models/langue/langue_model.dart';

const Color colorProBlue = Color(0xFF00008B);
const Color primaryBlue = Color(0xFF00CED1);
const Color colorLocked = Color(0xFFBDC3C7);
const Color orangeAccent = Colors.orange;

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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

    final LanguageModel? selectedLang = langController.allLanguages.firstWhereOrNull(
      (l) => l.id == langueId
    );
    String langueNom = selectedLang?.name ?? "ta langue";

    if (langueNom.toLowerCase().contains("mooré")) {
      greeting = "Ne y windiga";
    } else if (langueNom.toLowerCase().contains("dioula")) {
      greeting = "I ni sogoma";
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0F7FF),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'LinguaLearn ✨',
          style: TextStyle(color: colorProBlue, fontWeight: FontWeight.w900, fontSize: 22),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: CircleAvatar(
              backgroundColor: colorProBlue.withOpacity(0.1),
              child: Text(
                firstName.isNotEmpty ? firstName[0].toUpperCase() : "U",
                style: const TextStyle(color: colorProBlue, fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
      body: Column(
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
                BoxShadow(color: colorProBlue.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(25, 10, 25, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$greeting, $firstName ! 🇧🇫",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF2D3436)),
                ),
                const SizedBox(height: 5),
                Text(
                  "Prêt pour ton aventure en $langueNom ?",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildKidStat(Icons.local_fire_department, "3", "Jours", Colors.orange),
                    _buildKidStat(Icons.stars, "1250", "XP", colorProBlue),
                    _buildKidStat(Icons.emoji_events, "Bronze", "Ligue", primaryBlue),
                  ],
                ),
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
                      const Icon(Icons.info_outline, size: 50, color: Colors.grey),
                      const SizedBox(height: 10),
                      const Text("Aucun module trouvé."),
                      const SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: () => controller.loadModules(), 
                        child: const Text("Réessayer")
                      )
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
                    bool isLast = index == controller.filteredModules.length - 1;

                    // Utiliser les helpers du controller pour déterminer l'état
                    bool isUnlocked = controller.isUnlocked(module.id);
                    bool isCompleted = controller.isCompleted(module.id);
                    // Si le backend ne fournit rien, autoriser le premier module par défaut
                    if (!isUnlocked && index == 0) isUnlocked = true;

                    return IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              _buildTimelineIcon(isUnlocked, isCompleted),
                              if (!isLast)
                                Expanded(
                                  child: Container(
                                    width: 6,
                                    margin: const EdgeInsets.symmetric(vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isUnlocked ? (isCompleted ? primaryBlue : orangeAccent).withOpacity(0.3) : colorLocked.withOpacity(0.2),
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
                              child: _buildKidCard(controller, module, isUnlocked, isCompleted, index),
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
    );
  }

  Widget _buildTimelineIcon(bool isUnlocked, bool isCompleted) {
    IconData iconData = Icons.lock_rounded;
    Color iconColor = colorLocked;

    if (isUnlocked) {
      iconData = isCompleted ? Icons.check_circle_rounded : Icons.play_circle_filled_rounded;
      iconColor = isCompleted ? primaryBlue : orangeAccent;
    }

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          if (isUnlocked)
            BoxShadow(color: iconColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      child: Icon(iconData, color: iconColor, size: 42),
    );
  }

  Widget _buildKidCard(HomeController controller, ModuleModel module, bool isUnlocked, bool isCompleted, int index) {
    Color mainColor = isUnlocked ? (isCompleted ? primaryBlue : orangeAccent) : colorLocked;

    return GestureDetector(
      onTap: !isUnlocked
        ? () => Get.snackbar("🔒 Verrouillé", "Termine le module précédent !")
        : () async {
            final res = await Get.toNamed('/parcoursselectionpage', arguments: module.id);
            if (res == true || res == 'completed' || res == 'finished') {
              controller.onModuleCompleted(module.id);
            }
          },
      child: Container(
        decoration: BoxDecoration(
          color: isUnlocked ? Colors.white : const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: mainColor.withOpacity(0.5), width: 2),
          boxShadow: [
            if (isUnlocked)
              BoxShadow(color: mainColor.withOpacity(0.2), offset: const Offset(0, 8), blurRadius: 0),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                height: 55, width: 55,
                decoration: BoxDecoration(
                  color: mainColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Text("${index + 1}", 
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: mainColor)),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isUnlocked ? (isCompleted ? "TERMINÉ" : "EN COURS") : "VERROUILLÉ",
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: mainColor),
                    ),
                    Text(
                      module.title.toUpperCase(),
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: isUnlocked ? colorProBlue : colorLocked),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isUnlocked ? module.description : "Termine les étapes précédentes...",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: isUnlocked ? Colors.blueGrey : colorLocked, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Icon(isUnlocked ? Icons.chevron_right_rounded : Icons.lock_outline_rounded, color: mainColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKidStat(IconData icon, String val, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(val, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
              Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
            ],
          ),
        ],
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
              Expanded(child: Container(height: 100, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)))),
            ],
          ),
        ),
      ),
    );
  }
}