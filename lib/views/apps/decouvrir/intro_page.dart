import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:lottie/lottie.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
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
                'assets/lottie/mascot.json',
                width: 150,
                repeat: true,
              ),
      
              const SizedBox(height: 20),
      
              const Text(
                "LINGUALEARN",
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
                  "Apprendre la langue nationale d’un pays, c’est ouvrir la porte à son âme, à sa culture et à de vraies connexions avec son peuple",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),
              ),
      
              const SizedBox(height: 50),
      
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: ElevatedButton(
                  onPressed: ()=> 
                    Get.toNamed('/step'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:  const Color.fromARGB(192,255, 127, 0),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    "C'EST PARTI !",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}