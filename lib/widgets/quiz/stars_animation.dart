import 'package:flutter/material.dart';

class StarsAnimation extends StatelessWidget {
  final int stars;
  const StarsAnimation({super.key, required this.stars});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: index < stars ? 1 : 0),
          duration: Duration(milliseconds: 400 + index * 200),
          builder: (_, value, __) {
            return Transform.scale(
              scale: value,
              child: Icon(
                Icons.star,
                color: index < stars ? Colors.amber : Colors.grey,
                size: 32,
              ),
            );
          },
        );
      }),
    );
  }
}
