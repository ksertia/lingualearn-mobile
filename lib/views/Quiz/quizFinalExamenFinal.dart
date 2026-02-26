import 'dart:async';
import 'package:fasolingo/views/Quiz/Certification_Screen.dart';
import 'package:flutter/material.dart';

// --- Palette de couleurs centralisée ---
class AppColors {
  static const Color bleuFonce = Color(0xFF000099);
  static const Color cyan = Color(0xFF00CED1);
  static const Color orange = Color(0xFFFF7F00);
  static const Color grisClair = Color(0xFFE0E0E0); // Légèrement plus doux
  static const Color blanc = Color(0xFFFFFFFF);
}

class ExamTestScreen extends StatefulWidget {
  const ExamTestScreen({super.key});

  @override
  State<ExamTestScreen> createState() => _ExamTestScreenState();
}

class _ExamTestScreenState extends State<ExamTestScreen> {
  // Contrôleur pour l'animation de glissement entre les questions
  final PageController _pageController = PageController();

  final List<Map<String, dynamic>> questions = [
    {
      "question": "Comment dire,'Merci beaucoup en mooré' ?",
      "options": ["Bogodo", "Barak wousgo", "Mam n'mi", "nissala"],
      "correctIndex": 1,
    },
    {
      "question": "Je m'appelle ...",
      "options": ["A Your la ...", "Kamba baba la ...", "Mam your la ...", "Fo your la ..."],
      "correctIndex": 2,
    },
    {
      "question": "Comment dire 15 en mooré ?",
      "options": ["Pig la nou", "PIssi", "Nassé", "Yibou"],
      "correctIndex": 0,
    },
  ];

  int currentIndex = 0;
  int correctAnswers = 0;
  int? selectedIndex;
  Timer? timer;
  int remainingSeconds = 60;
  bool blinkRed = false;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (remainingSeconds == 0) {
        finishExam();
      } else {
        setState(() {
          remainingSeconds--;
          if (remainingSeconds < 10) blinkRed = !blinkRed;
        });
      }
    });
  }

  void onOptionSelected(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  void handleNext() {
    if (selectedIndex == null) return;

    // Calcul du score
    if (selectedIndex == questions[currentIndex]["correctIndex"]) {
      correctAnswers++;
    }

    if (currentIndex < questions.length - 1) {
      // Transition animée vers la question suivante
      setState(() {
        currentIndex++;
        selectedIndex = null;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      finishExam();
    }
  }

  void finishExam() {
    timer?.cancel();
    double scorePercent = (correctAnswers / questions.length) * 100;

    // Petite pause pour laisser l'utilisateur voir sa dernière réponse
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ExamResultScreen(
            score: scorePercent.toInt(),
            isPassed: scorePercent >= 70,
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blanc,
      appBar: AppBar(
        backgroundColor: AppColors.bleuFonce,
        elevation: 0,
        centerTitle: true,
        title: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: (remainingSeconds < 10 && blinkRed) ? AppColors.orange : AppColors.cyan,
          ),
          child: Text("⏱ ${remainingSeconds ~/ 60}:${(remainingSeconds % 60).toString().padLeft(2, '0')}"),
        ),
      ),
      body: Column(
        children: [
          // Barre de progression animée
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 400),
            tween: Tween<double>(begin: 0, end: (currentIndex + 1) / questions.length),
            builder: (context, value, _) => LinearProgressIndicator(
              value: value,
              minHeight: 6,
              backgroundColor: AppColors.grisClair,
              color: AppColors.cyan,
            ),
          ),

          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(), // On force l'usage du bouton
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final q = questions[index];
                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "QUESTION ${index + 1}",
                        style: const TextStyle(
                          color: AppColors.cyan,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        q["question"],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.bleuFonce,
                        ),
                      ),
                      const SizedBox(height: 32),
                      ...List.generate(q["options"].length, (optIndex) {
                        bool isSelected = selectedIndex == optIndex;
                        return GestureDetector(
                          onTap: () => onOptionSelected(optIndex),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.bleuFonce : AppColors.blanc,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: isSelected ? AppColors.bleuFonce : AppColors.grisClair,
                                width: 2,
                              ),
                              boxShadow: isSelected
                                  ? [BoxShadow(color: AppColors.bleuFonce.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
                                  : [],
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                                  color: isSelected ? AppColors.cyan : AppColors.grisClair,
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Text(
                                    q["options"][optIndex],
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected ? AppColors.blanc : AppColors.bleuFonce,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                );
              },
            ),
          ),

          // Zone du bouton en bas
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: ElevatedButton(
              onPressed: selectedIndex != null ? handleNext : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orange,
                disabledBackgroundColor: AppColors.grisClair,
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 0,
              ),
              child: Text(
                currentIndex == questions.length - 1 ? "VALIDER L'EXAMEN" : "QUESTION SUIVANTE",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Écran de résultat simplifié avec votre palette ---
class ExamResultScreen extends StatelessWidget {
  final int score;
  final bool isPassed;

  const ExamResultScreen({
    super.key,
    required this.score,
    required this.isPassed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bleuFonce,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isPassed ? Icons.emoji_events : Icons.sentiment_dissatisfied,
              size: 100,
              color: AppColors.cyan,
            ),
            const SizedBox(height: 20),

            Text(
              "$score%",
              style: const TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            Text(
              isPassed ? "EXAMEN RÉUSSI" : "EXAMEN ÉCHOUÉ",
              style: const TextStyle(
                fontSize: 20,
                color: AppColors.cyan,
                letterSpacing: 2,
              ),
            ),

            const SizedBox(height: 40),

            // ✅ BOUTON CERTIFICAT (visible seulement si réussi)
            if (isPassed)
              Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cyan,
                    minimumSize: const Size(220, 50),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CertificationScreen(
                          userName: "Antoine Compaoré",
                          moduleName: "Les bases",
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    "VOIR LE CERTIFICAT",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            // 🔁 Bouton Retour
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orange,
                minimumSize: const Size(220, 50),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "RETOUR",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}