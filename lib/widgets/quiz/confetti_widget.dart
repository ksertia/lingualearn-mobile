import 'dart:math';
import 'package:flutter/material.dart';

class ConfettiWidget extends StatefulWidget {
  const ConfettiWidget({super.key});

  @override
  State<ConfettiWidget> createState() => _ConfettiWidgetState();
}

class _ConfettiWidgetState extends State<ConfettiWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_ConfettiParticle> particles = [];
  final Random random = Random();

  // Ta palette de couleurs harmonisée
  final List<Color> palette = [
    const Color(0xFF000099), // Bleu Foncé
    const Color(0xFF00CED1), // Cyan / Turquoise
    const Color(0xFFFF7F00), // Orange
    const Color(0xFFFFFFFF), // Blanc
  ];

  @override
  void initState() {
    super.initState();

    // Animation de 4 secondes pour une chute élégante
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..forward();

    // Génération des particules après le premier build pour obtenir la taille de l'écran
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final size = MediaQuery.of(context).size;

      setState(() {
        for (int i = 0; i < 60; i++) {
          particles.add(_ConfettiParticle(
            x: random.nextDouble() * size.width,
            y: -random.nextDouble() * size.height, // Démarre au-dessus de l'écran
            color: palette[random.nextInt(palette.length)],
            size: random.nextDouble() * 8 + 4,
            speed: random.nextDouble() * 2 + 1.5,
            rotationSpeed: random.nextDouble() * 2 + 1,
            shape: random.nextBool() ? BoxShape.circle : BoxShape.rectangle,
          ));
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return IgnorePointer( // Permet de cliquer sur les boutons à travers les confettis
          child: Stack(
            children: particles.map((p) {
              // Calcul de la position verticale (chute)
              final double yPos = p.y + (_controller.value * MediaQuery.of(context).size.height * 1.5);

              // Calcul de la position horizontale (effet de balancement sinusoïdal)
              final double xPos = p.x + (sin(_controller.value * 10 + p.x) * 25);

              return Positioned(
                top: yPos,
                left: xPos,
                child: Transform.rotate(
                  angle: _controller.value * p.rotationSpeed * pi,
                  child: Container(
                    width: p.size,
                    height: p.size,
                    decoration: BoxDecoration(
                      color: p.color,
                      shape: p.shape,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

/// Modèle interne pour définir chaque confetti
class _ConfettiParticle {
  final double x;
  final double y;
  final Color color;
  final double size;
  final double speed;
  final double rotationSpeed;
  final BoxShape shape;

  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.color,
    required this.size,
    required this.speed,
    required this.rotationSpeed,
    required this.shape,
  });
}