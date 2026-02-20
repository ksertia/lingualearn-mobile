import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:lottie/lottie.dart';

class StepSuccess extends StatelessWidget {
  const StepSuccess({super.key});

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
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Lottie.asset(
              'assets/lottie/Cute teddy bear with a gift.json',
              width: 250,
              repeat: true,
            ),

            const SizedBox(height: 20),

            const Text(
              "FÉLICITATIONS !",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color:  Color.fromARGB(255, 0, 0, 153),
                letterSpacing: 1.5,
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              child: Text(
                "vous avez terminé votre première leçon avec succès. Es-tu prêt à devenir un pro en langues ?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 30),

            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: ElevatedButton(
                    onPressed: ()=> 
                      Get.toNamed('/register'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:  const Color.fromARGB(192,255, 127, 0),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      elevation: 5,
                    ),
                    child: const Text(
                      "CRÉER MON COMPTE",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                TextButton(onPressed: () => Get.toNamed('/login'), child: const Text("Retour à la connexion", style: TextStyle(color: Colors.black54)))
              ],
            ),
          ],
        ),
      ),
    );
  }
}