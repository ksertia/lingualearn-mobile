import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fasolingo/controller/apps/discovery_controller.dart';
import 'package:lottie/lottie.dart';

class StepQuizFill extends StatefulWidget {
  final String phraseDebut; 
  final String phraseFin; 
  final List<String> options;

  const StepQuizFill({
    super.key,
    required this.phraseDebut,
    required this.phraseFin,
    required this.options,
  });

  @override
  State<StepQuizFill> createState() => _StepQuizFillState();
}

class _StepQuizFillState extends State<StepQuizFill> {
  final DiscoveryController controller = Get.find();
  String? reponseChoisie;

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
             SizedBox(height: 30),

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
                      "COMPLETE LA PHRASE",
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
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(widget.phraseDebut, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Color.fromARGB(255, 0, 0, 153), width: 3)),
                    ),
                    child: Text(
                      reponseChoisie ?? "________",
                      style: TextStyle(fontSize: 24, color: Color.fromARGB(255, 0, 0, 153), fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(widget.phraseFin, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
                ],
              ),
            ),

             Spacer(),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 15,
                  childAspectRatio: 2.5,
                ),
                itemCount: widget.options.length,
                itemBuilder: (context, index) {
                  return ElevatedButton(
                    onPressed: () {
                      setState(() {
                        reponseChoisie = widget.options[index];
                      });
                      controller.selectResponse();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor:Color.fromARGB(255, 0, 0, 153),
                      elevation: 2,
                      side: const BorderSide(color: Color.fromARGB(255, 0, 0, 153), width: 1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: Text(widget.options[index], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}