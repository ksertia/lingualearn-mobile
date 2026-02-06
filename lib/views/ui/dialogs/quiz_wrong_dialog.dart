import 'package:flutter/material.dart';

class QuizWrongDialog extends StatelessWidget {
  final String correction;
  final int xpReward; // optionnel, peut montrer XP partiel ou 0

  const QuizWrongDialog({
    super.key,
    required this.correction,
    this.xpReward = 0,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icône animée ❌
          const Icon(Icons.cancel, color: Colors.red, size: 80),
          const SizedBox(height: 12),
          const Text(
            "Oups...",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            correction,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          if (xpReward > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                "XP gagnés : $xpReward",
                style: const TextStyle(fontSize: 16, color: Colors.orange),
              ),
            ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () => Navigator.pop(context),
            child: const Text("Revoir"),
          ),
        ],
      ),
    );
  }
}
