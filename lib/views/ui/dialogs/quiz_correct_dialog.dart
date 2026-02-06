import 'package:flutter/material.dart';

class QuizCorrectDialog extends StatelessWidget {
  final int xpReward;

  const QuizCorrectDialog({super.key, this.xpReward = 10}); // XP par défaut = 10

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icône animée ✅
          Icon(Icons.check_circle, color: Colors.green, size: 80),
          const SizedBox(height: 12),
          const Text(
            "Bravo !",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Vous gagnez $xpReward XP",
            style: const TextStyle(fontSize: 18, color: Colors.orange),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () => Navigator.pop(context),
            child: const Text("Continuer"),
          ),
        ],
      ),
    );
  }
}
