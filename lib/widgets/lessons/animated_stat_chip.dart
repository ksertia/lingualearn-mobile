import 'package:flutter/material.dart';

/// Petite carte de statistique (XP, score, temps...) avec animation d'entree
/// (rebond + fondu) et compteur montant pour les valeurs numeriques.
class AnimatedStatChip extends StatefulWidget {
  final String label;
  final int? countTo;
  final String suffix;
  final String? staticValue;
  final IconData icon;
  final Color color;
  final Duration delay;

  const AnimatedStatChip({
    super.key,
    required this.label,
    this.countTo,
    this.suffix = '',
    this.staticValue,
    required this.icon,
    required this.color,
    this.delay = Duration.zero,
  });

  @override
  State<AnimatedStatChip> createState() => _AnimatedStatChipState();
}

class _AnimatedStatChipState extends State<AnimatedStatChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    final fade = CurvedAnimation(
        parent: _ctrl, curve: const Interval(0, 0.5, curve: Curves.easeOut));
    final count = CurvedAnimation(
        parent: _ctrl, curve: const Interval(0.1, 1.0, curve: Curves.easeOut));

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final displayValue = widget.staticValue ??
            '${(widget.countTo! * count.value).round()}${widget.suffix}';
        return Opacity(
          opacity: fade.value.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: scale.value,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: widget.color, width: 1.5),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: widget.color,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(widget.icon, color: widget.color, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        displayValue,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: widget.color,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
