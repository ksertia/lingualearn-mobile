import 'package:fasolingo/helpers/theme/admin_theme.dart';
import 'package:flutter/material.dart';

class MySpacing {
  static EdgeInsets zero = EdgeInsets.zero;

  static Color withdrawalStatusTextColor(String status) {
    switch (status) {
      case "COMPLETED":
        return AdminTheme.theme.contentTheme.withdrawalTextColor;
      case "PENDING":
        return AdminTheme.theme.contentTheme.pendingTextColor;
      case "APPROVED":
        return AdminTheme.theme.contentTheme.withdrawalTextColor;
      case "REJECTED":
        return AdminTheme.theme.contentTheme.rejectedTextColor;
      case "FAILURE":
        return AdminTheme.theme.contentTheme.rejectedTextColor;
      default:
        return AdminTheme.theme.contentTheme.withdrawalTextColor;
    }
  }

  static Color withdrawalStatusColor(String status) {
    switch (status) {
      case "COMPLETED":
        return AdminTheme.theme.contentTheme.withdrawalColor;
      case "PENDING":
        return AdminTheme.theme.contentTheme.pendingColor;
      case "APPROVED":
        return AdminTheme.theme.contentTheme.withdrawalColor;
      case "REJECTED":
        return AdminTheme.theme.contentTheme.rejectedColor;
      case "FAILURE":
        return AdminTheme.theme.contentTheme.rejectedColor;
      default:
        return AdminTheme.theme.contentTheme.withdrawalColor;
    }
  }

  static EdgeInsets only(
      {double top = 0, double right = 0, double bottom = 0, double left = 0}) {
    return EdgeInsets.only(left: left, right: right, top: top, bottom: bottom);
  }

  static EdgeInsets fromLTRB(
      double left, double top, double right, double bottom) {
    return MySpacing.only(bottom: bottom, top: top, right: right, left: left);
  }

  static EdgeInsets all(double spacing) {
    return MySpacing.only(
        bottom: spacing, top: spacing, right: spacing, left: spacing);
  }

  static EdgeInsets left(double spacing) {
    return MySpacing.only(left: spacing);
  }

  static EdgeInsets nLeft(double spacing) {
    return MySpacing.only(top: spacing, bottom: spacing, right: spacing);
  }

  static EdgeInsets top(double spacing) {
    return MySpacing.only(top: spacing);
  }

  static EdgeInsets nTop(double spacing) {
    return MySpacing.only(left: spacing, bottom: spacing, right: spacing);
  }

  static EdgeInsets right(double spacing) {
    return MySpacing.only(right: spacing);
  }

  static EdgeInsets nRight(double spacing) {
    return MySpacing.only(top: spacing, bottom: spacing, left: spacing);
  }

  static EdgeInsets bottom(double spacing) {
    return MySpacing.only(bottom: spacing);
  }

  static EdgeInsets nBottom(double spacing) {
    return MySpacing.only(top: spacing, left: spacing, right: spacing);
  }

  static EdgeInsets horizontal(double spacing) {
    return MySpacing.only(left: spacing, right: spacing);
  }

  static EdgeInsets x(double spacing) {
    return MySpacing.only(left: spacing, right: spacing);
  }

  static EdgeInsets xy(double xSpacing, double ySpacing) {
    return MySpacing.only(
        left: xSpacing, right: xSpacing, top: ySpacing, bottom: ySpacing);
  }

  static EdgeInsets y(double spacing) {
    return MySpacing.only(top: spacing, bottom: spacing);
  }

  static EdgeInsets vertical(double spacing) {
    return MySpacing.only(top: spacing, bottom: spacing);
  }

  static EdgeInsets symmetric({double vertical = 0, double horizontal = 0}) {
    return MySpacing.only(
        top: vertical, right: horizontal, left: horizontal, bottom: vertical);
  }

  static SizedBox height(double height) {
    return SizedBox(
      height: height,
    );
  }

  static double fullWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double fullHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static SizedBox width(double width) {
    return SizedBox(
      width: width,
    );
  }

  static Widget empty() {
    return SizedBox(width: 0, height: 0);
  }

  static double safeAreaTop(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }
}
