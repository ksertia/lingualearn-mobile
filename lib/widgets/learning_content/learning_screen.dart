import 'package:animate_do/animate_do.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LearningScreen extends StatelessWidget {
  final String word, imageUrl, message;

  const LearningScreen({
    super.key,
    required this.word,
    required this.imageUrl,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        Padding(
          padding: const EdgeInsets.all(20),
          child: DefaultTextStyle(
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black),
            child: AnimatedTextKit(
              key: ValueKey(message),
              animatedTexts: [
                TypewriterAnimatedText(message),
              ],
              totalRepeatCount: 1,
            ),
          ),
        ),

        const Spacer(),

        FadeInUp(
          duration: const Duration(milliseconds: 800),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(
                color: Colors.orange.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Image.network(
              imageUrl,
              height: 180,
            ),
          ),
        ),

        const Spacer(),

        Column(
          children: [
            GestureDetector(
              onTap: () {
                print("Play sound: $word");
              },
              child: Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                    color: Colors.blue, shape: BoxShape.circle),
                child: const Icon(Icons.volume_up,
                    color: Colors.white, size: 45),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              word,
              style: const TextStyle(
                  fontSize: 40, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ],
    );
  }
}