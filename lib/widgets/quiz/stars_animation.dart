import 'package:flutter/material.dart';

class StarsAnimation extends StatelessWidget {
  final int stars;
  // Orange (255, 127, 0)
  final Color activeStar = const Color(0xFFFF7F00);
  // Gris très clair (192, 192, 192)
  final Color inactiveStar = const Color(0xFFC0C0C0);

  const StarsAnimation({super.key, required this.stars});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final bool isFilled = index < stars;
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 600 + (index * 300)),
          curve: Curves.elasticOut,
          builder: (context, value, _) {
            return Transform.scale(
              scale: value,
              child: Icon(
                isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                color: isFilled ? activeStar : inactiveStar,
                size: index == 1 ? 56 : 42,
              ),
            );
          },
        );
      }),
    );
  }
}