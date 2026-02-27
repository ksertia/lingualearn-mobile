import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class CertificationScreen extends StatefulWidget {
  final String userName;
  final String moduleName;

  const CertificationScreen({
    super.key,
    required this.userName,
    required this.moduleName,
  });

  @override
  State<CertificationScreen> createState() => _CertificationScreenState();
}

class _CertificationScreenState extends State<CertificationScreen>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;

  late AnimationController _badgeController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // 🎉 Confettis
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();

    // 🏆 Animation badge
    _badgeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _badgeController,
        curve: Curves.elasticOut,
      ),
    );

    _badgeController.forward();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _badgeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          SafeArea(
            child: Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  const Text(
                    "🎉 Certification obtenue",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF000099),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // 🏆 BADGE ANIMÉ
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 25),
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFFFD700),
                            Color(0xFFFFA500),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.6),
                            blurRadius: 25,
                            spreadRadius: 4,
                          )
                        ],
                      ),
                      child: const Icon(
                        Icons.workspace_premium,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  // 🖼 IMAGE CERTIFICAT
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        "assets/images/quiz/certificat.jpg",
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 👤 Nom utilisateur
                  Text(
                    widget.userName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF000099),
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "a validé avec succès le module",
                    style: TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height: 8),

                  // 📚 Module
                  Text(
                    widget.moduleName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00CED1),
                    ),
                  ),

                  const Spacer(),

                  // 🔵 Bouton Module suivant
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF000099),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 6,
                    ),
                    child: const Text(
                      "Module suivant",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 🎊 Confettis
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            emissionFrequency: 0.05,
            numberOfParticles: 25,
            gravity: 0.25,
            colors: const [
              Color(0xFF000099),
              Color(0xFF00CED1),
              Color(0xFFFF7F00),
            ],
          ),
        ],
      ),
    );
  }
}