import 'package:flutter/material.dart';

import '../../../../widgets/lessons/custom_lesson_app_bar.dart';
import '../../../../widgets/lessons/lesson_card_item.dart';

class LessonSelectionScreen extends StatelessWidget {
  const LessonSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color accentBlue = Color(0xFF2196F3);
    const Color accentOrange = Color(0xFFFF8C00);

    return Scaffold(
      backgroundColor: Colors.white, // ✅ PAGE BLANCHE
      appBar: const CustomLessonAppBar(title: "Étape 1"),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 25, 20, 10),
            child: Text(
              "Beginner",
              style: TextStyle(
                color: Colors.black, // ✅ TEXTE NOIR
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              children: [
                LessonCardItem(
                  number: "1",
                  title: "Salutations",
                  subtitle: "10 Exp",
                  color: accentBlue,
                  isCompleted: true,
                  onTap: () {},
                ),
                LessonCardItem(
                  number: "2",
                  title: "Dialogue",
                  subtitle: "10 Exp",
                  color: accentOrange,
                  isActive: true,
                  onTap: () {},
                ),
                LessonCardItem(
                  number: "3",
                  title: "Présentation",
                  subtitle: "10 Exp",
                  color: Colors.redAccent,
                  onTap: () {},
                ),
                LessonCardItem(
                  number: "4",
                  title: "Quiz",
                  subtitle: "10 Exp",
                  color: Colors.grey,
                  isLocked: true,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
