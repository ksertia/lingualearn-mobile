import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:tibi/widgets/lessons/animated_stat_chip.dart';
import 'package:tibi/widgets/mascots/zaki_mascot.dart';
import 'package:tibi/widgets/quiz/confetti_widget.dart';
import '../../../../controller/apps/etapes/stepController.dart';
import '../../../../widgets/bottom_bar/navigation_provider.dart';

const Color _kOrange = Color(0xFFF27F22);


/// Page de recompense affichee apres un quiz : celebre les XP gagnes puis
/// valide la completion de l'etape au clic sur "Continuer".
class XpRewardScreen extends StatelessWidget {
  final int xp;
  final int scorePercent;
  final Duration elapsed;
  final String stepId;
  final String userId;
  final StepController controller;

  const XpRewardScreen({
    super.key,
    required this.xp,
    required this.scorePercent,
    required this.elapsed,
    required this.stepId,
    required this.userId,
    required this.controller,
  });

  String get _message {
    if (scorePercent == 100) return 'Score parfait, tu es un champion !';
    if (scorePercent >= 70) return 'Excellent travail, continue comme ça !';
    return 'Bien joué, chaque étape compte !';
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            const Positioned.fill(child: ConfettiWidget()),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const Spacer(),
                    const ZakiMascot(
                      mood: ZakiMood.victory,
                      size: ZakiSize.xl,
                      animated: true,
                    ),
                    const SizedBox(height: 8),
                    _XpBurst(xp: xp),
                    const SizedBox(height: 20),
                    const Text(
                      'Bravo, leçon terminée !',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF888888),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(
                          child: AnimatedStatChip(
                            label: 'SCORE',
                            countTo: scorePercent,
                            suffix: '%',
                            icon: Icons.track_changes_rounded,
                            color: const Color(0xFF58CC02),
                            delay: const Duration(milliseconds: 700),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AnimatedStatChip(
                            label: 'TEMPS',
                            staticValue: _formatDuration(elapsed),
                            icon: Icons.timer_outlined,
                            color: const Color(0xFF1CB0F6),
                            delay: const Duration(milliseconds: 900),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Obx(
                      () => SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: controller.isCompleting.value
                              ? null
                              : () => controller.completeCurrentStep(
                                    stepId: stepId,
                                    userId: userId,
                                  ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _kOrange,
                            disabledBackgroundColor: Colors.grey.shade300,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18)),
                            elevation: 0,
                          ),
                          child: controller.isCompleting.value
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Continuer',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.until((route) => route.isFirst);
                        context.read<NavigationProvider>().goToProgres();
                      },
                      child: Text(
                        'Voir ma progression',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Badge XP geant qui rebondit a l'apparition puis compte jusqu'a [xp].
class _XpBurst extends StatefulWidget {
  final int xp;
  const _XpBurst({required this.xp});

  @override
  State<_XpBurst> createState() => _XpBurstState();
}

class _XpBurstState extends State<_XpBurst> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    final count = CurvedAnimation(
        parent: _ctrl, curve: const Interval(0.15, 1.0, curve: Curves.easeOut));

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final value = (widget.xp * count.value).round();
        return Transform.scale(
          scale: scale.value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_kOrange, _kOrange],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: _kOrange.withValues(alpha: 0.40),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.bolt_rounded, color: Colors.white, size: 32),
                const SizedBox(width: 8),
                Text(
                  '+$value XP',
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
