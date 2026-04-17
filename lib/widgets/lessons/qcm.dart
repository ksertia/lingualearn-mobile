import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class QuizQCM extends StatefulWidget {
  final String question;
  final List<String> options;
  final String lottieQuestion;
  final String lottieCorrect;
  final String lottieIncorrect;
  final String correctOption;
  final VoidCallback onNext; // <--- AJOUTÉ : Pour communiquer avec StepContentScreen

  const QuizQCM({
    super.key,
    required this.question,
    required this.options,
    required this.lottieQuestion,
    required this.lottieCorrect,
    required this.lottieIncorrect,
    required this.correctOption,
    required this.onNext, // <--- AJOUTÉ
  });

  @override
  State<QuizQCM> createState() => _QuizQCMState();
}

class _QuizQCMState extends State<QuizQCM> {
  int? selectedIndex;
  String? currentLottie;
  bool hasValidated = false;

  @override
  void initState() {
    super.initState();
    currentLottie = widget.lottieQuestion;
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
                  Icon(
                    isCorrect ? Icons.check_circle : Icons.cancel,
                    color: isCorrect ? const Color(0xFF58CC02) : const Color(0xFFEE2B2B),
                    size: 35,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isCorrect ? "Bravo 🥳!" : "Désolé 😥!",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isCorrect ? const Color(0xFF58CC02) : const Color(0xFFEE2B2B),
                    ),
                  ),
                ],
              ),
              if (!isCorrect) ...[
                const SizedBox(height: 12),
                const Text(
                  "Bonne réponse :",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFEE2B2B)),
                ),
                Text(
                  widget.correctOption,
                  style: const TextStyle(fontSize: 18, color: Color(0xFFEE2B2B)),
                ),
              ],
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onNext(); // <--- MODIFIÉ : Appelle la fonction passée en paramètre
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isCorrect ? const Color(0xFF58CC02) : const Color(0xFFEE2B2B),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 0,
                  ),
                  child: const Text(
                    "CONTINUER",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getBorderColor(int index) {
    if (!hasValidated) {
      return selectedIndex == index ? const Color(0xFFFF9800) : Colors.grey.shade300;
    }
    if (widget.options[index] == widget.correctOption) return const Color(0xFF58CC02);
    if (selectedIndex == index) return const Color(0xFFEE2B2B);
    return Colors.grey.shade300;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 120),
          child: Column(
            children: [
              const SizedBox(height: 30),
              const Text(
                "CHOISIS LA BONNE RÉPONSE",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.black54),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: currentLottie != null
                          ? Lottie.asset(currentLottie!)
                          : const SizedBox(),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: Colors.grey.shade300, width: 1.5),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.volume_up, color: Colors.blueAccent, size: 24),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    widget.question,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            left: -6.5,
                            top: 22,
                            child: RotationTransition(
                              turns: const AlwaysStoppedAnimation(-45 / 360),
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border(
                                    left: BorderSide(color: Colors.grey.shade300, width: 1.5),
                                    top: BorderSide(color: Colors.grey.shade300, width: 1.5),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.options.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    bool isSelected = selectedIndex == index;
                    Color color = _getBorderColor(index);
                    return InkWell(
                      onTap: hasValidated ? null : () => setState(() => selectedIndex = index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                        decoration: BoxDecoration(
                          color: isSelected ? color.withOpacity(0.05) : Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: color,
                            width: (isSelected || (hasValidated && widget.options[index] == widget.correctOption)) ? 2.5 : 1.2,
                          ),
                        ),
                        child: Text(
                          widget.options[index],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? color : Colors.black87,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 25,
          left: 20,
          right: 20,
          child: SizedBox(
            height: 55,
            child: ElevatedButton(
              onPressed: selectedIndex != null && !hasValidated
                  ? () {
                bool isCorrect = widget.options[selectedIndex!] == widget.correctOption;
                setState(() {
                  hasValidated = true;
                  currentLottie = isCorrect ? widget.lottieCorrect : widget.lottieIncorrect;
                });
                _showResultBottomSheet(isCorrect);
              }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9800),
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 3,
              ),
              child: const Text(
                "VALIDER",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}