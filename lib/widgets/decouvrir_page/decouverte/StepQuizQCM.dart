import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fasolingo/controller/apps/discovery_controller.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StepQuizQCM extends StatefulWidget {
  final String question;
  final List<String> options;
  final String lottie;

  const StepQuizQCM({
    super.key,
    required this.question,
    required this.options,
    required this.lottie,
  });

  @override
  State<StepQuizQCM> createState() => _StepQuizQCMState();
}

class _StepQuizQCMState extends State<StepQuizQCM> {
  final DiscoveryController controller = Get.find();
  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Zone de contenu scrollable
        SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 20.h),

              Text(
                "CHOISIS LA BONNE RÉPONSE",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                  letterSpacing: 0.5,
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                child: Lottie.asset(
                  widget.lottie,
                  height: 120.h,
                  repeat: true,
                ),
              ),

              // --- BOX QUESTION AVEC RETOUR À LA LIGNE ---
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(15.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15.r),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFF000099),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.volume_up, size: 22, color: Colors.white),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      // ✅ Expanded règle le problème du bandeau jaune (overflow)
                      Expanded(
                        child: Text(
                          widget.question,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              // --- GRILLE DES OPTIONS ---
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.options.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10.w,
                    mainAxisSpacing: 10.h,
                    childAspectRatio: 2.2,
                  ),
                  itemBuilder: (context, index) {
                    bool isSelected = selectedIndex == index;

                    return InkWell(
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                        });
                        controller.selectResponse();
                      },
                      borderRadius: BorderRadius.circular(15.r),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF000099).withOpacity(0.05)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(15.r),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF000099)
                                : Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          widget.options[index],
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? const Color(0xFF000099) : Colors.black87,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 100.h),
            ],
          ),
        ),

        Positioned(
          bottom: 20.h,
          left: 20.w,
          right: 20.w,
          child: SizedBox(
            width: double.infinity,
            height: 55.h,
            child: ElevatedButton(
              onPressed: selectedIndex != null 
                  ? () {
                      print("Validé avec l'index: $selectedIndex");
                    } 
                  : null, 
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9800), 
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.r),
                ),
                elevation: 0,
              ),
              child: Text(
                "VALIDER",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}