import 'package:fasolingo/helpers/theme/admin_theme.dart';
import 'package:flutter/material.dart';

class CustomCircularProgressIndicator extends StatelessWidget {
  final double? value;
  final Color? color;
  final double strokeWidth;

  CustomCircularProgressIndicator({
    this.value,
    this.color,
    this.strokeWidth = 4.0, // Default stroke width
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 48, // Adjust size as needed
        height: 48, // Adjust size as needed
        child: CircularProgressIndicator(
          value: value,
          valueColor: AlwaysStoppedAnimation<Color>(color ??  AdminTheme.theme.contentTheme.onPrimary,), // Use provided color or primary color
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}