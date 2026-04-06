import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TestStepImage extends StatelessWidget {
  final int count;
  final String text;
  final VoidCallback onPlayAudio;

  const TestStepImage({
    super.key,
    required this.count,
    required this.text,
    required this.onPlayAudio,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center, // Centre verticalement
          children: [
            SizedBox(height: 10.h),
            Text(
              "REGARDE ET ÉCOUTE",
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16.sp,
                color: const Color(0xFFB47C3C),
                letterSpacing: 1.2,
              ),
            ),

            const Spacer(), // Espace flexible

            // --- CARTE CENTRALE ---
            // On utilise FittedBox pour que la carte diminue si l'écran est petit
            Center(
              child: SizedBox(
                width: 290.w,
                height: 290.w,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30.r),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 20,
                              offset: Offset(0, 10)
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30.r),
                        child: Image.asset(
                          "assets/images/app/plan5.jpg",
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "$count",
                          style: TextStyle(
                            fontSize: 90.sp,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            shadows: const [Shadow(color: Colors.black45, blurRadius: 15)],
                          ),
                        ),
                        Wrap(
                          spacing: 5.w,
                          runSpacing: 5.h,
                          alignment: WrapAlignment.center,
                          children: List.generate(count, (index) =>
                              Image.asset("assets/images/app/pomme.jpg", width: 60.w)
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      bottom: -20.h,
                      child: GestureDetector(
                        onTap: onPlayAudio,
                        child: Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8BC34A),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.black26, blurRadius: 10, offset: const Offset(0, 4))
                            ],
                          ),
                          child: Icon(Icons.volume_up, color: Colors.white, size: 30.sp),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(), // Espace flexible

            // --- BLOC TRADUCTION ---
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Material(
                elevation: 3,
                shadowColor: Colors.black12,
                borderRadius: BorderRadius.circular(25.r),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(15.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25.r),
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "TRADUCTION",
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      FittedBox( // Empêche le texte de dépasser si la phrase est longue
                        fit: BoxFit.scaleDown,
                        child: Text(
                          text,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 20.h),
          ],
        );
      },
    );
  }
}