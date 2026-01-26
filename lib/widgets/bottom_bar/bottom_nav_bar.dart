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
        label: 'Dashboard',
        index: 0,
      ),
      _NavItem(
        icon: LucideIcons.bookOpen, 
        label: 'Lexique',
        index: 1,
      ),
      _NavItem(
        icon: LucideIcons.trendingUp, 
        label: 'Progrès',
        index: 2,
      ),
      _NavItem(
        icon: LucideIcons.user, 
        label: 'Paramètres',
        index: 3,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.map((item) {
              final isActive = widget.currentIndex == item.index;
              return Expanded(
                child: InkWell(
                  onTap: () => widget.onTabChange(item.index),
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: isActive
                          ? const LinearGradient(
                              colors: [
                                Color(0xFFDBeafe),
                                Color(0xFFD1FAE5),
                              ],
                            )
                          : null,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.icon,
                          size: 20,
                          color: isActive
                              ? contentTheme.onPrimary
                              : contentTheme.textTertiary,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 12,
                            color: isActive
                                ? contentTheme.onPrimary
                                : contentTheme.textSecondary,
                            fontWeight:
                                isActive ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
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
