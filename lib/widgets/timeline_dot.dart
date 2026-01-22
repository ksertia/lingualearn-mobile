import 'package:flutter/material.dart';
import '../models/module_model.dart';

class TimelineDot extends StatelessWidget {
  final ModuleStatus status;

  const TimelineDot({
    super.key,
    required this.status,
  });

  Color get _color {
    switch (status) {
      case ModuleStatus.completed:
        return Color.fromARGB(255, 0, 206, 209);
      case ModuleStatus.inProgress:
        return Color.fromARGB(255, 255, 127, 0);
      case ModuleStatus.locked:
        return Colors.grey.shade300;
    }
  }

  IconData get _icon {
    switch (status) {
      case ModuleStatus.completed:
        return Icons.check;
      case ModuleStatus.inProgress:
        return Icons.play_arrow;
      case ModuleStatus.locked:
        return Icons.lock;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: _color,
            shape: BoxShape.circle,
          ),
          child: Icon(
            _icon,
            color: Colors.white,
            size: 16,
          ),
        ),
        Container(
          width: 2,
          height: 60,
          color: Colors.grey.shade300,
        ),
      ],
    );
  }
}
