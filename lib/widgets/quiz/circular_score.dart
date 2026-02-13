import 'package:flutter/material.dart';

class CircularScore extends StatelessWidget {
  final double value;
  // Utilisation du Bleu Foncé (0, 0, 153)
  final Color mainColor = const Color(0xFF000099);
  // Utilisation du Cyan (0, 206, 209)
  final Color secondaryColor = const Color(0xFF00CED1);

  const CircularScore({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeOutQuart,
      builder: (context, val, _) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: mainColor.withOpacity(0.1),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 160,
              height: 160,
              child: CircularProgressIndicator(
                value: val,
                strokeWidth: 14,
                strokeCap: StrokeCap.round,
                backgroundColor: secondaryColor.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(mainColor),
              ),
            ),
            Text(
              "${(val * 100).toInt()}%",
              style: TextStyle(
                fontSize: 42,
                // Remplacement de FontWeight.black par FontWeight.w900
                fontWeight: FontWeight.w900,
                color: mainColor,
              ),
            ),
          ],
        );
      },
    );
  }
}