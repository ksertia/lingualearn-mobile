import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fasolingo/controller/apps/discovery_controller.dart';
import 'package:lottie/lottie.dart';

class StepQuizAudio extends StatefulWidget {
  final String correctWord;
  final List<String> options;

  const StepQuizAudio({
    super.key,
    required this.correctWord,
    required this.options,
  });

  @override
  State<StepQuizAudio> createState() => _StepQuizAudioState();
}

class _StepQuizAudioState extends State<StepQuizAudio> {
  final DiscoveryController controller = Get.find();
  bool isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 15, offset: const Offset(0, 8))
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 30),

                          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  Lottie.asset(
                    'assets/lottie/Happy mascot.json',
                    width: 60,
                    height: 60,
                    repeat: true,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "ÉCOUTE ATTENTIVEMENT", 
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const Spacer(),

            GestureDetector(
              onTap: () {
                setState(() => isPlaying = true);
                Future.delayed(const Duration(seconds: 1), () => setState(() => isPlaying = false));
              },
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                  border: Border.all(color: Color.fromARGB(255, 0, 0, 153), width: 4),
                ),
                child: Center(
                  child: Icon(
                    isPlaying ? Icons.graphic_eq_rounded : Icons.play_arrow_rounded,
                    size: 80,
                    color: Color.fromARGB(255, 0, 0, 153),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text("Appuie pour écouter", style: TextStyle(color: Colors.grey)),

            const Spacer(),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: widget.options.map((option) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => controller.selectResponse(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          side: BorderSide(color: Colors.grey.shade300, width: 2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        child: Text(option, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}