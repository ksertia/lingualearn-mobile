import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../helpers/utils/ui_mixins.dart';

class AppBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTabChange;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabChange,
  });

  @override
  State<AppBottomNavBar> createState() => _AppBottomNavBarState();
}

class _AppBottomNavBarState extends State<AppBottomNavBar>
    with SingleTickerProviderStateMixin, UIMixin {
  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItem(
        icon: LucideIcons.layoutDashboard,
        label: 'Accueil',
        index: 0,
      ),
      _NavItem(
        icon: LucideIcons.bookOpen,
        label: 'Historique',
        index: 1,
      ),
      _NavItem(
        icon: LucideIcons.trendingUp,
        label: 'Progrès',
        index: 2,
      ),
      _NavItem(
        icon: LucideIcons.personStanding,
        label: 'Profil',
        index: 3,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: contentTheme.bottomBarColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: items.map((item) {
              final isActive = widget.currentIndex == item.index;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => widget.onTabChange(item.index),
                      borderRadius: BorderRadius.circular(28),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isActive
                              ? Colors.blueAccent.withOpacity(0.14)
                              : contentTheme.bottomBarColor,
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              item.icon,
                              size: 22,
                              color: isActive
                                  ? Colors.blueAccent
                                  : contentTheme.textTertiary,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item.label,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11.5,
                                color: isActive
                                    ? Colors.blueAccent
                                    : contentTheme.textSecondary,
                                fontWeight: isActive
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                            if (isActive) const SizedBox(height: 6),
                            if (isActive)
                              Container(
                                width: 28,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.blueAccent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final int index;

  _NavItem({
    required this.icon,
    required this.label,
    required this.index,
  });
}
