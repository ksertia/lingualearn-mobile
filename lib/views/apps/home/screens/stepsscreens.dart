// lib/screens/steps_screens_pages.dart
import 'package:flutter/material.dart';
import '../../../../widgets/stepsscreens/custom_app_bar.dart';
import '../../../../widgets/stepsscreens/parcours_item.dart';

class StepsScreensPages extends StatelessWidget {
  const StepsScreensPages({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Charger les parcours"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Présentation des étapes du module",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              ParcoursItem(
                label: "Etapes: 1",
                status: "Terminé",
                statusColor: Colors.green,
                icon: Icons.check_circle_outline,
                progress: 1.0,
                countText: "3/3",
                onTap: () => Navigator.pushNamed(context, '/detaillepage'),
              ),

              const SizedBox(height: 10),

              ParcoursItem(
                label: "Etapes: 2",
                status: "En cours",
                statusColor: Colors.orange,
                icon: Icons.timelapse,
                progress: 0.33,
                countText: "1/3",
                onTap: () => Navigator.pushNamed(context, '/etapes2pages'),
              ),

              const SizedBox(height: 10),

              ParcoursItem(
                label: "Etapes: 3",
                status: "Verrouillé",
                statusColor: Colors.grey,
                icon: Icons.lock,
                progress: 0.0,
                countText: "0/3",
                onTap: () => print("L'étape 3 est verrouillée !"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}