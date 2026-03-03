import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fasolingo/controller/apps/parcoure/parcoure_controller.dart';

class ParcoursSelectionPage extends StatelessWidget {
  const ParcoursSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Utilisation de ton contrôleur existant
    final controller = Get.put(ParcoursSelectionController());

    return Scaffold(
      body: Stack(
        children: [
          /// 🌄 BACKGROUND SAVANE (Image de fond)
          Positioned.fill(
            child: Image.asset(
              "assets/images/quiz/brousse.jpeg",
              fit: BoxFit.cover,
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                /// 🔵 HEADER BLEU FIXE (En haut)
                _buildTopHeader(),

                /// 📜 CONTENU DÉFILANT
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(child: CircularProgressIndicator(color: Colors.orange));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      // +1 pour inclure la carte de Module en haut de la liste
                      itemCount: controller.paths.length + 1,
                      itemBuilder: (context, index) {

                        // Le premier élément est la carte orange du Module 1
                        if (index == 0) {
                          return _buildModuleProgressCard();
                        }

                        // Les éléments suivants sont tes parcours (index - 1)
                        final path = controller.paths[index - 1];

                        return _SavanePathCard(
                          path: path,
                          index: index - 1,
                          onTap: () {
                            if (path.status != "locked") {
                              Get.toNamed('/stepsscreens', arguments: {
                                'moduleId': controller.moduleId,
                                'pathId': path.id,
                              });
                            }
                          },
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🔵 HEADER SUPERIEUR (Retour + Titre)
  Widget _buildTopHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: const CircleAvatar(
              backgroundColor: Colors.orange,
              child: Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Text(
              "Suivez votre parcours",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [Shadow(color: Colors.black26, blurRadius: 2)],
              ),
            ),
          ),
          const Icon(Icons.star_border, color: Colors.white, size: 28),
          const SizedBox(width: 5),
          const Icon(Icons.star_border, color: Colors.white, size: 28),
        ],
      ),
    );
  }

  /// 🍊 CARTE DE PROGRESSION DU MODULE (Module 1 : Dibi)
  Widget _buildModuleProgressCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 30),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF39C12).withOpacity(0.9),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  "MODULE 1 : Dibi 🇧🇫\n(Les Animaux)",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Image.asset("assets/images/lion_icon.png", height: 50, errorBuilder: (c,e,s) => const Icon(Icons.pets, color: Colors.white, size: 40)),
            ],
          ),
          const Text(
            "Découvre les bêtes sauvages !",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 15),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: const LinearProgressIndicator(
              value: 0.7, // À lier avec une variable de ton controller si besoin
              minHeight: 12,
              backgroundColor: Colors.black12,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.greenAccent),
            ),
          ),
          const SizedBox(height: 8),
          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              "7/10 Leçons",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }
}

/// 🦁 CARD STYLE SAVANE (Design des étapes)
class _SavanePathCard extends StatelessWidget {
  final dynamic path;
  final int index;
  final VoidCallback onTap;

  const _SavanePathCard({
    required this.path,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    bool isLocked = path.status == "locked";
    bool isCompleted = path.status == "completed";

    // Couleurs adaptées à l'image
    Color bgColor = isLocked
        ? Colors.white.withOpacity(0.6)
        : (isCompleted ? const Color(0xFFFF9F43) : Colors.white);

    Color textColor = isLocked ? Colors.grey : (isCompleted ? Colors.white : Colors.orange.shade700);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
            onTap: isLocked ? null : onTap,
            child: Container(
              height: 85,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Row(
                children: [
                  /// 🦁 Icône à gauche (Lion ou Lock)
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: isLocked ? Colors.grey.shade300 : Colors.orange.shade100,
                    child: isLocked
                        ? const Icon(Icons.lock, color: Colors.grey)
                        : Image.asset("assets/images/mini_lion.png", errorBuilder: (c,e,s) => const Icon(Icons.face, color: Colors.orange)),
                  ),
                  const SizedBox(width: 15),

                  /// 📝 Texte du parcours
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Parcours ${index + 1}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: textColor.withOpacity(0.8),
                          ),
                        ),
                        Text(
                          path.title ?? "",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// ▶ Bouton Action
                  if (!isLocked)
                    CircleAvatar(
                      backgroundColor: Colors.green,
                      radius: 18,
                      child: Icon(
                        isCompleted ? Icons.check : Icons.play_arrow,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                ],
              ),
            ),
          ),

          /// 🔒 Cadenas flottant doré
          if (isLocked)
            Positioned(
              right: 20,
              top: -10,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.yellow.shade700,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.lock, size: 16, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}