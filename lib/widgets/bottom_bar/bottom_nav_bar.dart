import 'package:fasolingo/helpers/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

const Color _kGreen     = Color(0xFF188329);
const Color _kGreenDark = Color(0xFF0F5C1C);

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabChange;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final bg     = AppColors.card(context);
    final shadow = isDark
        ? Colors.black.withValues(alpha: 0.40)
        : Colors.black.withValues(alpha: 0.08);

    const items = [
      _NavItem(icon: LucideIcons.layoutDashboard, label: 'Accueil',    index: 0),
      _NavItem(icon: LucideIcons.bookOpen,        label: 'Historique', index: 1),
      _NavItem(icon: LucideIcons.trendingUp,      label: 'Progrès',    index: 2),
      _NavItem(icon: LucideIcons.personStanding,  label: 'Profil',     index: 3),
    ];

    return Container(
      decoration: BoxDecoration(
        color: bg,
        border: Border(
          top: BorderSide(
            color: AppColors.divider(context),
            width: 0.8,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: shadow,
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.map((item) {
              final isActive = currentIndex == item.index;
              return Expanded(
                child: _NavTab(
                  item: item,
                  isActive: isActive,
                  bg: bg,
                  onTap: () => onTabChange(item.index),
                  context: context,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// ── Onglet individuel ─────────────────────────────────────────────────────────

class _NavTab extends StatelessWidget {
  final _NavItem item;
  final bool isActive;
  final Color bg;
  final VoidCallback onTap;
  final BuildContext context;

  const _NavTab({
    required this.item,
    required this.isActive,
    required this.bg,
    required this.onTap,
    required this.context,
  });

  @override
  Widget build(BuildContext ctx) {
    final activeColor   = _kGreen;
    final inactiveColor = AppColors.textSecondary(context);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? _kGreen.withValues(alpha: 0.10)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icône
            AnimatedScale(
              scale: isActive ? 1.12 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                item.icon,
                size: 22,
                color: isActive ? activeColor : inactiveColor,
              ),
            ),
            const SizedBox(height: 5),
            // Label
            Text(
              item.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: isActive ? activeColor : inactiveColor,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: isActive ? 0.1 : 0,
              ),
            ),
            // Indicateur actif
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: const EdgeInsets.only(top: 5),
              width: isActive ? 24 : 0,
              height: isActive ? 3 : 0,
              decoration: BoxDecoration(
                gradient: isActive
                    ? const LinearGradient(colors: [_kGreen, _kGreenDark])
                    : null,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Modèle item ───────────────────────────────────────────────────────────────

class _NavItem {
  final IconData icon;
  final String label;
  final int index;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
  });
}
