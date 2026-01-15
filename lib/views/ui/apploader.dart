import 'package:fasolingo/helpers/theme/admin_theme.dart';
import 'package:flutter/material.dart';

class AppLoader extends StatelessWidget {
  const AppLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: AdminTheme.theme.contentTheme.primary,
      ),
    );
  }
}
