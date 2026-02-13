import 'package:flutter/material.dart';

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

  // Ta palette officielle
  final Color bleuFonce = const Color(0xFF000099);
  final Color orange = const Color(0xFFFF7F00);
  final Color blanc = const Color(0xFFFFFFFF);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    // Animation de zoom avec un léger rebond (elasticOut)
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
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
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: blanc,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: bleuFonce.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icône stylisée avec un cercle de fond
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.green,
                  size: 60,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "EXCELLENT !",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900, // Remplacé "black" pour éviter le soulignement
                  color: bleuFonce,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),

              // Badge XP stylisé
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bolt, color: orange, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      "+${widget.xpReward} XP",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: orange,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Bouton large et stylé
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: bleuFonce,
                    foregroundColor: blanc,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "CONTINUER",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}