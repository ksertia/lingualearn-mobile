import 'package:fasolingo/helpers/theme/admin_theme.dart';
import 'package:flutter/material.dart';

showMyDialog(
  BuildContext context, {
  required Widget content,
  List<Widget>? actions,
  String? title,
  double? borderRadius,
  EdgeInsetsGeometry? contentPadding,
}) {
  showDialog<void>(
    context: context,
    barrierDismissible: false, // Allow dismissing by tapping outside
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: AdminTheme.theme.contentTheme.kF6F6F6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              borderRadius ?? 16.0),
          side: BorderSide(
            color:
            AdminTheme.theme.contentTheme.kE6E6E6, // Set your desired border color here
            width: 1.0, // Optional: Adjust the border width
          ),
        ),
        contentPadding: contentPadding ??
            EdgeInsets.all(16.0), // Default to 16 if not provided
        title: title != null ? Text(title) : null,
        content: SingleChildScrollView(
          child: content,
        ),
        actions: actions,
      );
    },
  );
}
