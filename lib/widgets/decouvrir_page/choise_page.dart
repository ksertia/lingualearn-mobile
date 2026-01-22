import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fasolingo/controller/apps/discovery_controller.dart';
import 'package:lottie/lottie.dart';

class StepQuiz extends StatefulWidget {
  final String question;
  final List<String> options;

  const StepQuiz({
    super.key,
    required this.question,
    required this.options,
  });

  @override
  State<StepQuiz> createState() => _StepQuizState();
}

class _StepQuizState extends State<StepQuiz> {
  final DiscoveryController controller = Get.find();
  int? selectedIndex; 

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
          children: [
            const SizedBox(height: 20),
            
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
                      "CHOISIS LA BONNE RÉPONSE",
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

            Lottie.asset(
              'assets/lottie/Male 01.json',
              height: 150,
            ),

            const Spacer(),

                Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Text(
                widget.question,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: List.generate(widget.options.length, (index) {
                  bool isSelected = selectedIndex == index;
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                        });

                        controller.selectResponse();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.greenAccent.withOpacity(0.3) : Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: isSelected ? Colors.green : Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          widget.options[index],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? Colors.green.shade900 : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}