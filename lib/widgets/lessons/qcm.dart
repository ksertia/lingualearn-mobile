import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class QuizQCM extends StatefulWidget {
  final String question;
  final List<String> options;
  final String lottieQuestion;
  final String lottieCorrect;
  final String lottieIncorrect;
  final String correctOption;
  final VoidCallback onNext;

  const QuizQCM({
    super.key,
    required this.question,
    required this.options,
    required this.lottieQuestion,
    required this.lottieCorrect,
    required this.lottieIncorrect,
    required this.correctOption,
    required this.onNext,
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
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isCorrect
                  ? [Color(0xFFF0FFDB), Color(0xFFD7FFB8)]
                  : [Color(0xFFFFE7E2), Color(0xFFFFDFE0)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
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
                    ? const Color(0xFF58CC02)
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
                    widget.onNext();
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
        );
      },
    );
  }

  Color _getBorderColor(int index) {
    if (!hasValidated) {
      return selectedIndex == index
          ? const Color(0xFFFF9800)
          : Colors.grey.shade300;
    }
    if (widget.options[index] == widget.correctOption)
      return const Color(0xFF58CC02);
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
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFC845), Color(0xFFFF9100)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.22),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child:
                          const Icon(Icons.lightbulb, color: Color(0xFFFF9100)),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "Choisis la bonne réponse pour continuer l'aventure !",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.options.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    bool isSelected = selectedIndex == index;
                    bool isCorrectOption =
                        widget.options[index] == widget.correctOption;
                    Color baseColor = _getBorderColor(index);
                    Color backgroundColor;
                    if (hasValidated) {
                      backgroundColor = isCorrectOption
                          ? const Color(0xFFE8F6DC)
                          : isSelected
                              ? const Color(0xFFFFE8E5)
                              : Colors.white;
                    } else {
                      backgroundColor = isSelected
                          ? baseColor.withOpacity(0.12)
                          : Colors.white;
                    }
                    return InkWell(
                      onTap: hasValidated
                          ? null
                          : () => setState(() => selectedIndex = index),
                      borderRadius: BorderRadius.circular(18),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        padding: const EdgeInsets.symmetric(
                            vertical: 18, horizontal: 18),
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: baseColor,
                            width: (isSelected ||
                                    (hasValidated && isCorrectOption))
                                ? 2.2
                                : 1.2,
                          ),
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
                                  color:
                                      isSelected ? baseColor : Colors.black87,
                                ),
                              ),
                            ),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              transitionBuilder: (child, animation) =>
                                  ScaleTransition(
                                scale: animation,
                                child: child,
                              ),
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
                      bool isCorrect = widget.options[selectedIndex!] ==
                          widget.correctOption;
                      setState(() {
                        hasValidated = true;
                        currentLottie = isCorrect
                            ? widget.lottieCorrect
                            : widget.lottieIncorrect;
                      });
                      _showResultBottomSheet(isCorrect);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9800),
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
