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
  final Random random = Random();

  @override
  void initState() {
    super.initState();
    _controller =
    AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat();
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
      builder: (_, __) {
        return Stack(
          children: List.generate(20, (index) {
            final double top =
                _controller.value * MediaQuery.of(context).size.height;
            final double left =
                random.nextDouble() * MediaQuery.of(context).size.width;

            return Positioned(
              top: top - random.nextDouble() * 100,
              left: left,
              child: Transform.rotate(
                angle: random.nextDouble() * pi,
                child: Container(
                  width: 8,
                  height: 8,
                  color: Colors.primaries[
                  random.nextInt(Colors.primaries.length)],
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
