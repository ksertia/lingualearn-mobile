import 'package:flutter/material.dart';

class LessonCardItem extends StatelessWidget {
  final String number;
  final String title;
  final String subtitle;
  final Color color;
  final bool isCompleted;
  final bool isActive;
  final bool isLocked;
  final VoidCallback onTap;

  const LessonCardItem({
    super.key,
    required this.number,
    required this.title,
    required this.subtitle,
    required this.color,
    this.isCompleted = false,
    this.isActive = false,
    this.isLocked = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFF1D2033),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isLocked ? Colors.grey : color, width: 2),
              ),
              child: Center(
                child: isLocked
                    ? const Icon(Icons.lock, color: Colors.grey)
                    : isCompleted
                    ? Icon(Icons.check, color: color)
                    : Text(number, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18)),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Lesson", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  Text(
                    title,
                    style: TextStyle(
                      color: isLocked ? Colors.grey : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(color: Color(0xFF2196F3), fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}