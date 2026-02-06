import 'package:fasolingo/views/apps/home/screens/stepsscreens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../../../widgets/parcourspage/ParcoursStepItem.dart';
import '../../../../widgets/stepsscreens/custom_app_bar.dart';
//import '../stepsscreens/stepsscreens.dart'; // IMPORT de ta page d'étapes

class ParcoursSelectionPage extends StatelessWidget {
  const ParcoursSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF00008B);
    const Color cyanAccent = Color(0xFF00CED1);
    const Color orangeAccent = Color(0xFFFF8C00);

    // Fonction pratique pour éviter de répéter Navigator.push
    void goToSteps(BuildContext context) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const StepsScreensPages()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: "Suivez Votre Parcours"),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
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

                    ParcoursStepItem(
                      number: "1",
                      title: "Parcours 1",
                      subtitle: "Commencez ici",
                      color: primaryBlue,
                      isCompleted: true,
                      imagePath: 'assets/rocket.png',
                        onTap: ()  => Get.toNamed('/stepsscreens'),
                    ),

                    ParcoursStepItem(
                      number: "2",
                      title: "Parcours 2",
                      subtitle: "Renseignez vos détails",
                      color: cyanAccent,
                      isCompleted: true,
                      imagePath: 'assets/clipboard.png',
                        onTap: () {}
                    ),

                    ParcoursStepItem(
                      number: "3",
                      title: "Parcours 3",
                      subtitle: "Vérifiez vos informations",
                      color: orangeAccent,
                      isActive: true,
                      imagePath: 'assets/search.png',
                        onTap: () {}
                    ),

                    ParcoursStepItem(
                      number: "4",
                      title: "Parcours 4",
                      subtitle: "Terminez le processus",
                      color: Colors.grey,
                      imagePath: 'assets/trophy.png',
                        onTap: () {}
                    ),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),

          ),
        ],
      ),
    );
  }
}