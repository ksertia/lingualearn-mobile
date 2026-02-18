import 'package:flutter/material.dart';
import 'package:fasolingo/widgets/quiz/confetti_widget.dart'; // Assure-toi que le chemin est correct

class QuizCorrectDialog extends StatefulWidget {
  final int xpReward;

  const QuizCorrectDialog({super.key, this.xpReward = 10});

  @override
  State<QuizCorrectDialog> createState() => _QuizCorrectDialogState();
}

class _QuizCorrectDialogState extends State<QuizCorrectDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  // Ta palette officielle
  final Color bleuFonce = const Color(0xFF000099);
  final Color orange = const Color(0xFFFF7F00);
  final Color blanc = const Color(0xFFFFFFFF);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Animation d'entrée élastique
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );

    // Animation de battement pour l'icône
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeInOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // 1. Les Confettis (en arrière-plan du contenu)
            const Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(30)),
                child: ConfettiWidget(),
              ),
            ),

            // 2. Le Conteneur principal
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: blanc.withOpacity(0.95), // Légère transparence pour voir les confettis
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: bleuFonce.withOpacity(0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icône animée avec effet de "pulse"
                  ScaleTransition(
                    scale: _pulseAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.green.withOpacity(0.2), width: 2),
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.green,
                        size: 60,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    "EXCELLENT !",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: bleuFonce,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Badge XP avec un style plus "Bulle"
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [orange, orange.withOpacity(0.8)],
                        ),
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: orange.withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ]
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.bolt_rounded, color: Colors.white, size: 22),
                        const SizedBox(width: 6),
                        Text(
                          "+${widget.xpReward} XP",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Bouton avec Feedback visuel
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: bleuFonce,
                        foregroundColor: blanc,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "CONTINUER",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
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
    );
  }
}