import 'package:fasolingo/controller/apps/discovery_controller.dart';
import 'package:fasolingo/widgets/decouvrir_page/decouverte/StepDiscoveryAudio.dart';
import 'package:fasolingo/widgets/decouvrir_page/decouverte/StepDiscoveryVideo.dart';
import 'package:fasolingo/widgets/lessons/qcm.dart';
import 'package:fasolingo/widgets/lessons/qcmdrag.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class AudioStepPage extends StatelessWidget {
  final dynamic data;
  const AudioStepPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final DiscoveryController controller = Get.put(DiscoveryController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF8F00), Color(0xFFFF8F00)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Les bases des salutations",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: Obx(() => IconButton(
              icon: Icon(
                controller.currentPage.value == 0
                    ? Icons.arrow_back_ios_new
                    : Icons.close,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () => Get.back(),
            )),
      ),
      body: Column(
        children: [
          // BARRE DE PROGRESSION
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Obx(() => ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: LinearProgressIndicator(
                    value: controller.progress,
                    minHeight: 8,
                    backgroundColor: Colors.grey[300],
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Color(0xFFFF8F00)),
                  ),
                )),
          ),

          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: PageView(
                  controller: controller.pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) =>
                      controller.currentPage.value = index,
                  children: [
                    StepDiscoveryAudio(
                      title: "RÉPÈTE APRÈS MOI",
                      texteOriginal: "I ni sɔgɔma",
                      traduction: "Bonjour (le matin)",
                      lottie:
                          'assets/lottie/Sad mascot.json', 
                    ),

                    StepDiscoveryAudio(
                      title: "RÉPÈTE APRÈS MOI",
                      texteOriginal: "I ka kɛnɛ ?",
                      traduction: "Est-ce que tu vas bien ?",
                      lottie: 'assets/lottie/Sad mascot.json',
                    ),

                    StepDiscoveryVideo(
                      videoTitle: "OBSERVE ATTENTIVEMENT",
                      videoUrl: "assets/images/video/videos.mp4",
                      onVideoFinished: () => controller.nextPage(),
                    ),

                    const QuizQCM(
                      question: "Comment dire 'Bonjour' le matin ?",
                      options: [
                        "I ni tile",
                        "I ni wula",
                        "I ni sɔgɔma",
                        "I ni su"
                      ],
                      correctOption: "I ni sɔgɔma",
                      lottieQuestion: 'assets/lottie/mascot.json',
                      lottieCorrect: 'assets/lottie/Happy mascot.json',
                      lottieIncorrect: 'assets/lottie/Sad mascot.json',
                    ),

                    const QuizQCM(
                      question: "Si on te dit 'I ka kɛnɛ ?', tu réponds :",
                      options: [
                        "Tana tɛ", 
                        "A bɛ sɔrɔ",
                        "I ni sɔgɔma",
                        "I bɛ min ?"
                      ],
                      correctOption: "Tana tɛ",
                      lottieQuestion: 'assets/lottie/mascot.json',
                      lottieCorrect: 'assets/lottie/Happy mascot.json',
                      lottieIncorrect: 'assets/lottie/Sad mascot.json',
                    ),

                    StepQuizTranslate(
                      question: "I ni sɔgɔma",
                      words: [
                        "Bonjour",
                        "Merci",
                        "À demain",
                        "Comment",
                        "Monsieur"
                      ],
                      correctFullSentence: "Bonjour",
                      lottieQuestion: 'assets/lottie/mascot.json',
                      lottieCorrect: 'assets/lottie/Happy mascot.json',
                      lottieIncorrect: 'assets/lottie/Sad mascot.json',
                    ),
                    StepQuizTranslate(
                      question: "Bonjour, ça va ?",
                      words: ["I", "ni", "sɔgɔma", "ka", "kɛnɛ", "tana"],
                      correctFullSentence: "I ni sɔgɔma ka kɛnɛ",
                      lottieQuestion: 'assets/lottie/mascot.json',
                      lottieCorrect: 'assets/lottie/Happy mascot.json',
                      lottieIncorrect: 'assets/lottie/Sad mascot.json',
                    ),
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 15, 20, 25),
            child: Obx(() {
              if (controller.currentPage.value >= 3) {
                return const SizedBox.shrink();
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  controller.currentPage.value > 0
                      ? SizedBox(
                          height: 45,
                          child: OutlinedButton.icon(
                            onPressed: controller.previousPage,
                            icon: const Icon(Icons.arrow_back_ios, size: 14),
                            label: const Text("Précédent"),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFFF8F00),
                              side: const BorderSide(color: Color(0xFFFF8F00)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),

                  // Bouton Suivant
                  SizedBox(
                    height: 45,
                    child: ElevatedButton(
                      onPressed: controller.nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF8F00),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Suivant",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
