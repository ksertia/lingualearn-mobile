import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../widgets/parcourspage/ParcoursStepItem.dart';
import '../../../../widgets/stepsscreens/custom_app_bar.dart';

class ParcoursSelectionPage extends StatelessWidget {
  const ParcoursSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF00CED1);
    const Color orangeAccent = Color(0xFFFF8C00);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: "Suivez Votre Parcours"),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                // Ligne verticale
                Positioned(
                  left: 48, top: 40, bottom: 40,
                  child: Container(width: 2, color: Colors.grey.shade200),
                ),
                ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  children: [
                    const Text(
                      "Complétez chaque parcours pour avancer.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 30),

                    // PARCOURS 1 : Terminé
                    ParcoursStepItem(
                      number: "1",
                      title: "Parcours 1",
                      subtitle: "Terminé avec succès",
                      color: primaryBlue,
                      isCompleted: true,
                      onTap: () => Get.toNamed('/stepsscreens'),
                    ),

                    // PARCOURS 2 : En cours
                    ParcoursStepItem(
                      number: "2",
                      title: "Parcours 2",
                      subtitle: "En cours",
                      color: orangeAccent,
                      isActive: true,
                      isCompleted: false,
                      icon: Icons.play_arrow_rounded,
                      onTap: () {},
                    ),

                    // PARCOURS 3 (Ancien Parcours 4) : Verrouillé
                    ParcoursStepItem(
                      number: "3",
                      title: "Parcours 3",
                      subtitle: "Verouillé",
                      color: Colors.grey,
                      icon: Icons.lock_outline,
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}