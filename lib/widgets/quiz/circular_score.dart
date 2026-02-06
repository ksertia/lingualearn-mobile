import 'package:flutter/material.dart';

class CircularScore extends StatelessWidget {
  final double value;
  const CircularScore({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: const Duration(milliseconds: 800),
      builder: (context, val, _) {
        return SizedBox(
          width: 120,
          height: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: val,
                strokeWidth: 10,
                backgroundColor: Colors.grey.shade300,
              ),
              Text(
                "${(val * 100).toInt()}%",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
