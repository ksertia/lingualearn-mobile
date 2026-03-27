import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:animated_text_kit/animated_text_kit.dart';


class StepMascotte extends StatelessWidget {
  const StepMascotte({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/app/plan4.jpeg"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: Row(
                    children: [
                      _buildBackButton(),                    ],
                  ),
                ),

                Image.asset(
                  "assets/images/app/logo.png",
                  height: 140,
                ),

                _buildSpeechBubble(),

                Lottie.asset(
                  'assets/lottie/Sad mascot.json',
                  width: 240,
                  height: 240,
                  fit: BoxFit.contain,
                ),


                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                  child: _buildActionButton(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))
        ],
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
        onPressed: () => Get.back(),
      ),
    );
  }

  Widget _buildSpeechBubble() {
    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 400,
          height: 140,
          margin: const EdgeInsets.symmetric(horizontal: 30),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0xFFFFD54F), width: 3), 
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: AnimatedTextKit(
            animatedTexts: [
              TypewriterAnimatedText(
                "Salut 👋 moi c’est LinguaLearn !\nPrêt à découvrir l’application ?",
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF424242),
                ),
                speed: const Duration(milliseconds: 40),
              ),
            ],
            totalRepeatCount: 1,
            displayFullTextOnTap: true,
            stopPauseOnTap: true,
          ),
          // child: const Text(
          //   "Salut 👋 moi c’est LinguaLearn !\nPrêt à découvrir l’application ?",
          //   textAlign: TextAlign.center,
          //   style: TextStyle(
          //     fontSize: 18,
          //     fontWeight: FontWeight.bold,
          //     color: Color(0xFF424242),
          //   ),
          // ),
        ),
        Positioned(
          bottom: -12,
          child: RotationTransition(
            turns: const AlwaysStoppedAnimation(45 / 360),
            child: Container(
              width: 25,
              height: 25,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  right: BorderSide(color: Color(0xFFFFD54F), width: 3),
                  bottom: BorderSide(color: Color(0xFFFFD54F), width: 3),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () => Get.toNamed('/laguedecouvert'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF8F00),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(35),
            side: const BorderSide(color: Colors.white, width: 2),
          ),
          elevation: 0,
        ),
        child: const Text(
          "C'EST PARTI !",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}