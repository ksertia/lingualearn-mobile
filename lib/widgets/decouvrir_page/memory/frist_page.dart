import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class StepMemorise extends StatelessWidget {
  final String titre;
  final String texteAMemoriser;
  final String? imagePath;

  const StepMemorise({
    super.key,
    required this.titre,
    required this.texteAMemoriser,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1.5),
        ),
        child: Column(
          children: [
            const SizedBox(height: 15),
            
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
                      titre.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 14,
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

            Lottie.asset(
              'assets/lottie/study.json',
              width: MediaQuery.of(context).size.width * 0.7,
              fit: BoxFit.contain,
              repeat: true,
            ),

            const Spacer(),

            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey.shade300, width: 2),
                      ),
                      child: Text(
                        texteAMemoriser,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  GestureDetector(
                    onTap: () {
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.volume_up_rounded,
                        color: Colors.blueAccent,
                        size: 28,
                      ),
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