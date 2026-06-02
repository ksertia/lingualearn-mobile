import 'package:fasolingo/helpers/theme/app_colors.dart';
import 'package:flutter/material.dart';

const Color _kGreen  = Color(0xFF188329);
const Color _kYellow = Color(0xFFF5BF1E);
const Color _kOrange = Color(0xFFF27F22);

class ParcoursStepItem extends StatelessWidget {
  final String number;
  final String title;
  final String subtitle;
  final Color color;
  final String? statusText;
  final bool isCompleted;
  final bool isActive;
  final VoidCallback? onTap;
  final IconData? icon;

  const ParcoursStepItem({
    super.key,
    required this.number,
    required this.title,
    required this.subtitle,
    required this.color,
    this.statusText,
    this.isCompleted = false,
    this.isActive = false,
    this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDimmed = !isActive && !isCompleted;

    final List<Color> stripeColors = isCompleted
        ? [_kGreen, _kYellow]
        : isActive
            ? [_kOrange, _kYellow]
            : [const Color(0xFFCFD8DC), const Color(0xFFB0BEC5)];

    final List<Color> circleColors = isCompleted
        ? [_kGreen, const Color(0xFF22A63B)]
        : isActive
            ? [_kOrange, const Color(0xFFFFB347)]
            : [const Color(0xFFB0BEC5), const Color(0xFFCFD8DC)];

    return Opacity(
      opacity: isDimmed ? 0.62 : 1.0,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(
            color: AppColors.card(context),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: color.withValues(alpha: isDimmed ? 0.10 : 0.22),
              width: 1.5,
            ),
            boxShadow: isDimmed
                ? []
                : [
                    BoxShadow(
                      color: color.withValues(alpha: 0.18),
                      blurRadius: 18,
                      offset: const Offset(0, 7),
                    ),
                  ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(23),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Gradient left stripe
                  Container(
                    width: 6,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: stripeColors,
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  // Number / icon circle
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: circleColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: isDimmed
                            ? []
                            : [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.32),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(Icons.check_rounded,
                                color: Colors.white, size: 26)
                            : (icon != null
                                ? Icon(icon, color: Colors.white, size: 24)
                                : Text(
                                    number,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  )),
                      ),
                    ),
                  ),
                  // Text content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 14, 8, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isCompleted
                                      ? Icons.check_circle_rounded
                                      : (isActive
                                          ? Icons.play_circle_filled
                                          : Icons.lock_rounded),
                                  color: color,
                                  size: 11,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  statusText ?? 'Verrouillé',
                                  style: TextStyle(
                                    color: color,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: isDimmed
                                  ? AppColors.textSecondary(context)
                                  : AppColors.textPrimary(context),
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.textSecondary(context),
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Right indicator
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: isActive
                              ? color.withValues(alpha: 0.10)
                              : AppColors.cardAlt(context),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isActive
                              ? Icons.arrow_forward_rounded
                              : Icons.lock_rounded,
                          color: isActive ? color : Colors.grey.shade400,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
