import 'package:confetti/confetti.dart'; 
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class StepSuccess extends StatelessWidget {
  final ConfettiController confettiController;

  const StepSuccess({super.key, required this.confettiController});

  @override
  Widget build(BuildContext context) {
    return Stack( 
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30.r),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/lottie/Happy mascot.json',
                width: 220.w,
                repeat: true,
              ),
              SizedBox(height: 10.h),
              Text(
                "FELICITATION !",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF58CC02),
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 15.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.w),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: Colors.black87,
                      height: 1.6,
                    ),
                    children: [
                      const TextSpan(text: "Tu as un talent naturel. 🌟\n"),
                      TextSpan(
                        text: "Inscris-toi maintenant pour enregistrer tes progrès et débloquer tout le parcours d'apprentissage.",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 40.h),
              Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 55.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.r),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF8F00).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () => Get.toNamed('/register'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF8F00),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        "COMMENCER L'AVENTURE",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  TextButton(
                    onPressed: () => Get.toNamed('/login'),
                    style: TextButton.styleFrom(
                      foregroundColor:  const Color.fromARGB(180, 158, 158, 158),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "J'ai déjà un compte",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 5.w),
                        Icon(Icons.arrow_forward, size: 16.sp),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: confettiController,
            blastDirectionality: BlastDirectionality.explosive, 
            shouldLoop: false,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple,
              Colors.yellow,
            ], 
            gravity: 0.1,
          ),
        ),
      ],
    );
  }
}