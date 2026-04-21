// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart'; // IMPORTANT
// import 'package:get/get.dart';
// import 'package:lottie/lottie.dart';
// import 'package:audioplayers/audioplayers.dart';
// import 'package:fasolingo/widgets/etap_content/test_qiz.dart';
// import 'package:fasolingo/widgets/etap_content/test_step_image.dart';
// import 'package:fasolingo/controller/apps/discovery_controller.dart';
// import '../decouvrir_page/decouverte/StepDiscoveryVideo.dart';

// class TestStepPage extends StatelessWidget {
//   final dynamic data;
//   const TestStepPage({super.key, required this.data});

//   @override
//   Widget build(BuildContext context) {
//     final DiscoveryController controller = Get.put(DiscoveryController());
//     final AudioPlayer player = AudioPlayer();

//     // On initialise ScreenUtil ici pour que .w, .h et .sp fonctionnent
//     return ScreenUtilInit(
//       designSize: const Size(360, 690),
//       minTextAdapt: true,
//       builder: (context, child) => Scaffold(
//         backgroundColor: const Color(0xFFF5F5F5),
//         appBar: AppBar(
//           backgroundColor: Colors.orange,
//           elevation: 0,
//           title: Text(
//               "Chiffres en Dioula",
//               style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20.sp)
//           ),
//           centerTitle: true,
//           leading: IconButton(
//             icon: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20.sp),
//             onPressed: () => Get.back(),
//           ),
//         ),
//         body: Column(
//           children: [
//             // Barre de progression agrandie
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
//               child: Obx(() => ClipRRect(
//                 borderRadius: BorderRadius.circular(10.r),
//                 child: LinearProgressIndicator(
//                   value: controller.progress,
//                   minHeight: 12.h,
//                   backgroundColor: Colors.grey[300],
//                   valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
//                 ),
//               )),
//             ),

//             Expanded(
//               child: Container(
//                 margin: EdgeInsets.symmetric(horizontal: 16),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(30),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.05),
//                       blurRadius: 15,
//                       offset: Offset(0, 5),
//                     ),
//                   ],
//                 ),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(30),
//                   child: PageView(
//                     controller: controller.pageController,
//                     physics: const NeverScrollableScrollPhysics(),
//                     onPageChanged: (index) => controller.currentPage.value = index,
//                     children: [
//                       TestStepImage(
//                         count: 1,
//                         text: "Kèlèn = Un",
//                         onPlayAudio: () async => await player.play(AssetSource('audio/one.mp3')),
//                       ),
//                       TestStepImage(
//                         count: 2,
//                         text: "Fla = Deux",
//                         onPlayAudio: () async => await player.play(AssetSource('audio/two.mp3')),
//                       ),
//                       TestStepImage(
//                         count: 3,
//                         text: "Saba = Trois",
//                         onPlayAudio: () async => await player.play(AssetSource('audio/three.mp3')),
//                       ),
//                       TestStepImage(
//                         count: 4,
//                         text: "Nani = Quatre",
//                         onPlayAudio: () async => await player.play(AssetSource('audio/four.mp3')),
//                       ),
//                       StepDiscoveryVideo(
//                         videoTitle: "OBSERVE ATTENTIVEMENT",
//                         videoUrl: "",
//                         onVideoFinished: () => controller.nextPage(),
//                       ),
//                       TestQiz(
//                         question: "Comment dit-on '2' en Dioula ?",
//                         options: const ["Kèlèn", "Fla", "Saba", "Nani"],
//                         correctOption: "Fla",
//                         onValidated: (isCorrect) => _showBottomValidation(isCorrect, controller),
//                       ),
//                       TestQiz(
//                         question: "Comment dit-on '3' en Dioula ?",
//                         options: const ["Kèlèn", "Fla", "Saba", "Nani"],
//                         correctOption: "Saba",
//                         onValidated: (isCorrect) => _showBottomValidation(isCorrect, controller),
//                       ),
//                       TestQiz(
//                         audioUrl: "audio/three.mp3", // Chemin vers ton fichier audio
//                         question: "Quel chiffre avez-vous entendu ?",
//                         options: const ["Un", "Deux", "Trois", "Quatre"],
//                         correctOption: "Trois",
//                         onValidated: (isCorrect) => _showBottomValidation(isCorrect, controller),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(height: 25.h),

//             // Navigation agrandie
//             Obx(() => controller.currentPage.value < 5 // Ajuste l'index selon tes pages
//                 ? _buildNav(controller)
//                 : SizedBox(height: 20.h)
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildNav(DiscoveryController controller) {
//     return Padding(
//       padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 35.h),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           if (controller.currentPage.value > 0)
//             SizedBox(
//               height: 45.h,
//               child: OutlinedButton(
//                 onPressed: controller.previousPage,
//                 style: OutlinedButton.styleFrom(
//                   side: const BorderSide(color: Colors.orange, width: 2),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
//                 ),
//                 child: Text("Précédent", style: TextStyle(color: Colors.orange, fontSize: 16.sp, fontWeight: FontWeight.bold)),
//               ),
//             ),
//           const Spacer(),
//           SizedBox(
//             height: 45.h,
//             child: ElevatedButton(
//               onPressed: controller.nextPage,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.orange,
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
//                 padding: EdgeInsets.symmetric(horizontal: 40.w),
//               ),
//               child: Text("Suivant", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.sp)),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showBottomValidation(bool isCorrect, DiscoveryController controller) {
//     Get.bottomSheet(
//       Container(
//         padding: EdgeInsets.all(20.w),
//         height: 240.h,
//         decoration: BoxDecoration(
//           color: isCorrect ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
//           borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
//         ),
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 SizedBox(
//                   height: 90.h,
//                   width: 90.w,
//                   child: Lottie.asset(
//                     isCorrect ? 'assets/lottie/Happy mascot.json' : 'assets/lottie/Sad mascot.json',
//                   ),
//                 ),
//                 SizedBox(width: 15.w),
//                 Expanded(
//                   child: Text(
//                     isCorrect ? "C'est juste ! Bravo !" : "Oups ! Ce n'est pas ça.",
//                     style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: isCorrect ? Colors.green[800] : Colors.red[800]),
//                   ),
//                 ),
//               ],
//             ),
//             const Spacer(),
//             SizedBox(
//               width: double.infinity,
//               height: 55.h,
//               child: ElevatedButton(
//                 onPressed: () {
//                   Get.back();
//                   if (isCorrect) controller.nextPage();
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: isCorrect ? Colors.green : Colors.red,
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
//                 ),
//                 child: Text(isCorrect ? "CONTINUER" : "RÉESSAYER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18.sp)),
//               ),
//             ),
//           ],
//         ),
//       ),
//       isDismissible: false,
//       enableDrag: false,
//     );
//   }
// }