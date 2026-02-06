
import 'package:flutter/material.dart';

class BadgeRewardDialog extends StatelessWidget {
  final int xp;
  const BadgeRewardDialog({super.key, required this.xp});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.stars, color: Colors.orange, size: 80),
          const SizedBox(height: 12),
          const Text("Félicitations !",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text("+$xp XP"),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Afficher mes badges"),
          ),
        ],
      ),
    );
  }
}
