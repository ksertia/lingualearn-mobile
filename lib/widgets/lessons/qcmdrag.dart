import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fasolingo/controller/apps/discovery_controller.dart';
import 'package:lottie/lottie.dart';

class StepQuizTranslate extends StatefulWidget {
  final String question;
  final List<String> words;
  final String correctFullSentence;
  final String lottieQuestion;
  final String lottieCorrect;
  final String lottieIncorrect;

  const StepQuizTranslate({
    super.key,
    required this.question,
    required this.words,
    required this.correctFullSentence,
    required this.lottieQuestion,
    required this.lottieCorrect,
    required this.lottieIncorrect,
  });

  @override
  State<StepQuizTranslate> createState() => _StepQuizTranslateState();
}

class _StepQuizTranslateState extends State<StepQuizTranslate> {
  final DiscoveryController controller = Get.find();
  
  List<String> selectedWords = []; 
  List<String> availableWords = []; 
  String? currentLottie;
  bool hasValidated = false;

  @override
  void initState() {
    super.initState();
    currentLottie = widget.lottieQuestion;
    availableWords = List.from(widget.words);
  }

  void _showResultBottomSheet(bool isCorrect) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isCorrect ? const Color(0xFFD7FFB8) : const Color(0xFFFFDFE0),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(isCorrect ? Icons.check_circle : Icons.cancel,
                      color: isCorrect ? const Color(0xFF58CC02) : const Color(0xFFEE2B2B), size: 35),
                  const SizedBox(width: 12),
                  Text(isCorrect ? "Excellent !" : "Oups !",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, 
                      color: isCorrect ? const Color(0xFF58CC02) : const Color(0xFFEE2B2B))),
                ],
              ),
              if (!isCorrect) ...[
                const SizedBox(height: 12),
                const Text("La réponse correcte était :", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFEE2B2B))),
                Text(widget.correctFullSentence, style: const TextStyle(fontSize: 18, color: Color(0xFFEE2B2B))),
              ],
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity, height: 55,
                child: ElevatedButton(
                  onPressed: () { Navigator.pop(context); controller.nextPage(); },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isCorrect ? const Color(0xFF58CC02) : const Color(0xFFEE2B2B),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 0,
                  ),
                  child: const Text("CONTINUER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 110),
          child: Column(
            children: [
              const SizedBox(height: 30),
              const Text("TRADUIS CETTE PHRASE", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.black54)),
              const SizedBox(height: 20),

              // --- ROW MASCOTTE + BULLE (Comme sur ton dessin) ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(width: 110, height: 110, child: Lottie.asset(currentLottie!)),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: Colors.grey.shade300, width: 1.5),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.volume_up, color: Colors.blueAccent, size: 24),
                                const SizedBox(width: 10),
                                Expanded(child: Text(widget.question, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                              ],
                            ),
                          ),
                          // La pointe de la bulle
                          Positioned(
                            left: -6, top: 20,
                            child: RotationTransition(
                              turns: const AlwaysStoppedAnimation(-45 / 360),
                              child: Container(
                                width: 12, height: 12,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border(left: BorderSide(color: Colors.grey.shade300, width: 1.5), top: BorderSide(color: Colors.grey.shade300, width: 1.5)),
                                ),
                              ),
                            ),
                          ),
                          // Masque pour l'ouverture
                          Positioned(left: 0, top: 18, child: Container(width: 4, height: 18, color: Colors.white)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // --- ZONE DE RÉPONSE (Les mots s'alignent ici) ---
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                constraints: const BoxConstraints(minHeight: 120),
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey.shade300, width: 2), top: BorderSide(color: Colors.grey.shade100, width: 1)),
                ),
                alignment: Alignment.topLeft,
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: selectedWords.asMap().entries.map((entry) {
                    return ActionChip(
                      label: Text(entry.value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFE5E5E5), width: 2)),
                      onPressed: hasValidated ? null : () {
                        setState(() {
                          availableWords.add(selectedWords.removeAt(entry.key));
                        });
                      },
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 40),

              // --- OPTIONS DE MOTS (Le clavier de mots en bas) ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: availableWords.asMap().entries.map((entry) {
                    return ActionChip(
                      label: Text(entry.value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      backgroundColor: const Color(0xFFF7F7F7),
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFE5E5E5), width: 2)),
                      onPressed: hasValidated ? null : () {
                        setState(() {
                          selectedWords.add(availableWords.removeAt(entry.key));
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        // --- BOUTON VALIDER FIXE EN BAS ---
        Positioned(
          bottom: 25,
          left: 20,
          right: 20,
          child: SizedBox(
            height: 55,
            child: ElevatedButton(
              onPressed: selectedWords.isEmpty || hasValidated ? null : () {
                String userSentence = selectedWords.join(" ");
                bool isCorrect = userSentence.trim().toLowerCase() == widget.correctFullSentence.trim().toLowerCase();
                setState(() {
                  hasValidated = true;
                  currentLottie = isCorrect ? widget.lottieCorrect : widget.lottieIncorrect;
                });
                _showResultBottomSheet(isCorrect);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9800),
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 3,
              ),
              child: const Text("VALIDER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
            ),
          ),
        ),
      ],
    );
  }
}