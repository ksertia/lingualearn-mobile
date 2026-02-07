import 'package:flutter/material.dart';

class ParcoursStepItem extends StatelessWidget {
  final String number;
  final String title;
  final String subtitle;
  final Color color;
  final bool isCompleted;
  final bool isActive;
  final VoidCallback? onTap;
  final IconData? icon;

  const ParcoursStepItem({
    super.key,
    required this.number,
    required this.title,
    required this.subtitle,
    required this.color,
    this.isCompleted = false,
    this.isActive = false,
    this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: Row(
          children: [
            // Cercle d'état
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: isCompleted || isActive ? color : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                    color: isCompleted || isActive ? color : Colors.grey.shade300,
                    width: 2),
                boxShadow: [
                  if (isActive)
                    BoxShadow(color: color.withOpacity(0.3), blurRadius: 10)
                ],
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 28)
                    : (icon != null
                    ? Icon(icon, color: isActive ? Colors.white : Colors.grey, size: 28)
                    : Text(number,
                    style: TextStyle(
                        color: isActive ? Colors.white : Colors.grey,
                        fontSize: 20,
                        fontWeight: FontWeight.bold))),
              ),
            ),
            const SizedBox(width: 15),

            // Carte de contenu (Numéro et points supprimés ici)
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: isActive || isCompleted
                          ? color.withOpacity(0.5)
                          : Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, // Suppression de "$number. "
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 14)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}