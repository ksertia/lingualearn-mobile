import 'dart:async';
import 'package:dio/dio.dart';
import 'package:tibi/helpers/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tibi/controller/apps/moduls/home_controller.dart';
import 'package:tibi/views/apps/home/screens/sub_themes_page.dart';

// ── Palette ────────────────────────────────────────────────────────────────
const Color _kGreen  = Color(0xFF188329);
const Color _kOrange = Color(0xFFF27F22);
const int _kModulesPerPage = 2;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  late HomeController controller;

  bool _hasNetworkError = false;
  String _networkErrorMsg = '';

  Color _accent(String s) => s == 'completed' ? _kGreen : _kOrange;

  @override
  void initState() {
    super.initState();
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

  String get _userId => controller.session.userId.value.isNotEmpty
      ? controller.session.userId.value
      : (controller.session.user?.id ?? '');

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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

          final modules = controller.moduleTree;
          final pages = <List<ModuleNode>>[];
          for (int i = 0; i < modules.length; i += _kModulesPerPage) {
            pages.add(modules.sublist(
                i, (i + _kModulesPerPage).clamp(0, modules.length)));
          }

          return Column(
            children: [
              SizedBox(
                  height:
                      MediaQuery.of(context).padding.top + kToolbarHeight + 16),
              if (pages.length > 1) _buildPageIndicator(context, pages.length),
              const SizedBox(height: 4),
              Expanded(
                child: PageView.builder(
                  controller: controller.pageController,
                  onPageChanged: controller.onPageChanged,
                  itemCount: pages.length,
                  itemBuilder: (_, i) => _buildModulesPage(
                      context, pages[i], i * _kModulesPerPage),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // ── Pagination ─────────────────────────────────────────────────────────────

  Widget _buildModulesPage(
      BuildContext context, List<ModuleNode> pageModules, int startIndex) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 48),
      itemCount: pageModules.length,
      itemBuilder: (_, index) {
        final moduleNode = pageModules[index];
        final st = (controller.moduleDisplayStatus[moduleNode.module.id] ??
                'unlocked')
            .toLowerCase();
        final accent = _accent(st);

        return Padding(
          padding: const EdgeInsets.only(bottom: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildModuleHeader(
                  context, moduleNode, accent, startIndex + index),
              _buildThemesSection(context, moduleNode),
            ],
          ),
        );
      },
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

  // ── Module header ─────────────────────────────────────────────────────────

  Widget _buildModuleHeader(BuildContext context, ModuleNode moduleNode,
      Color accent, int moduleIndex) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Text(
                  'MODULE ${moduleIndex + 1} — ${moduleNode.module.title.toUpperCase()}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    letterSpacing: 0.4,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Thèmes ────────────────────────────────────────────────────────────────

  Widget _buildThemesSection(BuildContext context, ModuleNode moduleNode) {
    return Obx(() {
      if (moduleNode.themesLoading.value) {
        return _buildInlineShimmerRows(context, count: 2);
      }
      if (moduleNode.themesError.value) {
        return _buildInlineError(
          context,
          message: 'Impossible de charger les thèmes.',
          onRetry: () => controller.retryThemesForModule(moduleNode),
        );
      }
      if (moduleNode.themeNodes.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < moduleNode.themeNodes.length; i++)
              Padding(
                padding: EdgeInsets.only(
                    bottom: i == moduleNode.themeNodes.length - 1 ? 0 : 12),
                child: _buildThemeCard(context, moduleNode.themeNodes[i], i),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildThemeCard(BuildContext context, ThemeNode themeNode, int themeIdx) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Get.to(
          () => SubThemesPage(
            controller: controller,
            themeNode: themeNode,
            themeIdx: themeIdx,
            userId: _userId,
          ),
          transition: Transition.rightToLeft,
        ),
        child: Container(
          constraints: const BoxConstraints(minHeight: 88),
          decoration: BoxDecoration(
            color: AppColors.card(context),
            borderRadius: BorderRadius.circular(18),
            border:
                Border.all(color: _kOrange.withValues(alpha: 0.28), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: _kOrange.withValues(alpha: 0.12),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(17),
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(width: 5, color: _kOrange),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 12, 20),
                  child: Row(
                    children: [
                      Icon(Icons.label_outline, size: 18, color: _kOrange),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              themeNode.theme.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15.5,
                                color: AppColors.textPrimary(context),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Obx(() {
                              if (themeNode.subThemesLoading.value) {
                                return const SizedBox.shrink();
                              }
                              final n = themeNode.subThemes.length;
                              return Text(
                                n <= 1 ? '$n sous-thème' : '$n sous-thèmes',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary(context),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right_rounded,
                          color: _kOrange, size: 22),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── États locaux (thème/sous-thème) ────────────────────────────────────────

  Widget _buildInlineShimmerRows(BuildContext context,
      {required int count, double cardHeight = 40}) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 4),
      child: Shimmer.fromColors(
        baseColor: AppColors.shimmerBase(context),
        highlightColor: AppColors.shimmerHighlight(context),
        child: Column(
          children: List.generate(
            count,
            (_) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                height: cardHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInlineError(BuildContext context,
      {required String message, required VoidCallback onRetry}) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12.5,
                color: AppColors.textSecondary(context),
              ),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: const Text('Réessayer',
                style: TextStyle(color: _kOrange, fontWeight: FontWeight.w700)),
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
