import 'package:flutter/material.dart';

class Etapes2Pages extends StatelessWidget {
  const Etapes2Pages({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0056B3),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Etapes 2 : En cours",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          children: [
            // Leçon 1 - Bouton "Réviser" -> Envoie vers '/lesson1'
            _buildLessonCard(
              context,
              title: "Leçon 1 - Salutations",
              status: "Terminée",
              statusIcon: Icons.check_circle,
              color: Colors.white,
              textColor: Colors.black,
              statusColor: Colors.green,
              buttonText: "Réviser",
              buttonColor: Colors.green,
              progress: 1.0,
              routeName: '/lesson1',
            ),
            const SizedBox(height: 16),

            // Leçon 2 - Bouton "Continuer" -> Envoie vers '/lesson2'
            _buildLessonCard(
              context,
              title: "Leçon 2 - Se présenter",
              status: "En cours (60%)",
              statusIcon: Icons.check_circle_outline,
              color: const Color(0xFF2D74C4),
              textColor: Colors.white,
              statusColor: Colors.white,
              buttonText: "Continuer",
              buttonColor: Colors.white,
              progress: 0.6,
              routeName: '/lesson2',
            ),
            const SizedBox(height: 16),

            // Leçon 3 - Verrouillée (Pas de bouton)
            _buildLessonCard(
              context,
              title: "Leçon 3 - Les chiffres",
              status: "Verrouillée",
              statusIcon: Icons.lock,
              color: Colors.white,
              textColor: Colors.black87,
              statusColor: Colors.grey,
              subtitle: "Terminez la leçon 2 pour débloquer",
              progress: 0.0,
              isLocked: true,
              routeName: '/lesson3',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonCard(
      BuildContext context, {
        required String title,
        required String status,
        required IconData statusIcon,
        required Color color,
        required Color textColor,
        required Color statusColor,
        String? buttonText,
        Color? buttonColor,
        String? subtitle,
        required double progress,
        bool isLocked = false,
        required String routeName,
      }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          // Clique n'importe où sur la carte pour naviguer
          onTap: isLocked ? null : () => Navigator.pushNamed(context, routeName),
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: textColor)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(statusIcon, color: statusColor, size: 22),
                        const SizedBox(width: 8),
                        Text(status, style: TextStyle(color: statusColor, fontSize: 16, fontWeight: FontWeight.w500)),
                      ],
                    ),
                    // LE BOUTON CLIQUABLE
                    if (buttonText != null)
                      SizedBox(
                        height: 35,
                        child: ElevatedButton(
                          // Le bouton déclenche la navigation nommée
                          onPressed: isLocked ? null : () => Navigator.pushNamed(context, routeName),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonColor,
                            foregroundColor: buttonColor == Colors.white ? const Color(0xFF2D74C4) : Colors.white,
                            elevation: 2, // Légère ombre pour le bouton
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text(buttonText, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                  ],
                ),
                if (subtitle != null) ...[
                  const Padding(padding: EdgeInsets.only(top: 8.0), child: Divider(color: Colors.grey, thickness: 0.5)),
                  Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ],
                if (progress > 0 && progress < 1) ...[
                  const SizedBox(height: 15),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.cyanAccent),
                      minHeight: 8,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}