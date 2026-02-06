import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../../../widgets/stepsscreens/custom_app_bar.dart';
import '../../../../widgets/stepsscreens/parcours_item.dart';
//import '../widgets/stepsscreens/custom_app_bar.dart';
//import '../widgets/stepsscreens/parcours_item.dart';

class StepsScreensPages extends StatelessWidget {

  const StepsScreensPages({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF00008B);
    const Color cyanAccent = Color(0xFF00CED1);
    const Color orangeAccent = Color(0xFFFF8C00);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: "Module 1: Introduction à la Science"),
      body: Stack(
        children: [
          // LIGNE VERTICALE CORRIGÉE
          Positioned(
            left: 56, // Ajusté pour être bien au centre des icônes
            top: 130, // ON AUGMENTE LE TOP pour que la ligne commence SOUS le premier cercle
            bottom: 100,
            child: Container(
              width: 3,
              color: cyanAccent.withOpacity(0.3),
            ),
          ),

          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              children: [
                const Text(
                  "Parcours 1 : Comprendre les bases",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: primaryBlue,
                  ),
                ),
                const SizedBox(height: 40),

                // Étape 1
                ParcoursItem(
                  label: "Étape 1: ",
                  status: "En cours",
                  mainColor: primaryBlue,
                  icon: Icons.play_arrow_rounded,
                  onTap: () => Navigator.pushNamed(context, '/lessonselectionscreen'),
                ),

                const SizedBox(height: 30),

                // Étape 2
                ParcoursItem(
                  label: "Étape 2: Grammaires",
                  status: "Verrouillé",
                  mainColor: cyanAccent,
                  icon: Icons.lock_outline,
                  onTap: () => Navigator.pushNamed(context, '/etapes2pages'),
                ),

                const SizedBox(height: 30),

                // Étape 3
                ParcoursItem(
                  label: "Étape 3: Vocabulaires",
                  status: "Verrouillé",
                  mainColor: orangeAccent,
                  icon: Icons.lock_outline,
                  onTap: () => print("Étape 3 verrouillée"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}