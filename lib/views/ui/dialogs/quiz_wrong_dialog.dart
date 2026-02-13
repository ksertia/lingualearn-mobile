import 'package:flutter/material.dart';

class QuizWrongDialog extends StatefulWidget {
  final String correction;
  final int xpReward;

  const QuizWrongDialog({
    super.key,
    required this.correction,
    this.xpReward = 0,
  });

  @override
  State<QuizWrongDialog> createState() => _QuizWrongDialogState();
}

class _QuizWrongDialogState extends State<QuizWrongDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  // Ta palette officielle
  final Color bleuFonce = const Color(0xFF000099);
  final Color orange = const Color(0xFFFF7F00);
  final Color grisClair = const Color(0xFFC0C0C0);
  final Color blanc = const Color(0xFFFFFFFF);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

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
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icône d'erreur avec fond subtil
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.red,
                  size: 60,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "PAS TOUT À FAIT",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: bleuFonce,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),

              // Section Correction
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: grisClair.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      "LA RÉPONSE ÉTAIT :",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: grisClair,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.correction,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: orange, // Utilisation de l'orange pour la correction
                      ),
                    ),
                  ],
                ),
              ),

              if (widget.xpReward > 0) ...[
                const SizedBox(height: 16),
                Text(
                  "+${widget.xpReward} XP gagnés quand même !",
                  style: TextStyle(color: bleuFonce, fontWeight: FontWeight.w600),
                ),
              ],

              const SizedBox(height: 24),

              // Bouton d'action
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
                    "J'AI COMPRIS",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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