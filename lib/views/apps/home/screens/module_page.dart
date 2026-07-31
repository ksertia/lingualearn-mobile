import 'dart:async';
import 'package:dio/dio.dart';
import 'package:tibi/helpers/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tibi/controller/apps/moduls/home_controller.dart';
import 'package:tibi/helpers/services/module_service.dart';
import 'package:tibi/models/modules/modul_model.dart';

// ── Palette ────────────────────────────────────────────────────────────────
const Color _kGreen  = Color(0xFF188329);
const Color _kLocked = Color(0xFFB0BEC5);
const Color _kOrange = Color(0xFFF27F22);


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

  // ─── Guide ─────────────────────────────────────────────────────────────────
  bool _showGuide = false;
  late final AnimationController _bounceCtrl;
  late final Animation<double> _bounceAnim;
  Worker? _guideWorker;

  static const List<String> _animals = [
    'assets/lottie/poulet.json',
    'assets/lottie/elephant.json',
    'assets/lottie/cat.json',
    'assets/lottie/Chicken.json',
    'assets/lottie/dino.json',
    'assets/lottie/Dog.json',
    'assets/lottie/Lion.json',
  ];

  String _animal(int i) => _animals[i % _animals.length];

  Color _accent(String s) {
    if (s == 'completed') return _kGreen;
    if (s == 'unlocked' || s == 'started') return _kOrange;
    return _kLocked;
  }

  @override
  void initState() {
    super.initState();
    controller = Get.put(HomeController());
    WidgetsBinding.instance.addObserver(this);
    ever(controller.moduleDisplayStatus, (_) => _autoUnlockNext());

    // Guide animation
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
    if (prefs.getBool('modules_guide_shown') ?? false) return;

    // Attend que les modules soient chargés pour afficher le guide
    _guideWorker = ever(controller.isLoading, (bool loading) async {
      if (loading) return;
      if (controller.filteredModules.isEmpty) return;
      _guideWorker?.dispose();
      _guideWorker = null;
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      setState(() => _showGuide = true);
      _bounceCtrl.repeat(reverse: true);
    });
  }

  Future<void> _dismissModuleGuide() async {
    if (!mounted) return;
    setState(() => _showGuide = false);
    _bounceCtrl.stop();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('modules_guide_shown', true);
  }

  Future<void> _silentRefresh() async {
    try {
      await controller.onRefresh();
    } catch (_) {}
  }

  void _autoUnlockNext() {
    final modules = controller.filteredModules;
    final statuses = controller.moduleDisplayStatus;
    for (int i = 0; i < modules.length - 1; i++) {
      final currentStatus =
          (statuses[modules[i].id] ?? 'locked').toLowerCase();
      final nextId = modules[i + 1].id;
      final nextStatus = (statuses[nextId] ?? 'locked').toLowerCase();
      if (currentStatus == 'completed' && nextStatus == 'locked') {
        statuses[nextId] = 'unlocked';
      }
    }
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
      await controller.loadModules();
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
    return 'Impossible de charger les modules. Réessaie.';
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _bounceCtrl.dispose();
    _guideWorker?.dispose();
    super.dispose();
  }

  // ── Guide widget ───────────────────────────────────────────────────────────

  Widget _buildModuleGuide() {
    return Column(
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
                  'Clique sur le premier module pour découvrir ses parcours !',
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
                onTap: _dismissModuleGuide,
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

        // Doigt animé centré sur le card module
        // Ligne = SizedBox(52) + SizedBox(12) + Expanded(card)
        // Centre du card = 52 + 12 + (largeur_card / 2)
        LayoutBuilder(
          builder: (_, constraints) {
            const timelineW = 52.0;
            const gapW = 12.0;
            final cardW = constraints.maxWidth - timelineW - gapW;
            final fingerX = timelineW + gapW + cardW / 2 - 15; // 15 = moitié icône
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
                          painter: _ModuleTrianglePainter(color: _kOrange),
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
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Container(
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
          if (controller.filteredModules.isEmpty) {
            return _buildEmptyModules(context);
          }

          final modules = controller.filteredModules;

          return ListView.builder(
              padding: EdgeInsets.fromLTRB(
                20,
                MediaQuery.of(context).padding.top + kToolbarHeight + 16,
                20,
                48,
              ),
              itemCount: modules.length,
              itemBuilder: (_, index) {
                final moduleIndex = index;
                final module = modules[moduleIndex];
                final bool isLast = moduleIndex == modules.length - 1;
                final String st =
                    (controller.moduleDisplayStatus[module.id] ?? 'locked')
                        .toLowerCase();
                final bool isUnlocked =
                    st == 'unlocked' || st == 'started' || st == 'completed';
                final accent = _accent(st);

                final moduleRow = IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 52,
                        child: Column(
                          children: [
                            _buildTimelineNode(st, accent),
                            if (!isLast)
                              Expanded(
                                child: Center(
                                  child: Container(
                                    width: 4,
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 4),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          accent.withValues(alpha: 0.65),
                                          accent.withValues(alpha: 0.05),
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 22),
                          child: _buildModuleCard(
                            context, module, st, isUnlocked, accent,
                            moduleIndex,
                            onBeforeTap: moduleIndex == 0 && _showGuide
                                ? _dismissModuleGuide
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                );

                if (moduleIndex == 0 && _showGuide) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildModuleGuide(),
                      const SizedBox(height: 6),
                      moduleRow,
                    ],
                  );
                }
                return moduleRow;
              },
          );
        }),
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
                  'Mes Modules',
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

  // ── Timeline node ─────────────────────────────────────────────────────────

  Widget _buildTimelineNode(String status, Color accent) {
    final IconData icon;
    if (status == 'completed') {
      icon = Icons.check_rounded;
    } else if (status == 'unlocked' || status == 'started') {
      icon = Icons.play_arrow_rounded;
    } else {
      icon = Icons.lock_rounded;
    }

    final bool isActive = status != 'locked';
    final List<Color> gradientColors = status == 'completed'
        ? [_kGreen, const Color(0xFF22A63B)]
        : (status == 'unlocked' || status == 'started')
            ? [_kOrange, const Color(0xFFFFB347)]
            : [const Color(0xFFECEFF1), const Color(0xFFCFD8DC)];

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: accent.withValues(alpha: 0.40),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: accent.withValues(alpha: 0.15),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: Icon(
        icon,
        color: isActive ? Colors.white : _kLocked,
        size: 24,
      ),
    );
  }

  // ── Module card ───────────────────────────────────────────────────────────

  Widget _buildModuleCard(
    BuildContext context,
    ModuleModel module,
    String st,
    bool isUnlocked,
    Color accent,
    int index, {
    VoidCallback? onBeforeTap,
  }) {
    final isCompleted = st == 'completed';
    final isOrange = accent == _kOrange;

    final List<Color> stripeColors = isCompleted
        ? [_kGreen, const Color(0xFF22A63B)]
        : isUnlocked
            ? [_kOrange, const Color(0xFFFFB347)]
            : [const Color(0xFFCFD8DC), const Color(0xFFB0BEC5)];

    return GestureDetector(
        onTap: !isUnlocked
            ? () => Get.snackbar(
                  '🔒 Module verrouillé',
                  'Termine le module précédent pour débloquer celui-ci.',
                  backgroundColor: const Color(0xFF1A1A1A),
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                  margin: const EdgeInsets.all(16),
                  borderRadius: 16,
                  icon: const Icon(Icons.lock_rounded, color: Colors.white70),
                )
            : () async {
                onBeforeTap?.call();
                if (!controller.isSubscriptionActive.value) {
                  _showSubscriptionRequired(context);
                  return;
                }
                final userId =
                    controller.session.userId.value.isNotEmpty
                        ? controller.session.userId.value
                        : (controller.session.user?.id ?? '');
                final raw =
                    (module.progress?.status ?? module.status ?? '')
                        .toLowerCase();
                if (userId.isNotEmpty && raw == 'unlocked') {
                  try {
                    await ModuleService.startModule(
                        userId: userId, moduleId: module.id);
                  } on DioException catch (e) {
                    final status = e.response?.statusCode ?? 0;
                    if (status == 402 || status == 403) {
                      controller.isSubscriptionActive.value = false;
                      if (context.mounted) _showSubscriptionRequired(context);
                      return;
                    }
                    if (status == 0 || e.response == null) {
                      if (context.mounted) {
                        Get.snackbar(
                          'Connexion perdue',
                          'Vérifie ton internet et réessaie.',
                          backgroundColor: const Color(0xFFE53E3E),
                          colorText: Colors.white,
                          snackPosition: SnackPosition.BOTTOM,
                          margin: const EdgeInsets.all(16),
                          borderRadius: 16,
                        );
                      }
                      return;
                    }
                  }
                }
                await Get.toNamed('/parcoursselectionpage', arguments: {
                  'moduleId': module.id,
                  'userId': userId,
                  'moduleLottie': _animal(index),
                });
                // Le module a pu être marqué "completed" côté serveur
                // pendant qu'on était sur les parcours/étapes : on
                // rafraîchit tout de suite pour débloquer le module
                // suivant sans attendre le timer ou un aller-retour.
                await controller.onRefresh();
              },
        child: Container(
          constraints: const BoxConstraints(minHeight: 118),
          decoration: BoxDecoration(
            color: AppColors.card(context),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: accent.withValues(alpha: isUnlocked ? 0.22 : 0.10),
              width: 1.5,
            ),
            boxShadow: isUnlocked
                ? [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.18),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(23),
            child: Stack(
              children: [
                // Gradient left stripe
                Positioned(
                  left: 0, top: 0, bottom: 0,
                  child: Container(
                    width: 6,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: stripeColors,
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                // Text content
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 10, 16, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            _buildStatusBadge(
                                st, isUnlocked, accent, isOrange),
                            if (isCompleted) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 3),
                                decoration: BoxDecoration(
                                  color: _kOrange.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(7),
                                  border: Border.all(
                                      color: _kOrange.withValues(alpha: 0.3),
                                      width: 1),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(Icons.star_rounded,
                                        color: _kOrange, size: 10),
                                    SizedBox(width: 3),
                                    Text(
                                      'BRAVO',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF8B6B00),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 7),
                        Text(
                          module.title.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14.5,
                            letterSpacing: 0.3,
                            color: isUnlocked
                                ? AppColors.textPrimary(context)
                                : Colors.grey.shade400,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          isUnlocked
                              ? module.description
                              : 'Continue pour découvrir ce module…',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isUnlocked
                                ? AppColors.textSecondary(context)
                                : Colors.grey.shade400,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Play button for active
                if (st == 'unlocked' || st == 'started')
                  Positioned(
                    right: 8, bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _kOrange.withValues(alpha: 0.30),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.play_circle_fill,
                          color: _kOrange, size: 30),
                    ),
                  ),
                // Completed checkmark
                if (isCompleted)
                  Positioned(
                    right: 8, top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: _kGreen,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _kGreen.withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.check_rounded,
                          color: Colors.white, size: 14),
                    ),
                  ),
              ],
            ),
          ),
        ),
    );
  }

  Widget _buildStatusBadge(
      String st, bool isUnlocked, Color accent, bool isOrange) {
    final String label;
    final IconData icon;
    if (st == 'completed') {
      label = 'TERMINÉ';
      icon = Icons.check_rounded;
    } else if (isUnlocked) {
      label = 'EN COURS';
      icon = Icons.bolt_rounded;
    } else {
      label = 'VERROUILLÉ';
      icon = Icons.lock_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(7),
        border:
            Border.all(color: accent.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              color: isOrange ? const Color(0xFF8B6B00) : accent,
              size: 10),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: isOrange ? const Color(0xFF8B6B00) : accent,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  // ── Empty state ────────────────────────────────────────────────────────────

  Widget _buildEmptyModules(BuildContext context) {
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
                'Aucun module disponible',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Il n\'y a pas encore de module disponible pour cette langue et ce niveau.',
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
                'Ton abonnement est expiré ou inactif.\nSouscris pour accéder à tous les modules.',
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

  // ── Subscription bottom sheet ──────────────────────────────────────────────

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
              width: 44,
              height: 4,
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
                  color: Colors.white, size: 38),
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
              'Accédez à tous les modules en illimité.\nSouscrivez dès maintenant et commencez à apprendre.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary(context),
                fontSize: 14,
                height: 1.6,
              ),
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
                child: const Text(
                  'Voir les forfaits',
                  style: TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Plus tard',
                style:
                    TextStyle(color: Colors.grey.shade400, fontSize: 14),
              ),
            ),
          ],
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
          // Header card shimmer
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
          // Module row shimmer
          return Padding(
            padding: const EdgeInsets.only(bottom: 22),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 118,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Triangle painter (guide) ──────────────────────────────────────────────────

class _ModuleTrianglePainter extends CustomPainter {
  final Color color;
  const _ModuleTrianglePainter({required this.color});

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
  bool shouldRepaint(_ModuleTrianglePainter old) => old.color != color;
}
