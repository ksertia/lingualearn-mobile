import 'dart:math';
import 'package:fasolingo/helpers/services/sound_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fasolingo/controller/apps/discovery_controller.dart';
import 'package:lottie/lottie.dart';

class StepQuizQCM extends StatefulWidget {
  final String question;
  final String title;
  final List<String> options;
  final String lottieQuestion;
  final String lottieCorrect;
  final String lottieIncorrect;
  final String correctOption;
  final VoidCallback? onContinue;

  const StepQuizQCM({
    super.key,
    required this.question,
    required this.title,
    required this.options,
    required this.lottieQuestion,
    required this.lottieCorrect,
    required this.lottieIncorrect,
    required this.correctOption,
    this.onContinue,
  });

  @override
  State<StepQuizQCM> createState() => _StepQuizQCMState();
}

class _StepQuizQCMState extends State<StepQuizQCM>
    with TickerProviderStateMixin {
  final DiscoveryController controller = Get.find();

  int? selectedIndex;
  String? currentLottie;
  bool hasValidated = false;

  late final AnimationController _shakeCtrl;
  late final AnimationController _correctCtrl;

  @override
  void initState() {
    super.initState();
    currentLottie = widget.lottieQuestion;
    _shakeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 480));
    _correctCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 550));
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    _correctCtrl.dispose();
    super.dispose();
  }

  // ── Bottom sheet feedback ──────────────────────────────────────────────────

  void _showResultBottomSheet(bool isCorrect) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
                  color: isCorrect
                      ? const Color(0xFF58CC02)
                      : const Color(0xFFEE2B2B),
                  size: 30,
                ),
                const SizedBox(width: 10),
                Text(
                  isCorrect ? "Bravo 🥳!" : "Désolé 😥!",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isCorrect
                        ? const Color(0xFF58CC02)
                        : const Color(0xFFEE2B2B),
                  ),
                ),
              ],
            ),
            if (!isCorrect) ...[
              const SizedBox(height: 10),
              const Text(
                "Bonne réponse :",
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFEE2B2B)),
              ),
              Text(
                widget.correctOption,
                style:
                    const TextStyle(fontSize: 16, color: Color(0xFFEE2B2B)),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (widget.onContinue != null) {
                    widget.onContinue!();
                  } else {
                    controller.nextPage();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCorrect
                      ? const Color(0xFF58CC02)
                      : const Color(0xFFEE2B2B),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  elevation: 0,
                ),
                child: Text(
                  isCorrect ? "CONTINUER" : "D'ACCORD",
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers couleurs ───────────────────────────────────────────────────────

  Color _getBorderColor(int index) {
    final optionText = widget.options[index];
    final isSelected = selectedIndex == index;
    if (!hasValidated) {
      return isSelected ? const Color(0xFF188329) : Colors.grey.shade300;
    }
    if (isSelected) {
      return optionText == widget.correctOption
          ? const Color(0xFF58CC02)
          : const Color(0xFFEE2B2B);
    }
    if (optionText == widget.correctOption) return const Color(0xFF58CC02);
    return Colors.grey.shade300;
  }

  Color _getBackgroundColor(int index) {
    final isSelected = selectedIndex == index;
    final isCorrect = widget.options[index] == widget.correctOption;
    if (!hasValidated) {
      return isSelected ? const Color(0xFFE8F6DC) : Colors.white;
    }
    if (isCorrect) return const Color(0xFFE8F6DC);
    if (isSelected) return const Color(0xFFFFE8E5);
    return Colors.white;
  }

  // ── Construction d'une option avec animations ─────────────────────────────

  Widget _buildOption(int index) {
    final isSelected = selectedIndex == index;
    final isCorrectOption = widget.options[index] == widget.correctOption;
    final isWrongSelected = hasValidated && isSelected && !isCorrectOption;
    final isCorrectValidated = hasValidated && isCorrectOption;

    return TweenAnimationBuilder<double>(
      // La clé change quand l'item devient sélectionné → rejoue le bounce
      key: ValueKey('opt-$index-$isSelected'),
      tween: Tween(
          begin: isSelected && !hasValidated ? 0.88 : 1.0, end: 1.0),
      duration: const Duration(milliseconds: 380),
      curve: Curves.elasticOut,
      builder: (_, bounceScale, __) => Transform.scale(
        scale: bounceScale,
        child: AnimatedBuilder(
          animation: Listenable.merge([_shakeCtrl, _correctCtrl]),
          builder: (_, __) {
            // Shake horizontal sur mauvaise réponse
            final shakeX = isWrongSelected
                ? sin(_shakeCtrl.value * pi * 5) *
                    7 *
                    (1 - _shakeCtrl.value)
                : 0.0;
            // Pulse scale sur bonne réponse
            final correctScale = isCorrectValidated
                ? 1.0 + 0.06 * sin(_correctCtrl.value * pi)
                : 1.0;

            return Transform.translate(
              offset: Offset(shakeX, 0),
              child: Transform.scale(
                scale: correctScale,
                child: InkWell(
                  onTap: hasValidated
                      ? null
                      : () {
                          SoundService.playSelect();
                          setState(() {
                            selectedIndex = index;
                            currentLottie = widget.lottieQuestion;
                          });
                        },
                  borderRadius: BorderRadius.circular(15),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _getBackgroundColor(index),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: _getBorderColor(index),
                        width: (isSelected ||
                                (hasValidated && isCorrectOption))
                            ? 2.5
                            : 1.0,
                      ),
                      boxShadow: isSelected && !hasValidated
                          ? [
                              BoxShadow(
                                color: const Color(0xFF188329)
                                    .withValues(alpha: 0.12),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ]
                          : [],
                    ),
                    child: Text(
                      widget.options[index],
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isSelected
                            ? FontWeight.w800
                            : FontWeight.bold,
                        color: hasValidated
                            ? (isCorrectOption
                                ? const Color(0xFF3C7D00)
                                : isSelected
                                    ? const Color(0xFFB00020)
                                    : Colors.black87)
                            : (isSelected
                                ? const Color(0xFF188329)
                                : Colors.black87),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            children: [
              const SizedBox(height: 30),
              Text(widget.title,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: Colors.black54)),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: currentLottie != null
                    ? Lottie.asset(currentLottie!, height: 140, repeat: true)
                    : const SizedBox(height: 140),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.volume_up,
                          color: Colors.blueAccent, size: 28),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Text(widget.question,
                            style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.options.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.1,
                  ),
                  itemBuilder: (_, index) => _buildOption(index),
                ),
              ),
            ],
          ),
        ),

        // Bouton VALIDER
        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: SizedBox(
            height: 55,
            child: ElevatedButton(
              onPressed: selectedIndex != null && !hasValidated
                  ? () {
                      final isCorrect =
                          widget.options[selectedIndex!] ==
                              widget.correctOption;
                      setState(() {
                        hasValidated = true;
                        currentLottie = isCorrect
                            ? widget.lottieCorrect
                            : widget.lottieIncorrect;
                      });
                      if (isCorrect) {
                        _correctCtrl.forward(from: 0);
                        SoundService.playCorrect();
                      } else {
                        _shakeCtrl.forward(from: 0);
                        SoundService.playWrong();
                      }
                      _showResultBottomSheet(isCorrect);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9800),
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text("VALIDER",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
          ),
        ),
      ],
    );
  }
}
