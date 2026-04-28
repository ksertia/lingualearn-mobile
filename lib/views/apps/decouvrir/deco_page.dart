import 'package:fasolingo/controller/apps/discovery_controller.dart';
import 'package:fasolingo/models/langue/decouverte_model.dart';
import 'package:fasolingo/widgets/decouvrir_page/decouverte/StepDiscoveryVideo.dart';
import 'package:fasolingo/widgets/decouvrir_page/decouverte/StepDiscoveryImage.dart';
import 'package:fasolingo/widgets/decouvrir_page/decouverte/StepQuizDrag.dart';
import 'package:fasolingo/widgets/decouvrir_page/decouverte/StepQuizQCM.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fasolingo/widgets/decouvrir_page/decouverte/StepDiscoveryAudio.dart';
import 'package:fasolingo/widgets/decouvrir_page/decouverte/step_discovery_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DiscoveryStep {
  final Widget widget;
  final String sectionType;

  DiscoveryStep({
    required this.widget,
    required this.sectionType,
  });
}

class DiscoveryPage extends StatelessWidget {
  const DiscoveryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final dynamic args = Get.arguments;

    final LanguageData languageData =
        args is LanguageData ? args : LanguageData(lessons: [], exercises: []);

    final DiscoveryController controller = Get.put(DiscoveryController());

    List<DiscoveryStep> allSteps = [];


    // GESTION DES LEÇONS (AUDIO, VIDÉO, IMAGE)
    for (var section in languageData.lessons) {
      for (var content in section.contents) {
        Widget stepWidget;

        if (content.questionType == "audio") {
          stepWidget = StepDiscoveryAudioPlayer(
            title: section.title.toUpperCase(),
            audioUrl: content.questionValue,
            answerText: content.answerValue ?? '',
          );
        }
        else if (content.answerType == "video") {
          stepWidget = StepDiscoveryVideo(
            videoTitle: section.title.toUpperCase(),
            videoUrl: content.answerValue ?? '',
            onVideoFinished: () {
              if (controller.currentPage.value == allSteps.length - 1) {
                Get.toNamed('/decouvert');
              } else {
                controller.nextPage();
              }
            },
          );
        }
        else if (content.answerType == "image") {
          stepWidget = StepDiscoveryImage(
            title: section.title.toUpperCase(),
            imageUrl: content.answerValue ?? '',
            answerText: content.questionValue,
          );
        }
        else {
          stepWidget = StepDiscoveryAudio(
            title: section.title.toUpperCase(),
            texteOriginal: content.questionValue,
            traduction: content.answerValue ?? '',
            lottie: 'assets/lottie/mascot.json',
          );
        }

        allSteps.add(
          DiscoveryStep(
            widget: stepWidget,
            sectionType: "lesson",
          ),
        );
      }
    }

    // 2. GESTION DES EXERCICES
    for (var section in languageData.exercises) {
      for (var content in section.contents) {
        if (content.options.isNotEmpty) {
          String correct = content.options
              .firstWhere(
                (o) => o.isCorrect,
                orElse: () => content.options[0],
              )
              .value;

          allSteps.add(
            DiscoveryStep(
              sectionType: "exercise",
              widget: StepQuizQCM(
                title: section.title.toUpperCase(),
                question: content.questionValue,
                options: content.options.map((o) => o.value).toList(),
                correctOption: correct,
                lottieQuestion: 'assets/lottie/mascot.json',
                lottieCorrect: 'assets/lottie/Happy mascot.json',
                lottieIncorrect: 'assets/lottie/Sad mascot.json',
                onContinue: () {
                  final bool isLastPage =
                      controller.currentPage.value == allSteps.length - 1;
                  if (isLastPage) {
                    Get.toNamed('/decouvert');
                  } else {
                    controller.nextPage();
                  }
                },
              ),
            ),
          );
        } else {
          allSteps.add(
            DiscoveryStep(
              sectionType: "exercise",
              widget: StepQuizDrag(
                title: section.title.toUpperCase(),
                choix: [
                  {
                    "nom": content.questionValue,
                    "traduction": "${content.answerValue ?? ''}",
                    "image": "assets/images/app/mere.png",
                  },
                ],
              ),
            ),
          );
        }
      }
    }

    if (allSteps.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text("Aucun contenu chargé."),
        ),
      );
    }

    void handleNext() {
      bool isLastPage = controller.currentPage.value == allSteps.length - 1;

      if (isLastPage) {
        Get.toNamed('/decouvert');
      } else {
        controller.nextPage();
      }
    }

    return ScreenUtilInit(
      designSize: const Size(360, 690),
      builder: (context, child) => Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF8F00), Color(0xFFFF8F00)],
              ),
            ),
          ),
          elevation: 0,
          centerTitle: true,
          title: Text(
            "Découvrir le ${languageData.language}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: Obx(
            () => IconButton(
              icon: Icon(
                controller.currentPage.value == 0
                    ? Icons.arrow_back_ios_new
                    : Icons.close,
                color: Colors.white,
                size: 20.sp,
              ),
              onPressed: () => Get.back(),
            ),
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
              child: Obx(() {
                double progress =
                    (controller.currentPage.value + 1) / allSteps.length;

                return ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8.h,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFFFF8F00),
                    ),
                  ),
                );
              }),
            ),

            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15.r,
                      offset: Offset(0, 5.h),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30.r),
                  child: PageView(
                    controller: controller.pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (index) {
                      controller.currentPage.value = index;
                    },
                    children: allSteps.map((step) => step.widget).toList(),
                  ),
                ),
              ),
            ),

            Obx(() {
              int currentIndex = controller.currentPage.value;
              bool isExercise =
                  allSteps[currentIndex].sectionType == "exercise";

              if (isExercise) {
                return const SizedBox.shrink();
              }

              return Padding(
                padding: EdgeInsets.fromLTRB(20.w, 15.h, 20.w, 25.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (currentIndex > 0)
                      SizedBox(
                        height: 40.h,
                        child: OutlinedButton.icon(
                          onPressed: controller.previousPage,
                          icon: Icon(Icons.arrow_back_ios, size: 14.sp),
                          label: const Text("Précédent"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFFF8F00),
                            side: const BorderSide(color: Color(0xFFFF8F00)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                        ),
                      )
                    else
                      const SizedBox.shrink(),

                    SizedBox(
                      height: 40.h,
                      child: ElevatedButton(
                        onPressed: handleNext,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF8F00),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 25.w),
                        ),
                        child: Row(
                          children: [
                            const Text(
                              "Suivant",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 8.w),
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
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}