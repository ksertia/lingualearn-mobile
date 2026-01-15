import 'package:fasolingo/helpers/my_widgets/my_text.dart';
import 'package:fasolingo/helpers/my_widgets/my_text_style.dart';
import 'package:fasolingo/helpers/theme/admin_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum SnackbarState {
  info,
  warning,
  danger,
  success,
  defaultState,
}

/// App themed snackbar
void appSnackbar({
  String? heading,
  required String message,
  SnackbarState snackbarState = SnackbarState.defaultState,
}) {
  Get.rawSnackbar(
    icon: Icon(_snackbarIcon(snackbarState), color: AdminTheme.theme.contentTheme.k0A0A0A),
    margin: const EdgeInsets.all(8),
    messageText: MyText.bodyMedium(
      message,
      style: MyTextStyle.displaySmall(
        fontSize: 14,
        fontWeight: 500,
        color: AdminTheme.theme.contentTheme.k0A0A0A,
      ),
    ),
    backgroundColor: _snackbarColor(snackbarState),
    borderRadius: 12,
    duration: const Duration(seconds: 5),
  );
}

Color _snackbarColor(SnackbarState snackbarState) {
  switch (snackbarState) {
    case SnackbarState.info:
      return Colors.blue;
    case SnackbarState.warning:
      return Colors.orangeAccent;
    case SnackbarState.danger:
      return Colors.red;
    case SnackbarState.defaultState:
      return AdminTheme.theme.contentTheme.black;
    case SnackbarState.success:
      return Colors.green;
  }
}

IconData _snackbarIcon(SnackbarState snackbarState) {
  switch (snackbarState) {
    case SnackbarState.info:
      return Icons.info;
    case SnackbarState.warning:
      return Icons.warning;
    case SnackbarState.danger:
      return Icons.error;
    case SnackbarState.defaultState:
      return Icons.notifications_active;
    case SnackbarState.success:
      return Icons.check_circle;
  }
}
