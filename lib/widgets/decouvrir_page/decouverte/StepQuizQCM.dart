import 'dart:math';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tibi/helpers/services/sound_service.dart';
import 'package:tibi/widgets/mascots/kadoua_mascot.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tibi/controller/apps/discovery_controller.dart';


const Color _kOrange     = Color(0xFFF27F22);


class StepQuizQCM extends StatefulWidget {
  final String question;
  final String title;
  final List<String> options;
  final String correctOption;
  final VoidCallback? onContinue;
  // conservés pour compatibilité ascendante (ignorés)
  final String lottieQuestion;
  final String lottieCorrect;
  final String lottieIncorrect;

  const StepQuizQCM({
    super.key,
    required this.question,
    required this.title,
    required this.options,
    required this.correctOption,
    this.onContinue,
    this.lottieQuestion = '',
    this.lottieCorrect = '',
    this.lottieIncorrect = '',
  });

  @override
  State<StepQuizQCM> createState() => _StepQuizQCMState();
}

class _StepQuizQCMState extends State<StepQuizQCM>
    with TickerProviderStateMixin {
  final DiscoveryController controller = Get.find();

  int? selectedIndex;
  KadouaMood _kadouaMood = KadouaMood.speaking;
  bool hasValidated = false;

  late final AnimationController _shakeCtrl;
  late final AnimationController _correctCtrl;

  @override
  void initState() {
    super.initState();
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

  // ── Bottom sheet ───────────────────────────────────────────────────────────

  void _showResultBottomSheet(bool isCorrect) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isCorrect
                ? [const Color(0xFFF0FFDB), const Color(0xFFD7FFB8)]
                : [const Color(0xFFFFE7E2), const Color(0xFFFFDFE0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 18,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.white70,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 16),
            Icon(
              isCorrect ? Icons.emoji_events : Icons.sentiment_dissatisfied,
              color: isCorrect
                  ? _kOrange
                  : const Color(0xFFEE2B2B),
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              isCorrect ? "Bravo champion !" : "Oups... presque !",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isCorrect
                    ? const Color(0xFF3C7D00)
                    : const Color(0xFFB00020),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              isCorrect
                  ? "Tu as choisi la bonne réponse. Prêt pour la prochaine ?"
                  : "Regarde bien la réponse et retente ta chance.",
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 15, color: Colors.black87, height: 1.4),
            ),
            if (!isCorrect) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F0),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Bonne réponse",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFB00020),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.correctOption,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFB00020),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 54,
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
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text(
                  "CONTINUER",
                  style: TextStyle(
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
    if (!hasValidated) {
      return selectedIndex == index
          ? _kOrange
          : Colors.grey.shade300;
    }
    if (widget.options[index] == widget.correctOption) {
      return const Color(0xFF58CC02);
    }
    if (selectedIndex == index) return const Color(0xFFEE2B2B);
    return Colors.grey.shade300;
  }

  Color _getBackgroundColor(int index) {
    final isCorrectOption = widget.options[index] == widget.correctOption;
    final isSelected = selectedIndex == index;
    if (!hasValidated) {
      return isSelected
          ? _kOrange.withValues(alpha: 0.10)
          : Colors.white;
    }
    if (isCorrectOption) return const Color(0xFFE8F6DC);
    if (isSelected) return const Color(0xFFFFE8E5);
    return Colors.white;
  }

  // ── Option avec animations ─────────────────────────────────────────────────

  Widget _buildOption(int index) {
    final isSelected = selectedIndex == index;
    final isCorrectOption = widget.options[index] == widget.correctOption;
    final isWrongSelected = hasValidated && isSelected && !isCorrectOption;
    final isCorrectValidated = hasValidated && isCorrectOption;
    final baseColor = _getBorderColor(index);

    return TweenAnimationBuilder<double>(
      key: ValueKey('opt-$index-$isSelected'),
      tween: Tween(begin: isSelected && !hasValidated ? 0.95 : 1.0, end: 1.0),
      duration: const Duration(milliseconds: 380),
      curve: Curves.elasticOut,
      builder: (_, bounceScale, __) => Transform.scale(
        scale: bounceScale,
        child: AnimatedBuilder(
          animation: Listenable.merge([_shakeCtrl, _correctCtrl]),
          builder: (_, __) {
            final shakeX = isWrongSelected
                ? sin(_shakeCtrl.value * pi * 5) * 8 * (1 - _shakeCtrl.value)
                : 0.0;
            final correctScale = isCorrectValidated
                ? 1.0 + 0.05 * sin(_correctCtrl.value * pi)
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
                          setState(() => selectedIndex = index);
                        },
                  borderRadius: BorderRadius.circular(18),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    padding: const EdgeInsets.symmetric(
                        vertical: 18, horizontal: 18),
                    decoration: BoxDecoration(
                      color: _getBackgroundColor(index),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: baseColor,
                        width:
                            (isSelected || (hasValidated && isCorrectOption))
                                ? 2.2
                                : 1.2,
                      ),
                      boxShadow: isSelected && !hasValidated
                          ? [
                              BoxShadow(
                                color: _kOrange.withValues(alpha: 0.15),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              )
                            ]
                          : [],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.options[index],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected ? baseColor : Colors.black87,
                            ),
                          ),
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder: (child, anim) =>
                              ScaleTransition(scale: anim, child: child),
                          child: hasValidated
                              ? isCorrectOption
                                  ? const Icon(Icons.check_circle,
                                      color: Color(0xFF58CC02),
                                      key: ValueKey('correct'))
                                  : isSelected
                                      ? const Icon(Icons.close,
                                          color: Color(0xFFEE2B2B),
                                          key: ValueKey('wrong'))
                                      : const SizedBox(
                                          width: 0,
                                          height: 0,
                                          key: ValueKey('empty'))
                              : const SizedBox(
                                  width: 0,
                                  height: 0,
                                  key: ValueKey('empty')),
                        ),
                      ],
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
          padding: const EdgeInsets.only(bottom: 120),
          child: Column(
            children: [
              const SizedBox(height: 30),

              Text("CHOISIE LA BONNE REPONSE", style: const TextStyle(
               fontSize: 18,
               fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              )),

              const SizedBox(height: 22),
              // Mascotte + bulle question
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    KadouaMascot(
                      mood: _kadouaMood,
                      size: KadouaSize.md,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                  color: Colors.grey.shade300, width: 1.5),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.volume_up,
                                    color: Colors.blueAccent, size: 24),
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
                          // Pointe de bulle
                          Positioned(
                            left: -6.5,
                            top: 22,
                            child: RotationTransition(
                              turns:
                                  const AlwaysStoppedAnimation(-45 / 360),
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border(
                                    left: BorderSide(
                                        color: Colors.grey.shade300,
                                        width: 1.5),
                                    top: BorderSide(
                                        color: Colors.grey.shade300,
                                        width: 1.5),
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
              const SizedBox(height: 24),
              // Liste des options
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.options.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, index) => _buildOption(index),
                ),
              ),
            ],
          ),
        ),

        // Bouton VALIDER
        Positioned(
          bottom: 25,
          left: 20,
          right: 20,
          child: SizedBox(
            height: 55,
            child: ElevatedButton(
              onPressed: selectedIndex != null && !hasValidated
                  ? () {
                      final isCorrect = widget.options[selectedIndex!] ==
                          widget.correctOption;
                      setState(() {
                        hasValidated = true;
                        _kadouaMood = isCorrect
                            ? KadouaMood.correct
                            : KadouaMood.incorrect;
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
                backgroundColor: _kOrange,
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                elevation: 4,
              ),
              child: const Text(
                "VALIDER",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
