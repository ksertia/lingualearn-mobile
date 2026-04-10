import 'package:fasolingo/controller/apps/discovery_controller.dart';
import 'package:fasolingo/models/langue/decouverte_model.dart';
import 'package:fasolingo/widgets/decouvrir_page/decouverte/StepDiscoveryVideo.dart';
import 'package:fasolingo/widgets/decouvrir_page/decouverte/StepQuizDrag.dart';
import 'package:fasolingo/widgets/decouvrir_page/decouverte/StepQuizQCM.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// Vérifie bien que ce fichier contient la classe LanguageData
import 'package:fasolingo/models/langue/decouvert_langue.dart';
import 'package:fasolingo/widgets/decouvrir_page/decouverte/StepDiscoveryAudio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DiscoveryPage extends StatelessWidget {
  const DiscoveryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final dynamic args = Get.arguments;
    final LanguageData languageData =
        args is LanguageData ? args : LanguageData(lessons: [], exercises: []);

    final String selectedLanguage = _getSelectedLanguage(languageData);
    final DiscoveryController controller = Get.put(DiscoveryController());

    return ScreenUtilInit(
      designSize: const Size(360, 690),
      builder: (context, child) => Scaffold(
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
            "Découvrir le $selectedLanguage",
            style: const TextStyle(
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
                  size: 20.sp,
                ),
                onPressed: () => Get.back(),
              )),
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
              child: Obx(() => ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: LinearProgressIndicator(
                      value: controller.progress,
                      minHeight: 8.h,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFFFF8F00),
                      ),
                    ),
                  )),
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
                    onPageChanged: (index) =>
                        controller.currentPage.value = index,
                    children: [
                      StepDiscoveryAudio(
                        title: "RÉPÈTE APRÈS MOI",
                        texteOriginal: "Ne yibeogo, yamba laafi ?",
                        traduction: "Bonjour, comment allez-vous ?",
                        lottie: 'assets/lottie/Sad mascot.json',
                      ),
                      StepDiscoveryAudio(
                        title: "RÉPÈTE APRÈS MOI",
                        texteOriginal: "Ne y tūūma, Wend na sõng-y.",
                        traduction: "Bon travail, que Dieu vous aide.",
                        lottie: 'assets/lottie/Sad mascot.json',
                      ),
                      StepDiscoveryAudio(
                        title: "RÉPÈTE APRÈS MOI",
                        texteOriginal: "Yãmb modga woto!",
                        traduction: "Vous avez fait beaucoup d'efforts !",
                        lottie: "assets/lottie/Lion.json",
                      ),
                      StepDiscoveryVideo(
                        videoTitle: "OBSERVE ATTENTIVEMENT",
                        videoUrl: "assets/images/video/videos.mp4",
                        onVideoFinished: () => controller.nextPage(),
                      ),
                      const StepQuizQCM(
                        title: "CHOISIS LA BONNE RÉPONSE",
                        question: "Comment dire 'Bon travail'",
                        options: [
                          "Sukuuri",
                          "Naaba yiri",
                          "Ne y tūūma",
                          "Burindi"
                        ],
                        correctOption: "Ne y tūūma",
                        lottieQuestion: 'assets/lottie/mascot.json',
                        lottieCorrect: 'assets/lottie/Happy mascot.json',
                        lottieIncorrect: 'assets/lottie/Sad mascot.json',
                      ),
                      const StepQuizQCM(
                        title: "CHOISIS LA BONNE RÉPONSE",
                        question: "Comment dit-on 'Bonjour'",
                        options: [
                          "Ne yibeogo",
                          "yambe modga",
                          "Mobilli",
                          "yamba laafi"
                        ],
                        correctOption: "Ne yibeogo",
                        lottieQuestion: 'assets/lottie/mascot.json',
                        lottieCorrect: 'assets/lottie/Happy mascot.json',
                        lottieIncorrect: 'assets/lottie/Sad mascot.json',
                      ),
                      StepQuizDrag(
                        title: "TIRE LE MOT VERS LA BONNE RÉPONSE",
                        choix: [
                          {
                            "nom": "Maam",
                            "traduction": "MERE",
                            "image": "assets/images/app/mere.png"
                          },
                          {
                            "nom": "Saam",
                            "traduction": "FRERE",
                            "image": "assets/images/app/frere.png"
                          },
                          {
                            "nom": "Baam",
                            "traduction": "PERE",
                            "image": "assets/images/app/papa.png"
                          },
                          {
                            "nom": "Taam",
                            "traduction": "SOEUR",
                            "image": "assets/images/app/soeur.png"
                          },
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Obx(() {
              if (controller.currentPage.value < 4) {
                return Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 15.h, 20.w, 25.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (controller.currentPage.value > 0)
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
                                  borderRadius: BorderRadius.circular(10.r)),
                            ),
                          ),
                        )
                      else
                        const SizedBox.shrink(),
                      SizedBox(
                        height: 40.h,
                        child: ElevatedButton(
                          onPressed: controller.nextPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF8F00),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r)),
                            padding: EdgeInsets.symmetric(horizontal: 25.w),
                          ),
                          child: Row(
                            children: [
                              const Text("Suivant",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(width: 8.w),
                              Icon(Icons.arrow_forward_ios,
                                  size: 14.sp, color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            }),
          ],
        ),
      ),
    );
  }

  String _getSelectedLanguage(LanguageData languageData) {
    if (languageData.lessons.isNotEmpty &&
        languageData.lessons.first.language.isNotEmpty) {
      return languageData.lessons.first.language;
    }
    if (languageData.exercises.isNotEmpty &&
        languageData.exercises.first.language.isNotEmpty) {
      return languageData.exercises.first.language;
    }
    return 'langue';
  }
}
