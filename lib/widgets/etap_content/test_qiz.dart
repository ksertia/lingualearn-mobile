import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:audioplayers/audioplayers.dart';

class TestQiz extends StatefulWidget {
  final String question;
  final List<String> options;
  final String correctOption;
  final String? audioUrl;
  final Function(bool) onValidated;

  const TestQiz({
    super.key,
    required this.question,
    required this.options,
    required this.correctOption,
    this.audioUrl,
    required this.onValidated,
  });

  @override
  State<TestQiz> createState() => _TestQizState();
}

class _TestQizState extends State<TestQiz> {
  String? selectedOption;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          const Spacer(flex: 1), // Pousse le contenu vers le centre

          // --- SECTION AUDIO ---
          if (widget.audioUrl != null) ...[
            GestureDetector(
              onTap: () async => await _audioPlayer.play(AssetSource(widget.audioUrl!)),
              child: Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.orange, width: 2.w),
                ),
                child: Icon(Icons.volume_up, size: 45.sp, color: Colors.orange),
              ),
            ),
            SizedBox(height: 10.h),
          ],

          // --- LA QUESTION ---
          Text(
            widget.question,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          const Spacer(flex: 1),

          // --- LES OPTIONS (Remplacé ListView par Column pour bloquer le scroll) ---
          Column(
            children: widget.options.map((option) {
              final isSelected = selectedOption == option;
              return GestureDetector(
                onTap: () => setState(() => selectedOption = option),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.only(bottom: 12.h),
                  padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 20.w),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFE3F2FD) : Colors.white,
                    borderRadius: BorderRadius.circular(15.r),
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey.shade300,
                      width: isSelected ? 2.w : 1.w,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 20.w,
                        height: 20.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.blue : Colors.grey,
                            width: 2.w,
                          ),
                          color: isSelected ? Colors.blue : Colors.transparent,
                        ),
                        child: isSelected
                            ? Icon(Icons.check, size: 14.sp, color: Colors.white)
                            : null,
                      ),
                      SizedBox(width: 15.w),
                      Expanded(
                        child: Text(
                          option,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Colors.blue.shade700 : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          const Spacer(flex: 2), // Plus d'espace avant le bouton de validation

          // --- BOUTON DE VALIDATION ---
          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: ElevatedButton(
              onPressed: selectedOption == null
                  ? null
                  : () {
                bool isCorrect = selectedOption == widget.correctOption;
                widget.onValidated(isCorrect);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
                elevation: 0,
              ),
              child: Text(
                "VÉRIFIER",
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}