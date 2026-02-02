import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class BienvenuPage extends StatelessWidget {
  const BienvenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
        child: Column(
          children: [
            const Spacer(),
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                  ),
                  child: const Text(
                    "Bienvenue sur LinguaLearn,\nLes langues de nos racines.\nChoisis tes langues.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 11,
                  child: Icon(Icons.arrow_drop_down,
                      color: Colors.grey.shade300, size: 30),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Lottie.asset(
              'assets/lottie/Sad mascot.json',
              width: 220,
              height: 220,
            ),
            const Spacer(flex: 2),
            ElevatedButton(
              onPressed: () => Get.toNamed('/selection'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 255, 127, 0),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 60),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                "CONTINUER",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
