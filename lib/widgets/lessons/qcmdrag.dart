import 'dart:math';
import 'package:tibi/helpers/services/sound_service.dart';
import 'package:tibi/widgets/mascots/quiz_mascot.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tibi/controller/apps/discovery_controller.dart';

class StepQuizTranslate extends StatefulWidget {
  final String question;
  final List<String> words;
  final String correctFullSentence;
  final int questionIndex;
  // conservés pour compatibilité ascendante (ignorés)
  final String lottieQuestion;
  final String lottieCorrect;
  final String lottieIncorrect;

  const StepQuizTranslate({
    super.key,
    required this.question,
    required this.words,
    required this.correctFullSentence,
    this.questionIndex = 0,
    this.lottieQuestion = '',
    this.lottieCorrect = '',
    this.lottieIncorrect = '',
  });

  @override
  State<StepQuizTranslate> createState() => _StepQuizTranslateState();
}

class _StepQuizTranslateState extends State<StepQuizTranslate>
    with SingleTickerProviderStateMixin {
  final DiscoveryController controller = Get.find();

  List<String> selectedWords = [];
  List<String> availableWords = [];
  QuizMascotMood _mascotMood = QuizMascotMood.speaking;
  bool hasValidated = false;

  // Shake sur la zone de réponse quand la phrase est mauvaise
  late final AnimationController _shakeCtrl;

  @override
  void initState() {
    super.initState();
    availableWords = List.from(widget.words);
    _shakeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 480));
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isCorrect
              ? const Color(0xFFD7FFB8)
              : const Color(0xFFFFDFE0),
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(25)),
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
                  size: 35,
                ),
                const SizedBox(width: 12),
                Text(
                  isCorrect ? "Excellent !" : "Oups !",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isCorrect
                        ? const Color(0xFF58CC02)
                        : const Color(0xFFEE2B2B),
                  ),
                ),
              ],
            ),
            if (!isCorrect) ...[
              const SizedBox(height: 12),
              const Text(
                "La réponse correcte était :",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFEE2B2B)),
              ),
              Text(
                widget.correctFullSentence,
                style: const TextStyle(
                    fontSize: 18, color: Color(0xFFEE2B2B)),
              ),
            ],
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  controller.nextPage();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCorrect
                      ? const Color(0xFF58CC02)
                      : const Color(0xFFEE2B2B),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  elevation: 0,
                ),
                child: const Text(
                  "CONTINUER",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              ),
            ),
          ],
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
          padding: const EdgeInsets.only(bottom: 110),
          child: Column(
            children: [
              const SizedBox(height: 30),
              const Text(
                "TRADUIS CETTE PHRASE",
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Colors.black54),
              ),
              const SizedBox(height: 20),

              // Mascotte + bulle question
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    QuizMascotSelector(
                      questionIndex: widget.questionIndex,
                      mood: _mascotMood,
                      size: 100,
                    ),
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
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Pointe de bulle
                          Positioned(
                            left: -6,
                            top: 20,
                            child: RotationTransition(
                              turns: const AlwaysStoppedAnimation(-45 / 360),
                              child: Container(
                                width: 12,
                                height: 12,
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
                          Positioned(
                            left: 0,
                            top: 18,
                            child: Container(
                                width: 4, height: 18, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Zone de réponse avec shake si mauvaise réponse
              AnimatedBuilder(
                animation: _shakeCtrl,
                builder: (_, child) => Transform.translate(
                  offset: Offset(
                    sin(_shakeCtrl.value * pi * 5) *
                        9 *
                        (1 - _shakeCtrl.value),
                    0,
                  ),
                  child: child,
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  constraints: const BoxConstraints(minHeight: 120),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: hasValidated
                        ? const Color(0xFFFFF8F8)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border(
                      bottom: BorderSide(
                          color: hasValidated
                              ? const Color(0xFFEE2B2B)
                              : Colors.grey.shade300,
                          width: 2),
                      top: BorderSide(
                          color: Colors.grey.shade100, width: 1),
                    ),
                  ),
                  alignment: Alignment.topLeft,
                  padding: const EdgeInsets.all(10),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: selectedWords.asMap().entries.map((entry) {
                      // Bounce d'entrée quand un mot est ajouté
                      return TweenAnimationBuilder<double>(
                        key: ValueKey('sel-${entry.value}-${entry.key}'),
                        tween: Tween(begin: 0.6, end: 1.0),
                        duration: const Duration(milliseconds: 320),
                        curve: Curves.elasticOut,
                        builder: (_, scale, child) =>
                            Transform.scale(scale: scale, child: child!),
                        child: ActionChip(
                          label: Text(
                            entry.value,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(
                                color: Color(0xFFE5E5E5), width: 2),
                          ),
                          onPressed: hasValidated
                              ? null
                              : () {
                                  SoundService.playSelect();
                                  setState(() {
                                    availableWords.add(
                                        selectedWords.removeAt(entry.key));
                                  });
                                },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Mots disponibles (clavier de mots)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: availableWords.asMap().entries.map((entry) {
                    // Bounce d'entrée quand un mot revient dans la liste
                    return TweenAnimationBuilder<double>(
                      key: ValueKey('avail-${entry.value}-${entry.key}'),
                      tween: Tween(begin: 0.7, end: 1.0),
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.elasticOut,
                      builder: (_, scale, child) =>
                          Transform.scale(scale: scale, child: child!),
                      child: ActionChip(
                        label: Text(
                          entry.value,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        backgroundColor: const Color(0xFFF7F7F7),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(
                              color: Color(0xFFE5E5E5), width: 2),
                        ),
                        onPressed: hasValidated
                            ? null
                            : () {
                                SoundService.playSelect();
                                setState(() {
                                  selectedWords.add(
                                      availableWords.removeAt(entry.key));
                                });
                              },
                      ),
                    );
                  }).toList(),
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
              onPressed: selectedWords.isEmpty || hasValidated
                  ? null
                  : () {
                      final userSentence = selectedWords.join(" ");
                      final isCorrect = userSentence.trim().toLowerCase() ==
                          widget.correctFullSentence.trim().toLowerCase();
                      setState(() {
                        hasValidated = true;
                        _mascotMood = isCorrect
                            ? QuizMascotMood.correct
                            : QuizMascotMood.incorrect;
                      });
                      if (isCorrect) {
                        SoundService.playCorrect();
                      } else {
                        _shakeCtrl.forward(from: 0);
                        SoundService.playWrong();
                      }
                      _showResultBottomSheet(isCorrect);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9800),
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                elevation: 3,
              ),
              child: const Text(
                "VALIDER",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 18),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
