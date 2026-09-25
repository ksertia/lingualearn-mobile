import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tibi/helpers/services/sound_service.dart';

const Color _kOrange = Color(0xFFF27F22);
const Color _kGreen = Color(0xFF188329);

// Célébration affichée quand un thème est entièrement terminé (tous ses
// sous-thèmes complétés) : confetti + son + carte de félicitations.
class ModuleCompletedDialog extends StatefulWidget {
  final String moduleTitle;

  const ModuleCompletedDialog({super.key, required this.moduleTitle});

  static Future<void> show(String moduleTitle) {
    return Get.dialog(
      ModuleCompletedDialog(moduleTitle: moduleTitle),
      barrierDismissible: false,
    );
  }

  @override
  State<ModuleCompletedDialog> createState() => _ModuleCompletedDialogState();
}

class _ModuleCompletedDialogState extends State<ModuleCompletedDialog> {
  late final ConfettiController _confetti =
      ConfettiController(duration: const Duration(milliseconds: 1400));

  @override
  void initState() {
    super.initState();
    _confetti.play();
    SoundService.playCelebration();
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              maxBlastForce: 22,
              minBlastForce: 10,
              emissionFrequency: 0.10,
              numberOfParticles: 24,
              gravity: 0.35,
              colors: const [_kOrange, _kGreen, Color(0xFFFFB347), Colors.white],
            ),
          ),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.85, end: 1.0),
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeOutBack,
            builder: (context, scale, child) =>
                Transform.scale(scale: scale, child: child),
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 44, 24, 22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                    color: _kOrange.withValues(alpha: 0.15), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: 24,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Thème terminé ! 🎉',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.moduleTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _rewardBadge(Icons.emoji_events_rounded, Colors.amber),
                      const SizedBox(width: 10),
                      _rewardBadge(Icons.auto_awesome_rounded, _kGreen),
                      const SizedBox(width: 10),
                      _rewardBadge(Icons.star_rounded, Colors.pinkAccent),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: _kOrange.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Text(
                      'Bravo ! Un nouveau thème t\'attend, choisis-le pour continuer ton aventure.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF8A4A38),
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_kOrange, Color(0xFFFFB347)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: _kOrange.withValues(alpha: 0.35),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () => Get.back(),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Text(
                              'Continuer',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: -36,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.7, end: 1.0),
              duration: const Duration(milliseconds: 500),
              curve: Curves.elasticOut,
              builder: (context, scale, child) =>
                  Transform.scale(scale: scale, child: child),
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [_kOrange, Color(0xFFFFB347)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: _kOrange.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(Icons.celebration_rounded,
                    color: Colors.white, size: 36),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rewardBadge(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}
