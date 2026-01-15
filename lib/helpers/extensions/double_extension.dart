import 'package:fasolingo/helpers/theme/admin_theme.dart';
import 'package:flutter/material.dart';

extension DoubleExtension on double? {
  String get precise {
    if (this != null) {
      return this!.toStringAsFixed(this!.truncateToDouble() == this ? 0 : 1);
    }
    return '';
  }
}

Color withdrawalStatusColor(String status)
{
  switch(status)  {
    case "Withdraw":
      return AdminTheme.theme.contentTheme.withdrawalColor;
    case "Pending":
      return AdminTheme.theme.contentTheme.pendingColor;
    case "Approved":
      return AdminTheme.theme.contentTheme.withdrawalColor;
    case "Rejected":
      return AdminTheme.theme.contentTheme.rejectedColor;
    default:
      return AdminTheme.theme.contentTheme.withdrawalColor;
  }
}

Color withdrawalStatusTextColor(String status)
{
  switch(status)  {
    case "Withdraw":
      return AdminTheme.theme.contentTheme.withdrawalTextColor;
    case "Pending":
      return AdminTheme.theme.contentTheme.pendingTextColor;
    case "Approved":
      return AdminTheme.theme.contentTheme.withdrawalTextColor;
    case "Rejected":
      return AdminTheme.theme.contentTheme.rejectedTextColor;
    default:
      return AdminTheme.theme.contentTheme.withdrawalTextColor;
  }
}
