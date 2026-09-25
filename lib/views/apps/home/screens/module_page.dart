import 'dart:async';
import 'package:confetti/confetti.dart';
import 'package:dio/dio.dart';
import 'package:tibi/helpers/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tibi/controller/apps/moduls/home_controller.dart';
import 'package:tibi/helpers/services/sound_service.dart';
import 'package:tibi/views/apps/home/screens/sub_themes_page.dart';

// ── Palette ────────────────────────────────────────────────────────────────
const Color _kGreen  = Color(0xFF188329);
const Color _kOrange = Color(0xFFF27F22);
const Color _kLocked = Color(0xFF9AA0A6);
const int _kThemesPerPage = 5;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late HomeController controller;

  bool _hasNetworkError = false;
  String _networkErrorMsg = '';
  bool _startHintDismissed = false;

  late final AnimationController _hintPulseController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  final ConfettiController _unlockConfettiController =
      ConfettiController(duration: const Duration(milliseconds: 700));
  Offset? _unlockBurstOrigin;

  Color _accent(String s) {
    if (s == 'completed') return _kGreen;
    if (s == 'locked') return _kLocked;
    return _kOrange;
  }

  @override
  void initState() {
    super.initState();
    // GetX réutilise silencieusement une instance déjà enregistrée quand on
    // rappelle Get.put (onInit() ne re-tourne pas) : sans ce Get.delete, un
    // HomeController resté enregistré depuis une précédente ouverture (avec
    // une autre langue/niveau) continuerait de servir ses anciennes données.
    if (Get.isRegistered<HomeController>()) {
      Get.delete<HomeController>(force: true);
    }
    controller = Get.put(HomeController());
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> _silentRefresh() async {
    try {
      await controller.onRefresh();
    } catch (_) {}
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) _silentRefresh();
  }

  Future<void> _reload() async {
    setState(() {
      _hasNetworkError = false;
      _networkErrorMsg = '';
    });
    try {
      await controller.loadThemes();
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _hasNetworkError = true;
        _networkErrorMsg = _dioErrorMsg(e);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _hasNetworkError = true;
        _networkErrorMsg = 'Une erreur inattendue s\'est produite.';
      });
    }
  }

  String _dioErrorMsg(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return 'Connexion trop lente. Vérifie ta connexion internet.';
    }
    if (e.type == DioExceptionType.connectionError || e.response == null) {
      return 'Pas de connexion internet. Vérifie ton réseau.';
    }
    final status = e.response?.statusCode ?? 0;
    if (status == 401 || status == 403) return 'Session expirée. Reconnecte-toi.';
    if (status >= 500) return 'Erreur serveur. Réessaie dans quelques instants.';
    return 'Impossible de charger les thèmes. Réessaie.';
  }

  String get _userId => controller.session.userId.value.isNotEmpty
      ? controller.session.userId.value
      : (controller.session.user?.id ?? '');

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _hintPulseController.dispose();
    _unlockConfettiController.dispose();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/app/plan1.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Obx(() {
              if (controller.isLoading.value) return _buildShimmer(context);
              if (_hasNetworkError) return _buildNetworkError(context);
              if (controller.hasSubscriptionError.value) {
                return _buildSubscriptionError(context);
              }
              if (controller.themeNodes.isEmpty) {
                return _buildEmptyThemes(context);
              }

              final themes = controller.themeNodes;
              final pages = <List<ThemeNode>>[];
              for (int i = 0; i < themes.length; i += _kThemesPerPage) {
                pages.add(themes.sublist(
                    i, (i + _kThemesPerPage).clamp(0, themes.length)));
              }

              return Column(
                children: [
                  SizedBox(
                      height: MediaQuery.of(context).padding.top +
                          kToolbarHeight +
                          16),
                  if (pages.length > 1) _buildPageIndicator(context, pages.length),
                  const SizedBox(height: 4),
                  Expanded(
                    child: PageView.builder(
                      controller: controller.pageController,
                      onPageChanged: controller.onPageChanged,
                      itemCount: pages.length,
                      itemBuilder: (_, i) => _buildThemesPage(
                          context, pages[i], i * _kThemesPerPage),
                    ),
                  ),
                ],
              );
            }),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + kToolbarHeight + 6,
            left: 20,
            right: 20,
            child: _buildStartHintBanner(context),
          ),
          if (_unlockBurstOrigin != null)
            Positioned(
              left: _unlockBurstOrigin!.dx - 60,
              top: _unlockBurstOrigin!.dy - 60,
              child: IgnorePointer(
                child: ConfettiWidget(
                  confettiController: _unlockConfettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  maxBlastForce: 10,
                  minBlastForce: 4,
                  emissionFrequency: 0.06,
                  numberOfParticles: 10,
                  gravity: 0.3,
                  colors: const [_kOrange, _kGreen, Color(0xFFFFB347)],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Bandeau flottant "choisis un thème" ─────────────────────────────────────

  Widget _buildStartHintBanner(BuildContext context) {
    return Obx(() {
      final show = !_startHintDismissed &&
          controller.themeNodes.isNotEmpty &&
          !controller.hasStartedAnyTheme;

      return IgnorePointer(
        ignoring: !show,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -0.25),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
              child: child,
            ),
          ),
          child: show
              ? KeyedSubtree(
                  key: const ValueKey('start-hint-shown'),
                  child: AnimatedBuilder(
                    animation: _hintPulseController,
                    builder: (context, child) {
                      final t = _hintPulseController.value;
                      return Opacity(
                        opacity: 0.72 + 0.28 * t,
                        child: Transform.scale(scale: 1 + 0.025 * t, child: child),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.97),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                            color: _kOrange.withValues(alpha: 0.25), width: 1.4),
                        boxShadow: [
                          BoxShadow(
                            color: _kOrange.withValues(alpha: 0.20),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [_kOrange, Color(0xFFFFB347)],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.auto_awesome_rounded,
                                color: Colors.white, size: 18),
                          ),
                          const SizedBox(width: 10),
                          const Flexible(
                            child: Text(
                              'Choisis un thème et lance-toi !',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () =>
                                setState(() => _startHintDismissed = true),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(Icons.close_rounded,
                                  size: 16, color: Colors.grey.shade400),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(key: ValueKey('start-hint-hidden')),
        ),
      );
    });
  }

  // ── Pagination ─────────────────────────────────────────────────────────────

  Widget _buildThemesPage(
      BuildContext context, List<ThemeNode> pageThemes, int startIndex) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 48),
      itemCount: pageThemes.length,
      itemBuilder: (_, index) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: _buildThemeCard(context, pageThemes[index], startIndex + index),
      ),
    );
  }

  Widget _buildPageIndicator(BuildContext context, int pageCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Center(
        child: Obx(() => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.96),
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildPageNavBtn(
                    Icons.arrow_back_ios_new_rounded,
                    controller.currentPage.value > 0,
                    () => controller.goToPage(controller.currentPage.value - 1),
                  ),
                  const SizedBox(width: 12),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(pageCount, (i) {
                      final isActive = i == controller.currentPage.value;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeOutCubic,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: isActive ? 22.0 : 7.0,
                        height: 7,
                        decoration: BoxDecoration(
                          gradient: isActive
                              ? const LinearGradient(
                                  colors: [_kOrange, Color(0xFFFFB347)])
                              : null,
                          color: isActive
                              ? null
                              : _kOrange.withValues(alpha: 0.20),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(width: 12),
                  _buildPageNavBtn(
                    Icons.arrow_forward_ios_rounded,
                    controller.currentPage.value < pageCount - 1,
                    () => controller.goToPage(controller.currentPage.value + 1),
                  ),
                ],
              ),
            )),
      ),
    );
  }

  Widget _buildPageNavBtn(IconData icon, bool enabled, VoidCallback onTap) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: enabled
              ? _kOrange.withValues(alpha: 0.12)
              : Colors.grey.withValues(alpha: 0.08),
          shape: BoxShape.circle,
        ),
        child: Icon(icon,
            size: 15, color: enabled ? _kOrange : Colors.grey.shade400),
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          color: _kOrange,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
        ),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: GestureDetector(
          onTap: Get.back,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2), width: 1),
            ),
            child: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white, size: 17),
          ),
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Mes Thèmes',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 18),
                ),
                Text(
                  'Choisis ton prochain défi',
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 14),
          child: GestureDetector(
            onTap: _reload,
            child: Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2), width: 1),
              ),
              child: const Icon(Icons.refresh_rounded,
                  color: Colors.white, size: 18),
            ),
          ),
        ),
      ],
    );
  }

  // ── Theme card ─────────────────────────────────────────────────────────────

  Widget _buildThemeCard(
      BuildContext context, ThemeNode themeNode, int themeIdx) {
    return Obx(() {
      final status =
          (controller.themeDisplayStatus[themeNode.theme.id] ?? 'locked')
              .toLowerCase();
      final isCompleted = status == 'completed';
      final isLocked = status == 'locked';
      final accent = _accent(status);
      final theme = themeNode.theme;

      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTapDown: isLocked
              ? (details) => _unlockBurstOrigin = details.globalPosition
              : null,
          onTap: () => _openTheme(themeNode, themeIdx, wasLocked: isLocked),
          child: Opacity(
            opacity: isLocked ? 0.75 : 1,
            child: Container(
              constraints: const BoxConstraints(minHeight: 92),
              decoration: BoxDecoration(
                color: AppColors.card(context),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: accent.withValues(alpha: 0.28), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.14),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(19),
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: Container(width: 5, color: accent),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                                isLocked
                                    ? Icons.lock_rounded
                                    : Icons.menu_book_rounded,
                                color: accent,
                                size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'THÈME ${themeIdx + 1}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.6,
                                    color: accent,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  theme.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15.5,
                                    color: AppColors.textPrimary(context),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                if (isLocked)
                                  Text(
                                    'Pas encore commencé',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: accent,
                                    ),
                                  )
                                else
                                  _buildThemeSubtitle(context, themeNode),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            isLocked
                                ? Icons.lock_rounded
                                : isCompleted
                                    ? Icons.check_circle_rounded
                                    : Icons.chevron_right_rounded,
                            color: accent,
                            size: 22,
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
      );
    });
  }

  // Nombre de sous-thèmes + progression (calculée côté backend à partir des
  // sous-thèmes) sous le titre d'un thème déverrouillé.
  Widget _buildThemeSubtitle(BuildContext context, ThemeNode themeNode) {
    return Obx(() {
      final pct = (themeNode.theme.progressPercentage ?? 0).round();
      final n = themeNode.subThemes.length;
      final parts = <String>[
        if (!themeNode.subThemesLoading.value)
          n <= 1 ? '$n sous-thème' : '$n sous-thèmes',
        if (pct > 0) '$pct%',
      ];
      if (parts.isEmpty) return const SizedBox.shrink();
      return Text(
        parts.join(' · '),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary(context),
        ),
      );
    });
  }

  void _openTheme(ThemeNode themeNode, int themeIdx, {required bool wasLocked}) {
    if (wasLocked) {
      // Premier tap sur un thème verrouillé : on le débloque seulement.
      // Le prochain tap ouvrira ses sous-thèmes.
      controller.markThemeOpened(themeNode);
      if (_unlockBurstOrigin != null) {
        setState(() {});
        _triggerUnlockCelebration();
      }
      return;
    }
    Get.to(
      () => SubThemesPage(
        controller: controller,
        themeNode: themeNode,
        themeIdx: themeIdx,
        userId: _userId,
      ),
      transition: Transition.circularReveal,
      curve: Curves.easeOutBack,
      duration: const Duration(milliseconds: 600),
    );
  }

  void _triggerUnlockCelebration() {
    SoundService.playUnlock();
    _unlockConfettiController.play();
    // Coupe l'émission après une seule salve courte : le paquet confetti
    // réémet en continu tant que le contrôleur "joue".
    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) _unlockConfettiController.stop();
    });
  }

  // ── Empty state ────────────────────────────────────────────────────────────

  Widget _buildEmptyThemes(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Container(
          padding:
              const EdgeInsets.symmetric(vertical: 36, horizontal: 28),
          decoration: BoxDecoration(
            color: AppColors.card(context),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: _kOrange.withValues(alpha: 0.10),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    _kOrange.withValues(alpha: 0.12),
                    _kOrange.withValues(alpha: 0.08),
                  ]),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.menu_book_outlined,
                    color: _kOrange, size: 44),
              ),
              const SizedBox(height: 20),
              Text(
                'Aucun thème disponible',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Il n\'y a pas encore de thème disponible pour cette langue et ce niveau.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary(context),
                    height: 1.5),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _reload,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Réessayer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kOrange,
                  foregroundColor: const Color(0xFF1A1A1A),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Network error ──────────────────────────────────────────────────────────

  Widget _buildNetworkError(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Container(
          padding:
              const EdgeInsets.symmetric(vertical: 36, horizontal: 28),
          decoration: BoxDecoration(
            color: AppColors.card(context),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE53E3E).withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.wifi_off_rounded,
                    color: Color(0xFFE53E3E), size: 44),
              ),
              const SizedBox(height: 20),
              Text(
                'Connexion perdue',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _networkErrorMsg,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary(context),
                    height: 1.5),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _reload,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Réessayer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kOrange,
                  foregroundColor: const Color(0xFF1A1A1A),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Subscription error ─────────────────────────────────────────────────────

  Widget _buildSubscriptionError(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Container(
          padding:
              const EdgeInsets.symmetric(vertical: 36, horizontal: 28),
          decoration: BoxDecoration(
            color: AppColors.card(context),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: _kOrange.withValues(alpha: 0.12),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _kOrange,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _kOrange.withValues(alpha: 0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.workspace_premium_rounded,
                    color: Colors.white, size: 44),
              ),
              const SizedBox(height: 20),
              Text(
                'Abonnement requis',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ton abonnement est expiré ou inactif.\nSouscris pour accéder à tous les thèmes.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary(context),
                    height: 1.5),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.toNamed('/subscription_plans'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kOrange,
                    foregroundColor: const Color(0xFF1A1A1A),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text(
                    'Voir les forfaits',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _reload,
                child: Text(
                  'Réessayer',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Shimmer ────────────────────────────────────────────────────────────────

  Widget _buildShimmer(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase(context),
      highlightColor: AppColors.shimmerHighlight(context),
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(
          20,
          MediaQuery.of(context).padding.top + kToolbarHeight + 16,
          20,
          40,
        ),
        itemCount: 6,
        itemBuilder: (_, i) {
          if (i == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 22),
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        },
      ),
    );
  }
}
