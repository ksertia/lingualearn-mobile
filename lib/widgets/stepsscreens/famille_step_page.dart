import 'package:fasolingo/controller/apps/discovery_controller.dart';
import 'package:fasolingo/widgets/decouvrir_page/decouverte/StepDiscoveryAudio.dart';
import 'package:fasolingo/widgets/decouvrir_page/decouverte/StepDiscoveryVideo.dart';
import 'package:fasolingo/widgets/decouvrir_page/decouverte/StepQuizQCM.dart';
import 'package:fasolingo/widgets/etapefamille/quiz_clic.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fasolingo/widgets/etapefamille/image_famille.dart';

class FamilleStepPage extends StatelessWidget {
  final dynamic data;

  const FamilleStepPage({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    // Initialisation du contrôleur
    final DiscoveryController controller = Get.put(DiscoveryController());

    // --- LOGIQUE DE FIN D'ÉTAPE ---
    // On surveille la progression. Si on dépasse l'index du dernier quiz (index 6), on ferme.
    once(controller.currentPage, (int index) {
      if (index > 6) {
        Get.back();
        Get.snackbar(
          "Bravo !",
          "Tu as terminé l'étape !",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    });

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
          title: const Text(
            "Les membres de la famille",
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          leading: Obx(() => IconButton(
            icon: Icon(
              controller.currentPage.value == 0 ? Icons.arrow_back_ios_new : Icons.close,
              color: Colors.white,
              size: 20.sp,
            ),
            onPressed: () => Get.back(),
          )),
        ),

        body: Column(
          children: [
            // ProgressBar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
              child: Obx(() => ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: LinearProgressIndicator(
                  value: controller.progress,
                  minHeight: 8.h,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF8F00)),
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
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15.r, offset: Offset(0, 5.h)),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30.r),
                  child: PageView(
                    controller: controller.pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (index) => controller.currentPage.value = index,
                    children: [
                      const StepDiscoveryAudio(
                        texteOriginal: "Bonjour papa",
                        traduction: "i ni sogoma baba",
                        lottie: "assets/lottie/elephant.json",
                      ),
                      const StepDiscoveryAudio(
                        texteOriginal: "Bonsoir maman",
                        traduction: "i ni wula baa",
                        lottie: "assets/lottie/elephant.json",
                      ),
                      StepDiscoveryVideo(
                        videoTitle: "OBSERVE ATTENTIVEMENT",
                        videoUrl: "assets/images/video/videos.mp4",
                        onVideoFinished: () => controller.nextPage(),
                      ),
                      StepFamilyImages(
                        items: [
                          {"image": "assets/images/app/mere1.jpg", "texte": "Mère", "traduction": "Baa", "audio": "audio/mother.mp3"},
                          {"image": "assets/images/app/pere1.jpg", "texte": "Père", "traduction": "Baba", "audio": "audio/father.mp3"},
                          {"image": "assets/images/app/bebe.jpg", "texte": "Bébé", "traduction": "dennenin", "audio": "audio/baby.mp3"},
                          {"image": "assets/images/app/vieux.jpg", "texte": "Vieux", "traduction": "Cekoronin", "audio": "audio/old_man.mp3"},
                        ],
                      ),
                      StepQuizSelectionImages(
                        choix: [
                          {"image": "assets/images/app/mere1.jpg", "nom": "Baa", "traduction": "Mère"},
                          {"image": "assets/images/app/pere1.jpg", "nom": "Baba", "traduction": "Père"},
                          {"image": "assets/images/app/bebe.jpg", "nom": "Dennenin", "traduction": "Bébé"},
                          {"image": "assets/images/app/vieux.jpg", "nom": "Cekoronin", "traduction": "Vieux"},
                        ],
                        onFinished: () => controller.nextPage(),
                      ),
                      const StepQuizQCM(
                        question: "Comment dit-on 'Ainé'",
                        options: ["Soo", "Banbunan", "Koro", "Bilakoro"],
                        correctOption: "Koro",
                        lottieQuestion: 'assets/lottie/mascot.json',
                        lottieCorrect: 'assets/lottie/Happy mascot.json',
                        lottieIncorrect: 'assets/lottie/Sad mascot.json',
                      ),
                      const StepQuizQCM(
                        question: "Comment dit-on 'Oncle paternel'",
                        options: ["Fakoroba", "Bako", "Abarika", "Demeni"],
                        correctOption: "Fakoroba",
                        lottieQuestion: 'assets/lottie/mascot.json',
                        lottieCorrect: 'assets/lottie/Happy mascot.json',
                        lottieIncorrect: 'assets/lottie/Sad mascot.json',
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Navigation
            Obx(() {
              int currentIndex = controller.currentPage.value;
              if (currentIndex >= 4) return const SizedBox(height: 25);

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
                          label: Text("Précédent"),
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
                            Text("Suivant",
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
            }),
          ],
        ),
      ),
    );
  }
}