import 'dart:async';
import 'package:dio/dio.dart';
import 'package:tibi/controller/apps/parcoure/parcoure_controller.dart';
import 'package:tibi/helpers/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:lottie/lottie.dart';
import 'package:tibi/helpers/services/module_service.dart';
import 'package:tibi/helpers/services/parcoure/parcoure_service.dart';
import 'package:tibi/models/modules/modul_model.dart';
import 'package:tibi/models/parcoure/parcour_model.dart';
import '../../../../widgets/stepsscreens/custom_app_bar.dart';

// ── Palette ────────────────────────────────────────────────────────────────
const Color _kGreen      = Color(0xFF188329);
const Color _pLocked    = Color(0xFFB0BEC5);
const Color _kOrange = Color(0xFFF27F22);



const List<double> _kNodeWave = [0.20, 0.50, 0.78, 0.50];
const double _kNodeSize  = 72.0;
const double _kNodeSlot  = 122.0;
const double _kConnH     = 38.0;

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
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 28),
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
                color: Color(0xFF1A1A1A), size: 38),
          ),
          const SizedBox(height: 22),
          Text(
            'Abonnement requis',
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Accédez à tous les parcours en illimité.\nSouscrivez dès maintenant et commencez à apprendre.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary(context), fontSize: 14, height: 1.6),
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
                backgroundColor: _kOrange,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text('Voir les forfaits',
                  style: TextStyle(
                      color: Color(0xFF1A1A1A),
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

class ParcoursSelectionPage extends StatefulWidget {
  const ParcoursSelectionPage({super.key});

  @override
  State<ParcoursSelectionPage> createState() => _ParcoursSelectionPageState();
}

class _ParcoursSelectionPageState extends State<ParcoursSelectionPage>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late ParcoursSelectionController controller;
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

  static const List<String> _lotties = [
    'assets/lottie/poulet.json',
    'assets/lottie/elephant.json',
    'assets/lottie/cat.json',
    'assets/lottie/Chicken.json',
    'assets/lottie/dino.json',
    'assets/lottie/Dog.json',
    'assets/lottie/Lion.json',
  ];

  @override
  void initState() {
    super.initState();
    controller = Get.put(ParcoursSelectionController());
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
    if (prefs.getBool('parcours_guide_shown') ?? false) return;

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

  Future<void> _dismissParcoursGuide() async {
    if (!mounted) return;
    setState(() => _showGuide = false);
    _bounceCtrl.stop();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('parcours_guide_shown', true);
  }

  void _startAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(_refreshInterval, (_) {
      if (mounted && !controller.isLoading.value) _silentRefresh();
    });
  }

  Future<void> _silentRefresh() async {
    try {
      await controller.fetchPaths();
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
      await controller.fetchPaths();
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
    return 'Impossible de charger les parcours. Réessaie.';
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

  Widget _buildParcoursGuide() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Bulle tooltip
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _kOrange,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _kOrange.withValues(alpha: 0.30),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lightbulb_rounded, color: Color(0xFF1A1A1A), size: 20),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Clique sur le premier parcours pour voir ses étapes !',
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
                  onTap: _dismissParcoursGuide,
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

          LayoutBuilder(
            builder: (_, constraints) {
              final fingerX = constraints.maxWidth * 0.54 - 15;
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
                            painter: _ParcoursTrianglePainter(color: _kOrange),
                          ),
                          const SizedBox(height: 2),
                          const Icon(Icons.touch_app_rounded,
                              color: _kOrange, size: 30),
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
    final String backgroundImage =
        (args is Map && args['backgroundImage'] != null)
            ? args['backgroundImage'].toString()
            : 'assets/images/app/plan3.png';

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: const CustomAppBar(title: 'Mes Parcours'),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(backgroundImage),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
                Colors.black.withValues(alpha: 0.18), BlendMode.darken),
          ),
        ),
        child: Obx(() {
          if (controller.isLoading.value) return _buildShimmer();
          if (_hasNetworkError) return _buildNetworkError();
          if (controller.items.isEmpty) return _buildEmpty();

          final List<_PageData> pages = [];
          ModuleModel? currentModule;
          List<LearningPathModel> currentPaths = [];
          int moduleIdx = 0;

          for (final item in controller.items) {
            if (item is ModuleModel) {
              if (currentModule != null || currentPaths.isNotEmpty) {
                pages.add(_PageData(
                  module: currentModule,
                  paths: List.from(currentPaths),
                  lottie: _lotties[
                      (moduleIdx - 1).clamp(0, _lotties.length - 1)],
                ));
              }
              currentModule = item;
              currentPaths = [];
              moduleIdx++;
            } else if (item is LearningPathModel) {
              currentPaths.add(item);
            }
          }
          if (currentModule != null || currentPaths.isNotEmpty) {
            pages.add(_PageData(
              module: currentModule,
              paths: List.from(currentPaths),
              lottie: _lotties[
                  moduleIdx > 0 ? (moduleIdx - 1) % _lotties.length : 0],
            ));
          }

          if (pages.isEmpty) return const SizedBox.shrink();

          return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height),
                child: Column(
                  children: [
                    SizedBox(
                        height: MediaQuery.of(context).padding.top +
                            kToolbarHeight +
                            16),
                    _buildPagesSection(context, pages),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
          );
        }),
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
                        color:
                            Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                            color:
                                _kOrange.withValues(alpha: 0.15),
                            width: 1),
                        boxShadow: [
                          BoxShadow(
                            color:
                                _kOrange.withValues(alpha: 0.10),
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
                            'Module ${controller.currentPage.value + 1} / ${pages.length}',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: AppColors.textPrimary(_ctx),
                            ),
                          ),
                          const SizedBox(width: 10),
                          _buildNavBtn(
                            Icons.arrow_forward_ios,
                            controller.currentPage.value <
                                pages.length - 1,
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
                          duration:
                              const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 3),
                          width: isActive ? 24.0 : 8.0,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isActive ? _kOrange : _kOrange.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                  ],
                )),
          ),
        const SizedBox(height: 10),
        SizedBox(
          height: MediaQuery.of(context).size.height -
              MediaQuery.of(context).padding.top -
              kToolbarHeight -
              (pages.length > 1 ? 112 : 16),
          child: PageView.builder(
            controller: controller.pageController,
            onPageChanged: controller.onPageChanged,
            itemCount: pages.length,
            itemBuilder: (_, i) => _buildPathsPage(pages[i], i),
          ),
        ),
      ],
    );
  }

  Widget _buildNavBtn(
      IconData icon, bool enabled, VoidCallback onTap) {
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
            size: 15,
            color: enabled ? _kOrange : Colors.grey.shade400),
      ),
    );
  }

  // ── Page d'un module  ───────────────────────────────

  Widget _buildPathsPage(_PageData page, int pageIndex) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (page.module != null)
            _buildModuleHeader(page.module!, page.lottie, pageIndex),
          if (page.module == null)
          const SizedBox(height: 8),
          Expanded(
            child: Builder(
              builder: (context) => ListView(
                padding: const EdgeInsets.only(top: 18, bottom: 24),
                children: _buildDuoNodes(page, pageIndex, context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────

  List<Widget> _buildDuoNodes(
      _PageData page, int pageIndex, BuildContext context) {
    final paths = page.paths;
    final List<Widget> widgets = [];

    for (int i = 0; i < paths.length; i++) {
      final path = paths[i];
      final pathStatus =
          (path.progress != null && path.progress!['status'] != null)
              ? path.progress!['status'].toString().toLowerCase()
              : (path.status ?? 'locked').toLowerCase();
      final isCompleted = pathStatus == 'completed';
      final isActive = pathStatus == 'unlocked' ||
          pathStatus == 'started' ||
          pathStatus == 'in_progress' ||
          isCompleted;
      final accent =
          isCompleted ? _kGreen : (isActive ? _kOrange : _pLocked);

      if (i == 0 && pageIndex == 0 && _showGuide) {
        widgets.add(_buildParcoursGuide());
      }

      if (i > 0) {
        final prevPath = paths[i - 1];
        final prevStatus =
            (prevPath.progress?['status'] ?? prevPath.status ?? 'locked')
                .toString()
                .toLowerCase();
        final prevCompleted = prevStatus == 'completed';
        final prevActive = prevCompleted ||
            prevStatus == 'unlocked' ||
            prevStatus == 'started' ||
            prevStatus == 'in_progress';
        widgets.add(_buildNodeConnector(
          _kNodeWave[(i - 1) % _kNodeWave.length],
          _kNodeWave[i % _kNodeWave.length],
          prevCompleted,
          prevActive || isActive,
        ));
      }

      widgets.add(_buildDuoNode(
        path: path,
        index: i,
        pageIndex: pageIndex,
        isCompleted: isCompleted,
        isActive: isActive,
        accent: accent,
        page: page,
        context: context,
      ));
    }

    return widgets;
  }

  Widget _buildNodeConnector(
      double fromFrac, double toFrac, bool completed, bool active) {
    final color = completed
        ? _kGreen.withValues(alpha: 0.45)
        : active
            ? _kOrange.withValues(alpha: 0.40)
            : _pLocked.withValues(alpha: 0.22);

    return LayoutBuilder(builder: (_, c) {
      final w = c.maxWidth;
      return SizedBox(
        height: _kConnH,
        child: CustomPaint(
          size: Size(w, _kConnH),
          painter: _DuoConnectorPainter(
            from: Offset(w * fromFrac, 0),
            to: Offset(w * toFrac, _kConnH),
            color: color,
          ),
        ),
      );
    });
  }

  Widget _buildDuoNode({
    required LearningPathModel path,
    required int index,
    required int pageIndex,
    required bool isCompleted,
    required bool isActive,
    required Color accent,
    required _PageData page,
    required BuildContext context,
  }) {
    const double nodeSize = _kNodeSize;
    const double labelW = 132.0;
    final xFrac = _kNodeWave[index % _kNodeWave.length];

    Future<void> handleTap() async {
      if (index == 0 && pageIndex == 0 && _showGuide) {
        _dismissParcoursGuide();
      }
      if (!controller.isSubscriptionActive.value) {
        _showSubscriptionRequired(context);
        return;
      }
      final a = Get.arguments;
      final userId =
          (a is Map && a['userId'] != null) ? a['userId'].toString() : '';
      final ps =
          (path.progress?['status'] ?? path.status ?? 'locked')
              .toString()
              .toLowerCase();
      if (userId.isNotEmpty && ps == 'unlocked') {
        await LearningPathService.startPath(userId: userId, pathId: path.id);
      }
      final res = await Get.toNamed('/stepsscreens', arguments: {
        'moduleId': path.moduleId,
        'pathId': path.id,
        'userId': userId,
        'moduleLottie': page.lottie,
      });
      if (res == true || res == 'completed' || res == 'finished') {
        final allPaths = controller.items
            .whereType<LearningPathModel>()
            .where((p) => p.moduleId == path.moduleId)
            .toList();
        final allDone = allPaths.isNotEmpty &&
            allPaths.every((p) {
              final st =
                  (p.progress != null && p.progress!['status'] != null)
                      ? p.progress!['status'].toString().toLowerCase()
                      : (p.status ?? 'locked').toLowerCase();
              return st == 'completed';
            });
        if (userId.isNotEmpty && path.moduleId.isNotEmpty && allDone) {
          await ModuleService.completeModule(
              userId: userId, moduleId: path.moduleId);
        }
        Get.back(result: true);
      }
    }

    void onLockedTap() => Get.snackbar(
          '🔒 Parcours verrouillé',
          'Terminez le parcours précédent pour débloquer celui-ci.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF1A1A1A),
          colorText: Colors.white,
          margin: const EdgeInsets.all(15),
          borderRadius: 16,
          icon: const Icon(Icons.lock_rounded, color: Colors.white70),
        );

    return SizedBox(
      height: _kNodeSlot,
      child: LayoutBuilder(builder: (_, c) {
        final w = c.maxWidth;
        final centerX = w * xFrac;
        final circleLeft =
            (centerX - nodeSize / 2).clamp(0.0, w - nodeSize);
        final labelLeft = (centerX - labelW / 2).clamp(0.0, w - labelW);

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Outer glow for active node
            if (isActive && !isCompleted)
              Positioned(
                left: circleLeft - 10,
                top: -10,
                child: Container(
                  width: nodeSize + 20,
                  height: nodeSize + 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent.withValues(alpha: 0.16),
                  ),
                ),
              ),

            // Number badge (floats above circle)
            Positioned(
              left: circleLeft - 2,
              top: -12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.30),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),

            // Circle node
            Positioned(
              left: circleLeft,
              top: 0,
              child: GestureDetector(
                onTap: isActive ? () { handleTap(); } : onLockedTap,
                child: Container(
                  width: nodeSize,
                  height: nodeSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: isCompleted
                          ? [_kGreen, const Color(0xFF22A63B)]
                          : isActive
                              ? [_kOrange, const Color(0xFFFFB347)]
                              : [
                                  const Color(0xFFCFD8DC),
                                  const Color(0xFFB0BEC5),
                                ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: accent.withValues(alpha: 0.44),
                              blurRadius: 24,
                              offset: const Offset(0, 7),
                            ),
                          ]
                        : [],
                    border: Border.all(color: Colors.white, width: 3.5),
                  ),
                  child: Center(
                    child: Icon(
                      isCompleted
                          ? Icons.star_rounded
                          : (isActive
                              ? Icons.play_arrow_rounded
                              : Icons.lock_rounded),
                      color: Colors.white,
                      size: isCompleted ? 34 : 30,
                    ),
                  ),
                ),
              ),
            ),

            // Label badge below circle
            Positioned(
              left: labelLeft,
              top: nodeSize + 6,
              width: labelW,
              child: GestureDetector(
                onTap: isActive ? () { handleTap(); } : onLockedTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.96),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: accent.withValues(
                          alpha: isActive ? 0.35 : 0.12),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.10),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        path.title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isActive
                              ? const Color(0xFF1A1A1A)
                              : Colors.grey.shade500,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isCompleted
                                ? Icons.check_circle_rounded
                                : isActive
                                    ? Icons.play_circle_filled
                                    : Icons.lock_rounded,
                            color: accent,
                            size: 10,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            isCompleted
                                ? 'Terminé'
                                : (isActive ? 'En cours' : 'Verrouillé'),
                            style: TextStyle(
                              color: accent,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildModuleHeader(
      ModuleModel module, String lottie, int index) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _kOrange.withValues(alpha: 0.10),
            _kOrange.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border:
            Border.all(color: _kOrange.withValues(alpha: 0.20), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _kOrange.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: _kOrange,
                borderRadius: BorderRadius.circular(17),
                boxShadow: [
                  BoxShadow(
                    color: _kOrange.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Lottie.asset(lottie, fit: BoxFit.contain),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _kOrange.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Module ${index + 1}',
                      style: const TextStyle(
                        color: _kOrange,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    module.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A1A),
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _kOrange.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.menu_book_rounded,
                  color: _kOrange, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  // ── Error & empty states ──────────────────────────────────────────────────

  Widget _buildNetworkError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 28),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.97),
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
              const Text(
                'Connexion perdue',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A1A)),
              ),
              const SizedBox(height: 8),
              Text(
                _networkErrorMsg,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
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

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Container(
          padding:
              const EdgeInsets.symmetric(vertical: 36, horizontal: 28),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.97),
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
                    _kOrange.withValues(alpha: 0.10),
                    _kOrange.withValues(alpha: 0.08),
                  ]),
                  shape: BoxShape.circle,
                ),
                child:
                    const Icon(Icons.map_outlined, color: _kOrange, size: 44),
              ),
              const SizedBox(height: 20),
              const Text(
                'Aucun parcours disponible',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A1A)),
              ),
              const SizedBox(height: 8),
              Text(
                'Il n\'y a pas encore de parcours disponible.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
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
          if (i == 1) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                height: 88,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
            );
          }
          // Circle node placeholder
          final xFrac = _kNodeWave[(i - 2) % _kNodeWave.length];
          return LayoutBuilder(builder: (_, c) {
            final w = c.maxWidth;
            final cx = w * xFrac;
            final cl = (cx - _kNodeSize / 2).clamp(0.0, w - _kNodeSize);
            final ll = (cx - 66.0).clamp(0.0, w - 132.0);
            return SizedBox(
              height: _kNodeSlot + (i > 2 ? _kConnH : 0),
              child: Stack(
                children: [
                  if (i > 2)
                    Positioned(
                      left: cx - 1.5,
                      top: 0,
                      child: Container(
                        width: 3,
                        height: _kConnH,
                        color: Colors.white,
                      ),
                    ),
                  Positioned(
                    left: cl,
                    top: i > 2 ? _kConnH : 0,
                    child: Container(
                      width: _kNodeSize,
                      height: _kNodeSize,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    left: ll,
                    top: (i > 2 ? _kConnH : 0) + _kNodeSize + 8,
                    child: Container(
                      width: 132,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],
              ),
            );
          });
        },
      ),
    );
  }
}

// ── Dashed connector between Duolingo nodes ───────────────────────────────────

class _DuoConnectorPainter extends CustomPainter {
  final Offset from;
  final Offset to;
  final Color color;
  const _DuoConnectorPainter(
      {required this.from, required this.to, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    const dashLen = 6.0;
    const gapLen  = 5.0;

    final dx = to.dx - from.dx;
    final dy = to.dy - from.dy;
    final dist = Offset(dx, dy).distance;
    final ux = dx / dist;
    final uy = dy / dist;
    final steps = (dist / (dashLen + gapLen)).floor();

    for (int i = 0; i < steps; i++) {
      final s = i * (dashLen + gapLen);
      final e = s + dashLen;
      canvas.drawLine(
        Offset(from.dx + ux * s, from.dy + uy * s),
        Offset(from.dx + ux * e, from.dy + uy * e),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DuoConnectorPainter o) =>
      o.from != from || o.to != to || o.color != color;
}

// ── Modèle de page ────────────────────────────────────────────────────────────

class _PageData {
  final ModuleModel? module;
  final List<LearningPathModel> paths;
  final String lottie;
  _PageData(
      {required this.module, required this.paths, required this.lottie});
}

// ── Triangle painter (guide parcours) ────────────────────────────────────────

class _ParcoursTrianglePainter extends CustomPainter {
  final Color color;
  const _ParcoursTrianglePainter({required this.color});

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
  bool shouldRepaint(_ParcoursTrianglePainter old) => old.color != color;
}
