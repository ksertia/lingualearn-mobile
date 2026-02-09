import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fasolingo/controller/apps/moduls/home_controller.dart';
import 'package:fasolingo/controller/apps/session_controller.dart';
import 'package:fasolingo/helpers/storage/local_storage.dart';
import 'package:fasolingo/models/modules/modul_model.dart';

// Palette de couleurs harmonisée
const Color colorProBlue = Color(0xFF00008B); // Bleu Profond (Structure & Titres)
const Color colorKidGreen = Color(0xFF32CD32); // Vert Éclatant (DÉVERROUILLÉ)
const Color colorLocked = Color(0xFFBDC3C7);   // Gris Souris (VERROUILLÉ)

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.put(HomeController());
    final SessionController session = Get.find<SessionController>();

    String firstName = LocalStorage.getUserName() ?? "Champion";
    String greeting = "Salut";
    String langue = session.user?.selectedLanguageId ?? "";

    if (langue.toLowerCase().contains("mooré")) {
      greeting = "Ne y windiga";
    } else if (langue.toLowerCase().contains("dioula")) {
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
          // --- HEADER ---
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
                  "Prêt pour ton aventure en $langue ?",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildKidStat(Icons.local_fire_department, "3", "Jours", Colors.orange),
                    _buildKidStat(Icons.stars, "1250", "XP", colorProBlue),
                    _buildKidStat(Icons.emoji_events, "Bronze", "Ligue", colorKidGreen),
                  ],
                ),
              ],
            ),
          ),

          // --- TIMELINE ---
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator(color: colorKidGreen));
              }

              return RefreshIndicator(
                onRefresh: () => controller.onRefresh(),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(25, 35, 25, 40),
                  itemCount: controller.filteredModules.length,
                  itemBuilder: (context, index) {
                    final module = controller.filteredModules[index];
                    bool isLast = index == controller.filteredModules.length - 1;
                    
                    // Logique : les deux premiers sont déverrouillés pour l'exemple
                    bool isUnlocked = index <= 1; 

                    return IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              _buildTimelineIcon(isUnlocked),
                              if (!isLast)
                                Expanded(
                                  child: Container(
                                    width: 6,
                                    margin: const EdgeInsets.symmetric(vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isUnlocked ? colorKidGreen.withOpacity(0.3) : colorLocked.withOpacity(0.2),
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
                              child: _buildKidCard(module, isUnlocked, index),
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

  Widget _buildTimelineIcon(bool isUnlocked) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          if (isUnlocked)
            BoxShadow(color: colorKidGreen.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      child: Icon(
        isUnlocked ? Icons.check_circle_rounded : Icons.lock_rounded,
        color: isUnlocked ? colorKidGreen : colorLocked,
        size: 42,
      ),
    );
  }

  Widget _buildKidCard(ModuleModel module, bool isUnlocked, int index) {
    return GestureDetector(
      onTap: !isUnlocked 
        ? () => Get.snackbar("Oups ! 🔒", "Finis les leçons précédentes pour débloquer celle-ci !") 
        : () => Get.toNamed('/parcoursselectionpage', arguments: module.id),
      child: Container(
        decoration: BoxDecoration(
          color: isUnlocked ? Colors.white : const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isUnlocked ? colorKidGreen.withOpacity(0.5) : colorLocked.withOpacity(0.3),
            width: 2
          ),
          boxShadow: [
            BoxShadow(
              color: isUnlocked ? colorKidGreen.withOpacity(0.3) : Colors.transparent, // 
              offset: const Offset(0, 8),
              blurRadius: 0,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                height: 55, width: 55,
                decoration: BoxDecoration(
                  color: isUnlocked ? colorKidGreen.withOpacity(0.1) : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Text("${index + 1}", 
                    style: TextStyle(
                      fontSize: 22, 
                      fontWeight: FontWeight.bold, 
                      color: isUnlocked ? colorKidGreen : colorLocked
                    )),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      module.title.toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.w900, 
                        fontSize: 17, 
                        color: isUnlocked ? colorProBlue : colorLocked // Titre gris si verrouillé
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isUnlocked 
                        ? (module.description ?? "Découvre les secrets de la langue !") 
                        : "Termine les étapes précédentes...",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isUnlocked ? Colors.blueGrey : colorLocked,
                        fontSize: 13,
                        fontWeight: FontWeight.w500
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isUnlocked ? Icons.chevron_right_rounded : Icons.lock_outline_rounded,
                color: isUnlocked ? colorKidGreen : colorLocked,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKidStat(IconData icon, String val, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(15),
      ),
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
}