// lib/widgets/parcours_item.dart
import 'package:flutter/material.dart';

class ParcoursItem extends StatelessWidget {
  final String label;
  final String status;
  final Color statusColor;
  final IconData icon;
  final double progress;
  final String countText;
  final VoidCallback? onTap;

  const ParcoursItem({
    super.key,
    required this.label,
    required this.status,
    required this.statusColor,
    required this.icon,
    required this.progress,
    required this.countText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(width: 2, color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(icon, color: statusColor),
                      const SizedBox(width: 20),
                      Text(
                        '$label:',
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 17,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        status,
                        style: TextStyle(color: statusColor, fontSize: 17),
                      ),
                    ],
                  ),
                  Text(
                    countText,
                    style: TextStyle(
                        color: statusColor,
                        fontSize: 17,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}