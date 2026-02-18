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
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorProBlue.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.school_rounded,
                    color: colorProBlue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'LinguaLearn',
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
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                      onTap: () => _showSettingsBottomSheet(context, firstName, langueNom),
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
                            firstName.isNotEmpty ? firstName[0].toUpperCase() : "U",
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

                    // 🔍 LOGS DEBUG - Données des modules
                    debugPrint("=== MODULE $index ===");
                    debugPrint("ID: ${module.id}");
                    debugPrint("Title: ${module.title}");
                    debugPrint("Description: ${module.description}");
                    debugPrint("Status: ${module.status}");
                    debugPrint("Progress: ${module.progressPercentage}%");
                    debugPrint("Index: ${module.index}");
                    debugPrint("IsActive: ${module.isActive}");
                    if (module.progress != null) {
                      debugPrint("Progress Object - Status: ${module.progress!.status}");
                      debugPrint("Progress Object - Percentage: ${module.progress!.progressPercentage}");
                      debugPrint("Progress Object - CompletedAt: ${module.progress!.completedAt}");
                      debugPrint("Progress Object - UnlockedAt: ${module.progress!.unlockedAt}");
                    } else {
                      debugPrint("Progress Object: null");
                    }
                    debugPrint("==================");

                    // Utiliser directement le statut du backend au lieu des helpers
                    String moduleStatus = module.status ?? "locked";
                    
                    // FALLBACK: Si tous les statuts sont null, débloquer le premier module
                    if (moduleStatus == "locked" && index == 0) {
                      bool allModulesLocked = controller.filteredModules.every((m) => (m.status ?? "locked") == "locked");
                      if (allModulesLocked) {
                        moduleStatus = "unlocked";
                        print(" [FALLBACK] Premier module débloqué automatiquement (tous les statuts sont null)");
                      }
                    }
                    
                    bool isCompleted = moduleStatus == "completed";
                    bool isUnlocked = moduleStatus == "unlocked" || moduleStatus == "completed";
                    bool isLocked = moduleStatus == "locked";

                    // LOG du statut calculé
                    print("Module ${index + 1}: Status='$moduleStatus' → isCompleted=$isCompleted, isUnlocked=$isUnlocked");

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
                              child: _buildKidCard(controller, module, moduleStatus, index),
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

  Widget _buildTimelineIcon(String moduleStatus) {
    IconData iconData = Icons.lock_rounded;
    Color iconColor = colorLocked;

    if (moduleStatus == "completed") {
      iconData = Icons.check_circle_rounded;
      iconColor = primaryBlue;
    } else if (moduleStatus == "unlocked") {
      iconData = Icons.play_circle_filled_rounded;
      iconColor = orangeAccent;
    }

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          if (moduleStatus != "locked")
            BoxShadow(color: iconColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      child: Icon(iconData, color: iconColor, size: 42),
    );
  }

  Widget _buildKidCard(HomeController controller, ModuleModel module, String moduleStatus, int index) {
    Color mainColor = moduleStatus == "completed" ? primaryBlue : moduleStatus == "unlocked" ? orangeAccent : colorLocked;
    bool isUnlocked = moduleStatus == "unlocked" || moduleStatus == "completed";
    bool isCompleted = moduleStatus == "completed";

    return GestureDetector(
      onTap: !isUnlocked
        ? () => Get.snackbar("", "Termine le module précédent !")
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
                      moduleStatus == "completed" ? "TERMINÉ" : moduleStatus == "unlocked" ? "EN COURS" : "VERROUILLÉ",
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

  void _showSettingsBottomSheet(BuildContext context, String firstName, String langueNom) {
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
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
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

              // Settings options
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  children: [
                    _buildSettingsItem(
                      icon: Icons.person_outline,
                      title: "Profil",
                      subtitle: "Modifier vos informations",
                      onTap: () {},
                    ),
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
                    _buildSettingsItem(
                      icon: Icons.help_outline,
                      title: "Aide & Support",
                      subtitle: "FAQ et contact",
                      onTap: () {},
                    ),
                    _buildSettingsItem(
                      icon: Icons.info_outline,
                      title: "À propos",
                      subtitle: "Version et informations",
                      onTap: () {},
                    ),
                    const SizedBox(height: 20),
                    _buildSettingsItem(
                      icon: Icons.logout,
                      title: "Déconnexion",
                      subtitle: "Se déconnecter de l'app",
                      onTap: () {
                        Navigator.of(context).pop();
                        _showLogoutDialog(context);
                      },
                      isDestructive: true,
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

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'Déconnexion',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: colorProBlue,
            ),
          ),
          content: const Text(
            'Êtes-vous sûr de vouloir vous déconnecter ?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Annuler',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Implement logout logic
                Get.snackbar(
                  "Déconnexion",
                  "Fonctionnalité à implémenter",
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Déconnecter',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }
}