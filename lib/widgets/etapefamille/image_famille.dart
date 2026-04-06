import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StepFamilyImages extends StatefulWidget {
  final List<Map<String, String>> items;

  const StepFamilyImages({
    super.key,
    required this.items,
  });

  @override
  State<StepFamilyImages> createState() => _StepFamilyImagesState();
}

class _StepFamilyImagesState extends State<StepFamilyImages> {
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playSound(String? audioPath) async {
    if (audioPath != null && audioPath.isNotEmpty) {
      try {
        await _audioPlayer.stop();
        await _audioPlayer.play(AssetSource(audioPath));
      } catch (e) {
        debugPrint("Erreur lors de la lecture audio : $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          SizedBox(height: 20.h),

          // --- HEADER ---
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.volume_up, color: Colors.orange, size: 22.sp),
              SizedBox(width: 8.w),
              Text(
                "REGARDE ET ÉCOUTE",
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w900,
                  color: Colors.grey[600],
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),

          SizedBox(height: 20.h),

          // --- GRID ---
          Expanded(
            child: GridView.builder(
              itemCount: widget.items.length,
              physics: const BouncingScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
                childAspectRatio: 0.82, // Ratio ajusté pour accueillir le texte sous l'image
              ),
              itemBuilder: (context, index) {
                final item = widget.items[index];

                return _buildCard(
                  image: item["image"] ?? "",
                  title: item["texte"] ?? "",       // Exemple: "Mère"
                  translation: item["traduction"] ?? "", // Exemple: "Baa"
                  audioPath: item["audio"] ?? "",
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String image,
    required String title,
    required String translation,
    required String audioPath,
  }) {
    return GestureDetector(
      onTap: () => _playSound(audioPath),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // --- SECTION IMAGE ---
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      image,
                      fit: BoxFit.cover,
                    ),
                    // Petit indicateur audio discret en haut à droite
                    Positioned(
                      top: 8.h,
                      right: 8.w,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.play_arrow_rounded, color: Colors.orange, size: 18.sp),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- SECTION TEXTE (Mère / Baa) ---
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 5.w),
              child: Column(
                children: [
                  Text(
                    title, // Texte en français
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    translation, // Traduction en Moore
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}