import 'package:fasolingo/controller/apps/discovery_controller.dart';
import 'package:fasolingo/widgets/decouvrir_page/decouverte/StepDiscoveryVideo.dart';
import 'package:fasolingo/widgets/decouvrir_page/decouverte/StepQuizDrag.dart';
import 'package:fasolingo/widgets/decouvrir_page/decouverte/StepQuizQCM.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fasolingo/models/langue/decouvert_langue.dart';
import 'package:fasolingo/widgets/decouvrir_page/decouverte/StepDiscoveryAudio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DiscoveryPage extends StatelessWidget {
  const DiscoveryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final LanguageDiscover language = Get.arguments;
    final DiscoveryController controller = Get.put(DiscoveryController());

    return ScreenUtilInit(
      designSize: const Size(360, 690),
      builder: (context, child) => Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),

        appBar: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF8F00),Color(0xFFFF8F00)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          elevation: 0,
          centerTitle: true,
          title: Text(
            "Découvrir le ${language.name}",
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

            // PROGRESS BAR
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

            // CONTENT
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
                        texteOriginal: "Ne yibeogo, yamba laafi ?",
                        traduction: "Bonjour, comment allez-vous ?",
                        lottie: 'assets/lottie/Sad mascot.json',
                      ),
                      StepDiscoveryAudio(
                        texteOriginal: "Ne y tūūma, Wend na sõng-y.",
                        traduction: "Bon travail, que Dieu vous aide.",
                        lottie: 'assets/lottie/Sad mascot.json',
                      ),
                      StepDiscoveryAudio(
                        texteOriginal: "Yãmb modga woto!",
                        traduction: "Vous avez fait beaucoup d'efforts !",
                        lottie: "assets/lottie/Lion.json",
                      ),

                      StepDiscoveryVideo(
                        videoTitle: "OBSERVE ATTENTIVEMENT",
                        videoUrl:
                            "assets/images/video/videos.mp4",
                        onVideoFinished: () => controller.nextPage(),
                      ),

                      const StepQuizQCM(
                        question: "Comment dit-on 'École'",
                        options: ["Sukuuri", "Yiri", "Mobilli", "Burindi"],
                        lottie: 'assets/lottie/Sad mascot.json',
                      ),
                      const StepQuizQCM(
                        question: "Que signifie 'Fofo' ?",
                        options: ["Merci", "Bonjour", "Au revoir", "Pardon"],
                        lottie: 'assets/lottie/Sad mascot.json',
                      ),

                      StepQuizDrag(
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

            Obx(() => controller.currentPage.value < 4
                ? Padding(
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
                              label: Text(
                                "Précédent",
                                style: TextStyle(fontSize: 14.sp),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor:  Color(0xFFFF8F00),
                                side: const BorderSide(
                                    color: Color(0xFFFF8F00)),
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
                            onPressed: controller.nextPage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF8F00),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              padding:
                                  EdgeInsets.symmetric(horizontal: 25.w),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  controller.currentPage.value == 2
                                      ? "FINIR"
                                      : "Suivant",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 14.sp,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
}