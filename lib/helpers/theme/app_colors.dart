import 'package:flutter/material.dart';

/// Centralized dark/light color pairs.
/// Use Theme.of(context).brightness — no LocalStorage needed.
class AppColors {
  AppColors._();

  // ── Brand (same in both modes) ───────────────────────────────────────────
  static const Color green       = Color(0xFF188329);
  static const Color greenDark   = Color(0xFF0F5C1C);
  static const Color yellow      = Color(0xFFF5BF1E);
  static const Color orange      = Color(0xFFF27F22);
  static const Color orangeDark  = Color(0xFFC4611A);
  static const Color partnerGreen = Color(0xFF16A34A);
  static const Color blue        = Color(0xFF0EA5E9);
  static const Color purple      = Color(0xFF7C3AED);
  static const Color red         = Color(0xFFEF4444);
  static const Color locked      = Color(0xFFB0BEC5);

  // ── Brightness helper ────────────────────────────────────────────────────
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  // ── Backgrounds ──────────────────────────────────────────────────────────
  /// Page background (green-tinted light / near-black dark)
  static Color bg(BuildContext context) =>
      isDark(context) ? const Color(0xFF121212) : const Color(0xFFF3F8F3);

  /// Neutral page background (grey-light / near-black dark)
  static Color bgAlt(BuildContext context) =>
      isDark(context) ? const Color(0xFF121212) : const Color(0xFFF5F5F5);

  /// Auth / form page background
  static Color bgForm(BuildContext context) =>
      isDark(context) ? const Color(0xFF121212) : const Color(0xFFF6F8FF);

  /// Partner section background
  static Color bgPartner(BuildContext context) =>
      isDark(context) ? const Color(0xFF121212) : const Color(0xFFF4F6FA);

  // ── Surfaces / Cards ─────────────────────────────────────────────────────
  static Color card(BuildContext context) =>
      isDark(context) ? const Color(0xFF1E1E1E) : Colors.white;

  static Color cardAlt(BuildContext context) =>
      isDark(context) ? const Color(0xFF2A2A2A) : const Color(0xFFF8F8F8);

  // ── Text ─────────────────────────────────────────────────────────────────
  static Color textPrimary(BuildContext context) =>
      isDark(context) ? Colors.white : const Color(0xFF1A1A1A);

  static Color textSecondary(BuildContext context) =>
      isDark(context) ? Colors.white60 : const Color(0xFF888888);

  static Color textHint(BuildContext context) =>
      isDark(context) ? Colors.white38 : const Color(0xFF9E9E9E);

  static Color textLabel(BuildContext context) =>
      isDark(context) ? Colors.white70 : const Color(0xFF1E232C);

  // ── Borders / Dividers ───────────────────────────────────────────────────
  static Color divider(BuildContext context) =>
      isDark(context) ? Colors.white12 : const Color(0xFFEEEEEE);

  static Color border(BuildContext context) =>
      isDark(context) ? const Color(0xFF3A3A3A) : const Color(0xFFE0E0E0);

  // ── Form fields ──────────────────────────────────────────────────────────
  static Color inputFill(BuildContext context) =>
      isDark(context) ? const Color(0xFF2A2A2A) : Colors.white;

  // ── Icons ────────────────────────────────────────────────────────────────
  static Color icon(BuildContext context) =>
      isDark(context) ? Colors.white70 : Colors.black54;

  // ── Shimmer ──────────────────────────────────────────────────────────────
  static Color shimmerBase(BuildContext context) =>
      isDark(context) ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0);

  static Color shimmerHighlight(BuildContext context) =>
      isDark(context) ? const Color(0xFF3A3A3A) : const Color(0xFFF5F5F5);

  // ── Overlay / shadow ─────────────────────────────────────────────────────
  static Color shadow(BuildContext context) =>
      isDark(context)
          ? Colors.black.withValues(alpha: 0.35)
          : Colors.black.withValues(alpha: 0.06);
}
