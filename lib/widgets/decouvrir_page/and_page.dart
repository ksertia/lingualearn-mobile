import 'package:confetti/confetti.dart';
import 'package:tibi/helpers/services/sound_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';


const Color _kOrange     = Color(0xFFF27F22);
const Color _kGreenDark  = Color(0xFF0F5C1C);

class StepSuccess {
  /// Affiche le popup de célébration par-dessus la page courante.
  static Future<void> show(BuildContext context) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha:0.55),
      transitionDuration: const Duration(milliseconds: 420),
      pageBuilder: (_, __, ___) => const _StepSuccessDialog(),
      transitionBuilder: (_, anim, __, child) {
        final curved =
            CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.12),
            end: Offset.zero,
          ).animate(curved),
          child: FadeTransition(opacity: anim, child: child),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _StepSuccessDialog extends StatefulWidget {
  const _StepSuccessDialog();

  @override
  State<_StepSuccessDialog> createState() => _StepSuccessDialogState();
}

class _StepSuccessDialogState extends State<_StepSuccessDialog>
    with TickerProviderStateMixin {
  late final ConfettiController _confetti;
  late final AnimationController _stagger;

  // animations en cascade
  late final Animation<double> _mascotScale;
  late final Animation<double> _badgeFade;
  late final Animation<double> _titleFade;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _rowFade;
  late final Animation<double> _btnFade;

  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();

    _confetti = ConfettiController(duration: const Duration(seconds: 4));

    _stagger = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );

    _mascotScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _stagger,
        curve: const Interval(0.00, 0.42, curve: Curves.elasticOut),
      ),
    );
    _badgeFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _stagger,
        curve: const Interval(0.28, 0.52, curve: Curves.easeIn),
      ),
    );
    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _stagger,
        curve: const Interval(0.38, 0.65, curve: Curves.easeIn),
      ),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.28),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _stagger,
      curve: const Interval(0.38, 0.70, curve: Curves.easeOutCubic),
    ));
    _rowFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _stagger,
        curve: const Interval(0.52, 0.78, curve: Curves.easeIn),
      ),
    );
    _btnFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _stagger,
        curve: const Interval(0.68, 1.00, curve: Curves.easeIn),
      ),
    );

    _confetti.play();
    _stagger.forward();
    SoundService.playCelebration();
  }

  @override
  void dispose() {
    _confetti.dispose();
    _stagger.dispose();
    super.dispose();
  }

  void _navigate(String route) {
    if (_isNavigating) return;
    _isNavigating = true;
    Navigator.of(context).pop();
    Get.offAllNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── Contenu du dialog ──────────────────────────────────────────────
        Center(
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding:
                EdgeInsets.symmetric(horizontal: 22.w, vertical: 48.h),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF0FDF4), Color(0xFFFFFDE7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28.r),
                border: Border.all(
                  color: _kOrange.withValues(alpha: 0.35),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: _kOrange.withValues(alpha: 0.18),
                    blurRadius: 32,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding:
                    EdgeInsets.fromLTRB(20.w, 28.h, 20.w, 24.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Mascotte avec bounce ─────────────────────────────
                    ScaleTransition(
                      scale: _mascotScale,
                      child: Lottie.asset(
                        'assets/lottie/Happy mascot.json',
                        width: 150.w,
                        repeat: true,
                      ),
                    ),
                    SizedBox(height: 10.h),

                    // ── Badge "Niveau validé" ────────────────────────────
                    FadeTransition(
                      opacity: _badgeFade,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 14.w, vertical: 7.h),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFDCFCE7), Color(0xFFFFFDE7)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(color: _kOrange, width: 1.2),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.emoji_events_rounded,
                                color: Colors.black,
                                size: 16.sp),
                            SizedBox(width: 6.w),
                            Text(
                              'Niveau validé !',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: _kGreenDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 14.h),

                    // ── Titre + description ──────────────────────────────
                    FadeTransition(
                      opacity: _titleFade,
                      child: SlideTransition(
                        position: _titleSlide,
                        child: Column(
                          children: [
                            Text(
                              'Bravo, champion !',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w900,
                                color: _kGreenDark,
                                letterSpacing: 0.4,
                              ),
                            ),
                            SizedBox(height: 10.h),
                            Text(
                              'Tu as débloqué un super pouvoir !'
                              'Inscris-toi pour sauvegarder ta progression.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.grey[600],
                                height: 1.55,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // ── Badges ───────────────────────────────────────────
                    FadeTransition(
                      opacity: _rowFade,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildBadge('✨ +20', 'Étoiles', _kOrange.withValues(alpha: 0.25)),
                          _buildBadge('🏅 +1',  'Badge',   Colors.black.withValues(alpha: 0.12)),
                          _buildBadge('💡 top', 'Astuces', const Color(0xFFE0F2FE)),
                        ],
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // ── Boutons ──────────────────────────────────────────
                    FadeTransition(
                      opacity: _btnFade,
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 52.h,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [_kOrange, _kOrange],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(14.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: _kOrange.withValues(alpha: 0.40),
                                    blurRadius: 14,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: () => _navigate('/register'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(14.r)),
                                ),
                                child: Text(
                                  "COMMENCER L'AVENTURE",
                                  style: TextStyle(
                                    color:  Colors.white,
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10.h),
                          TextButton(
                            onPressed: () => _navigate('/login'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.black,
                              minimumSize: Size(double.infinity, 40.h),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "J'ai déjà un compte",
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                Icon(Icons.arrow_forward_rounded,
                                    size: 15.sp),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ── Confettis par-dessus tout ──────────────────────────────────────
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confetti,
            blastDirectionality: BlastDirectionality.explosive,
            numberOfParticles: 35,
            shouldLoop: false,
            colors: const [
              _kOrange,
              _kOrange,
              Colors.white,
              Color(0xFF4ADE80),
              Color(0xFFFFF9C4),
              Color(0xFFDCFCE7),
              Color(0xFF1A1A1A),
            ],
            gravity: 0.15,
            maxBlastForce: 25,
            minBlastForce: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(String value, String label, Color bg) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Fallback si on atterrit sur la route /decouvert directement ───────────────

class StepSuccessPage extends StatelessWidget {
  const StepSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) StepSuccess.show(context);
    });
    return const Scaffold(
      backgroundColor: Color(0xFFFFFDE7),
      body: Center(
        child: CircularProgressIndicator(color: Colors.black),
      ),
    );
  }
}
