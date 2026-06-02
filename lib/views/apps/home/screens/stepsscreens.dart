import 'dart:async';
import 'package:dio/dio.dart';
import 'package:fasolingo/controller/apps/etapes/etapes_controller.dart';
import 'package:fasolingo/helpers/theme/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fasolingo/helpers/services/etapes/etape_service.dart';
import 'package:fasolingo/helpers/services/parcoure/parcoure_service.dart';
import 'package:fasolingo/views/apps/home/StepContentScreen.dart';
import 'package:fasolingo/widgets/stepsscreens/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import 'package:fasolingo/models/parcoure/parcour_model.dart';
import '../../../../widgets/stepsscreens/parcours_item.dart';

// ── Palette ────────────────────────────────────────────────────────────────
const Color _kGreen     = Color(0xFF188329);
const Color _kGreenDark = Color(0xFF0F5C1C);
const Color _kYellow    = Color(0xFFF5BF1E);
const Color _kOrange    = Color(0xFFF27F22);

const Color _sCompleted = _kGreen;
const Color _sActive    = _kOrange;
const Color _sLocked    = Color(0xFFB0BEC5);

void _showSubscriptionRequired(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => Container(
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44, height: 4,
            decoration: BoxDecoration(
                color: AppColors.divider(context),
                borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [_kOrange, _kYellow],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: _kOrange.withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8))
              ],
            ),
            child: const Icon(Icons.workspace_premium_rounded,
                color: Colors.white, size: 38),
          ),
          const SizedBox(height: 22),
          Text('Abonnement requis',
              style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontSize: 22,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          Text(
            'Accédez à toutes les étapes en illimité.\nSouscrivez dès maintenant et commencez à apprendre.',
            textAlign: TextAlign.center,
            style:
                TextStyle(color: Colors.grey.shade500, fontSize: 14, height: 1.6),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Get.toNamed('/subscription_plans');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _kGreen,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text('Voir les forfaits',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16)),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Plus tard',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
          ),
        ],
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────

class StepsScreensPages extends StatefulWidget {
  const StepsScreensPages({super.key});

  @override
  State<StepsScreensPages> createState() => _StepsScreensPagesState();
}

class _StepsScreensPagesState extends State<StepsScreensPages>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late StepsController controller;
  late BuildContext _ctx;

  bool _hasNetworkError = false;
  String _networkErrorMsg = '';

  Timer? _autoRefreshTimer;
  static const Duration _refreshInterval = Duration(seconds: 60);

  // ─── Guide ─────────────────────────────────────────────────────────────────
  bool _showGuide = false;
  late final AnimationController _bounceCtrl;
  late final Animation<double> _bounceAnim;
  Worker? _guideWorker;

  @override
  void initState() {
    super.initState();
    controller = Get.put(StepsController());
    WidgetsBinding.instance.addObserver(this);
    _startAutoRefresh();

    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _bounceAnim = Tween<double>(begin: 0.0, end: 8.0).animate(
      CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeInOut),
    );
    _checkGuideOnLoad();
  }

  Future<void> _checkGuideOnLoad() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('steps_guide_shown') ?? false) return;

    _guideWorker = ever(controller.isLoading, (bool loading) async {
      if (loading) return;
      if (controller.items.isEmpty) return;
      _guideWorker?.dispose();
      _guideWorker = null;
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      setState(() => _showGuide = true);
      _bounceCtrl.repeat(reverse: true);
    });
  }

  Future<void> _dismissStepsGuide() async {
    if (!mounted) return;
    setState(() => _showGuide = false);
    _bounceCtrl.stop();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('steps_guide_shown', true);
  }

  void _startAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(_refreshInterval, (_) {
      if (mounted && !controller.isLoading.value) _silentRefresh();
    });
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
      await controller.onRefresh();
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
    return 'Impossible de charger les étapes. Réessaie.';
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _autoRefreshTimer?.cancel();
    _bounceCtrl.dispose();
    _guideWorker?.dispose();
    super.dispose();
  }

  // ── Guide widget ───────────────────────────────────────────────────────────

  Widget _buildStepsGuide() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Bulle tooltip
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_kGreen, _kGreenDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _kGreen.withValues(alpha: 0.30),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lightbulb_rounded, color: _kYellow, size: 20),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Clique sur la première étape pour voir son contenu !',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.45,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _dismissStepsGuide,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.20),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded,
                        color: Colors.white, size: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // Doigt animé — steps pleine largeur → centre = maxWidth / 2
          LayoutBuilder(
            builder: (_, constraints) {
              final fingerX = constraints.maxWidth / 2 - 15;
              return SizedBox(
                height: 46,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AnimatedBuilder(
                      animation: _bounceAnim,
                      builder: (_, child) => Positioned(
                        left: fingerX,
                        top: _bounceAnim.value,
                        child: child!,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomPaint(
                            size: const Size(14, 7),
                            painter: _StepsTrianglePainter(color: _kGreen),
                          ),
                          const SizedBox(height: 2),
                          const Icon(Icons.touch_app_rounded,
                              color: _kGreen, size: 30),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    _ctx = context;
    final dynamic args = Get.arguments;
    final String moduleLottie =
        (args is Map && args['moduleLottie'] != null)
            ? args['moduleLottie'].toString()
            : 'assets/lottie/Lion.json';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const CustomAppBar(title: 'Mes Étapes'),
      body: Container(
        constraints: const BoxConstraints.expand(),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/app/plan2.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Obx(() {
          if (controller.isLoading.value) return _buildShimmer();
          if (_hasNetworkError) return _buildNetworkError();
          if (controller.items.isEmpty) return _buildEmpty();

          final List<_PageData> pages = [];
          LearningPathModel? currentPath;
          List<StepModel> currentSteps = [];
          for (final item in controller.items) {
            if (item is LearningPathModel) {
              if (currentPath != null) {
                pages.add(
                    _PageData(path: currentPath, steps: [...currentSteps]));
              }
              currentPath = item;
              currentSteps = [];
            } else if (item is StepModel) {
              currentSteps.add(item);
            }
          }
          if (currentPath != null) {
            pages.add(_PageData(path: currentPath, steps: [...currentSteps]));
          } else if (currentSteps.isNotEmpty) {
            pages.add(_PageData(path: null, steps: currentSteps));
          }

          return Stack(
            children: [
              RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    _hasNetworkError = false;
                    _networkErrorMsg = '';
                  });
                  try {
                    await controller.onRefresh();
                  } on DioException catch (e) {
                    if (!mounted) return;
                    setState(() {
                      _hasNetworkError = true;
                      _networkErrorMsg = _dioErrorMsg(e);
                    });
                  } catch (_) {}
                },
                color: _kGreen,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height),
                    child: Column(
                      children: [
                        SizedBox(
                            height: MediaQuery.of(context).padding.top +
                                kToolbarHeight +
                                16),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildHeaderCard(moduleLottie, pages),
                        ),
                        const SizedBox(height: 16),
                        _buildPagesSection(context, pages),
                        const SizedBox(height: 90),
                      ],
                    ),
                  ),
                ),
              ),
              // Sticky "Parcours terminé" button
              Positioned(
                left: 0, right: 0, bottom: 0,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Obx(() {
                      if (pages.isEmpty) return const SizedBox.shrink();
                      final pageIdx = controller.currentPage.value
                          .clamp(0, pages.length - 1);
                      final page = pages[pageIdx];
                      if (page.path == null) return const SizedBox.shrink();

                      final allDone = page.steps.isNotEmpty &&
                          page.steps.every((s) {
                            final st = (s.progress != null &&
                                    s.progress!['status'] != null)
                                ? s.progress!['status']
                                    .toString()
                                    .toLowerCase()
                                : (s.status ?? 'locked').toLowerCase();
                            return st == 'completed';
                          });
                      if (!allDone) return const SizedBox.shrink();

                      final a = Get.arguments;
                      final userId =
                          (a is Map && a['userId'] != null)
                              ? a['userId'].toString()
                              : '';

                      return Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [_kGreen, _kGreenDark],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: _kGreen.withValues(alpha: 0.40),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: userId.isEmpty
                              ? null
                              : () async {
                                  final ok =
                                      await LearningPathService.completePath(
                                    userId: userId,
                                    pathId: page.path!.id,
                                  );
                                  if (ok) Get.back(result: true);
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            minimumSize: const Size(double.infinity, 52),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_rounded,
                                  color: Colors.white, size: 20),
                              SizedBox(width: 8),
                              Text('Parcours terminé !',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16)),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // ── Header card ───────────────────────────────────────────────────────────

  Widget _buildHeaderCard(String lottie, List<_PageData> pages) {
    final totalSteps =
        pages.fold<int>(0, (sum, p) => sum + p.steps.length);
    final doneSteps = pages.fold<int>(0, (sum, p) {
      return sum +
          p.steps.where((s) {
            final st = (s.progress != null && s.progress!['status'] != null)
                ? s.progress!['status'].toString().toLowerCase()
                : (s.status ?? 'locked').toLowerCase();
            return st == 'completed';
          }).length;
    });
    final activeSteps = pages.fold<int>(0, (sum, p) {
      return sum +
          p.steps.where((s) {
            final st = (s.progress != null && s.progress!['status'] != null)
                ? s.progress!['status'].toString().toLowerCase()
                : (s.status ?? 'locked').toLowerCase();
            return st == 'unlocked' || st == 'started' || st == 'in_progress';
          }).length;
    });
    final lockedSteps =
        (totalSteps - doneSteps - activeSteps).clamp(0, totalSteps);
    final pct = totalSteps > 0 ? doneSteps / totalSteps : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card(_ctx),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: _kGreen.withValues(alpha: 0.20),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Green gradient banner
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_kGreen, _kGreenDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '🎯 $totalSteps étape${totalSteps > 1 ? 's' : ''}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Mes Étapes',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Progresse étape par étape !',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25), width: 1),
                  ),
                  child: Lottie.asset(lottie, fit: BoxFit.contain, repeat: true),
                ),
              ],
            ),
          ),
          // Progress + stats
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progression globale',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [_kGreen, Color(0xFF22A63B)]),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${(pct * 100).toInt()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 7,
                    backgroundColor: _kGreen.withValues(alpha: 0.08),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(_kGreen),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildStatPill(Icons.check_circle_rounded,
                        '$doneSteps', 'Terminées', _kGreen),
                    const SizedBox(width: 6),
                    _buildStatPill(Icons.play_circle_filled,
                        '$activeSteps', 'En cours', _kOrange),
                    const SizedBox(width: 6),
                    _buildStatPill(Icons.lock_rounded,
                        '$lockedSteps', 'À venir', _sLocked),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatPill(
      IconData icon, String count, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(14),
          border:
              Border.all(color: color.withValues(alpha: 0.15), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 15),
            const SizedBox(height: 3),
            Text(count,
                style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w900)),
            Text(label,
                style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 9,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  // ── Pages section ─────────────────────────────────────────────────────────

  Widget _buildPagesSection(BuildContext context, List<_PageData> pages) {
    if (pages.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        if (pages.length > 1)
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Obx(() => Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                            color: _kGreen.withValues(alpha: 0.15), width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: _kGreen.withValues(alpha: 0.10),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildNavBtn(
                            Icons.arrow_back_ios_new,
                            controller.currentPage.value > 0,
                            () => controller.goToPage(
                                controller.currentPage.value - 1),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Parcours ${controller.currentPage.value + 1} / ${pages.length}',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: AppColors.textPrimary(_ctx)),
                          ),
                          const SizedBox(width: 10),
                          _buildNavBtn(
                            Icons.arrow_forward_ios,
                            controller.currentPage.value < pages.length - 1,
                            () => controller.goToPage(
                                controller.currentPage.value + 1),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Animated dots indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(pages.length, (i) {
                        final isActive =
                            i == controller.currentPage.value;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          margin:
                              const EdgeInsets.symmetric(horizontal: 3),
                          width: isActive ? 24.0 : 8.0,
                          height: 8,
                          decoration: BoxDecoration(
                            gradient: isActive
                                ? const LinearGradient(
                                    colors: [_kGreen, _kYellow])
                                : null,
                            color: isActive
                                ? null
                                : _kGreen.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                  ],
                )),
          ),
        const SizedBox(height: 8),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.72,
          child: PageView.builder(
            controller: controller.pageController,
            onPageChanged: controller.onPageChanged,
            itemCount: pages.length,
            itemBuilder: (_, i) => _buildStepsPage(pages[i], i),
          ),
        ),
      ],
    );
  }

  Widget _buildNavBtn(IconData icon, bool enabled, VoidCallback onTap) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: enabled
              ? _kGreen.withValues(alpha: 0.12)
              : Colors.grey.withValues(alpha: 0.08),
          shape: BoxShape.circle,
        ),
        child: Icon(icon,
            size: 15,
            color: enabled ? _kGreen : Colors.grey.shade400),
      ),
    );
  }

  // ── Steps page ────────────────────────────────────────────────────────────

  Widget _buildStepsPage(_PageData page, [int pageIndex = 0]) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (page.path != null) _buildPathHeader(page.path!),
          if (page.path == null) _buildFallbackHeader(),
          const SizedBox(height: 8),
          Expanded(
            child: Builder(
              builder: (context) => ListView.builder(
                padding: const EdgeInsets.only(top: 4, bottom: 16),
                itemCount: page.steps.length,
                itemBuilder: (context, i) {
                  final step = page.steps[i];
                  final stepStatus = (step.progress != null &&
                          step.progress!['status'] != null)
                      ? step.progress!['status'].toString().toLowerCase()
                      : (step.status ?? 'locked').toLowerCase();
                  final isCompleted = stepStatus == 'completed';
                  final isActive = stepStatus == 'unlocked' ||
                      stepStatus == 'started' ||
                      stepStatus == 'in_progress' ||
                      isCompleted;

                  final stepItem = Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ParcoursItem(
                      label: 'Étape ${i + 1} : ${step.title}',
                      status: isCompleted
                          ? 'Terminé'
                          : (isActive ? 'En cours' : 'Verrouillé'),
                      mainColor: isActive
                          ? (isCompleted ? _sCompleted : _sActive)
                          : _sLocked,
                      isCompleted: isCompleted,
                      isActive: isActive,
                      icon: !isActive
                          ? Icons.lock_rounded
                          : (isCompleted
                              ? Icons.check_rounded
                              : Icons.play_arrow_rounded),
                      onTap: isActive
                          ? () async {
                              if (i == 0 && pageIndex == 0 && _showGuide) {
                                _dismissStepsGuide();
                              }
                              if (!controller.isSubscriptionActive.value) {
                                _showSubscriptionRequired(context);
                                return;
                              }
                              final a = Get.arguments;
                              final userId =
                                  (a is Map && a['userId'] != null)
                                      ? a['userId'].toString()
                                      : (controller.session?.userId.value ??
                                          '');
                              if (userId.isNotEmpty &&
                                  stepStatus == 'unlocked') {
                                await StepsService.startStep(
                                    userId: userId, stepId: step.id);
                              }
                              final res = await Get.to(
                                () => StepContentScreen(
                                    stepId: step.id, userId: userId),
                                transition: Transition.rightToLeft,
                              );
                              if (res == true) await _silentRefresh();
                            }
                          : () => Get.snackbar(
                                '🔒 Étape verrouillée',
                                'Complète les étapes précédentes pour débloquer celle-ci.',
                                backgroundColor: const Color(0xFF1A1A1A),
                                colorText: Colors.white,
                                snackPosition: SnackPosition.BOTTOM,
                                margin: const EdgeInsets.all(16),
                                borderRadius: 16,
                                icon: const Icon(Icons.lock_rounded,
                                    color: Colors.white70),
                              ),
                    ),
                  );

                  if (i == 0 && pageIndex == 0 && _showGuide) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildStepsGuide(),
                        stepItem,
                      ],
                    );
                  }
                  return stepItem;
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPathHeader(LearningPathModel path) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _kGreen.withValues(alpha: 0.10),
            _kYellow.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: _kGreen.withValues(alpha: 0.20), width: 1.5),
        boxShadow: [
          BoxShadow(
              color: _kGreen.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_kGreen, Color(0xFF22A63B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                    color: _kGreen.withValues(alpha: 0.30),
                    blurRadius: 8,
                    offset: const Offset(0, 3)),
              ],
            ),
            child: const Icon(Icons.route_rounded,
                color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(path.title,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary(_ctx))),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackHeader() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(18),
        border:
            Border.all(color: _kGreen.withValues(alpha: 0.12), width: 1),
      ),
      child: Text('Étapes du parcours',
          style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary(_ctx))),
    );
  }

  // ── Error & empty states ──────────────────────────────────────────────────

  Widget _buildNetworkError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Container(
          padding:
              const EdgeInsets.symmetric(vertical: 36, horizontal: 28),
          decoration: BoxDecoration(
            color: AppColors.card(_ctx),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  blurRadius: 24,
                  offset: const Offset(0, 10))
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: const Color(0xFFE53E3E).withValues(alpha: 0.08),
                    shape: BoxShape.circle),
                child: const Icon(Icons.wifi_off_rounded,
                    color: Color(0xFFE53E3E), size: 44),
              ),
              const SizedBox(height: 20),
              Text('Connexion perdue',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary(_ctx))),
              const SizedBox(height: 8),
              Text(_networkErrorMsg,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                      height: 1.5)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _reload,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Réessayer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kGreen,
                  foregroundColor: Colors.white,
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

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Container(
          padding:
              const EdgeInsets.symmetric(vertical: 36, horizontal: 28),
          decoration: BoxDecoration(
            color: AppColors.card(_ctx),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                  color: _kGreen.withValues(alpha: 0.10),
                  blurRadius: 28,
                  offset: const Offset(0, 12))
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    _kGreen.withValues(alpha: 0.10),
                    _kYellow.withValues(alpha: 0.08),
                  ]),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.flag_outlined,
                    color: _kGreen, size: 44),
              ),
              const SizedBox(height: 20),
              Text('Aucune étape disponible',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary(_ctx))),
              const SizedBox(height: 8),
              Text(
                  'Il n\'y a pas encore d\'étape disponible pour ce parcours.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                      height: 1.5)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _reload,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Réessayer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kGreen,
                  foregroundColor: Colors.white,
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

  // ── Shimmer ───────────────────────────────────────────────────────────────

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 100, 16, 20),
        itemCount: 6,
        itemBuilder: (_, i) {
          if (i == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
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
            padding: const EdgeInsets.only(bottom: 14),
            child: Container(
              height: 72,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18)),
            ),
          );
        },
      ),
    );
  }
}

// ── Modèle de page ────────────────────────────────────────────────────────────

class _PageData {
  final LearningPathModel? path;
  final List<StepModel> steps;
  _PageData({required this.path, required this.steps});
}

// ── Triangle painter (guide étapes) ──────────────────────────────────────────

class _StepsTrianglePainter extends CustomPainter {
  final Color color;
  const _StepsTrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_StepsTrianglePainter old) => old.color != color;
}
