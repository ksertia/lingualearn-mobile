import 'package:dio/dio.dart';
import 'package:fasolingo/controller/apps/langue/langue_controller.dart';
import 'package:fasolingo/controller/apps/moduls/home_controller.dart';
import 'package:fasolingo/controller/apps/session_controller.dart';
import 'package:fasolingo/controller/apps/user_progress/user_progress_controller.dart';
import 'package:fasolingo/helpers/services/souscription/sousciption_service.dart';
import 'package:fasolingo/helpers/storage/local_storage.dart';
import 'package:fasolingo/helpers/theme/app_colors.dart';
import 'package:fasolingo/models/user_progress/user_progress_model.dart';
import 'package:fasolingo/views/apps/home/module_page.dart';
import 'package:fasolingo/views/apps/home/screens/parcours.dart';
import 'package:fasolingo/views/apps/home/screens/stepsscreens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../controller/apps/settings/settings_controller.dart';

// ── Palette ────────────────────────────────────────────────────────────────
const _kGreen = Color(0xFF188329);
const _kGreenDark = Color(0xFF0F5C1C);
const _kYellow = Color(0xFFF5BF1E);
const _kYellowDark = Color(0xFF8B6B00);
const _kOrange = Color(0xFFF27F22);

const _kLangColors = [
  [Color(0xFF188329), Color(0xFF0F5C1C)],
  [Color(0xFFF27F22), Color(0xFFBF5A0F)],
  [Color(0xFF0EA5E9), Color(0xFF0369A1)],
  [Color(0xFF7C3AED), Color(0xFF5B21B6)],
  [Color(0xFFF5BF1E), Color(0xFF8B6B00)],
];

List<Color> _langColors(String name) {
  final i = name.isNotEmpty ? name.codeUnitAt(0) % _kLangColors.length : 0;
  return [_kLangColors[i][0], _kLangColors[i][1]];
}

class AcceuilleSreen extends StatefulWidget {
  const AcceuilleSreen({super.key});

  @override
  State<AcceuilleSreen> createState() => _AcceuilleSreenState();
}

class _AcceuilleSreenState extends State<AcceuilleSreen>
    with SingleTickerProviderStateMixin {
  final SessionController session = Get.find<SessionController>();
  late final UserProgressController progressCtrl;
  final controller = Get.put(SettingsController());
  late BuildContext _ctx;

  final RxInt _currentLangPage = 0.obs;
  late PageController _pageController;

  bool _isSubscriptionActive = true;
  bool _hasProgressError = false;
  String _progressErrorMsg = '';

  // ─── Guide ────────────────────────────────────────────────────────────────
  bool _showGuide = false;
  late final AnimationController _bounceCtrl;
  late final Animation<double> _bounceAnim;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    progressCtrl = Get.isRegistered<UserProgressController>()
        ? Get.find<UserProgressController>()
        : Get.put(UserProgressController());
    _loadProgressSafe();
    _checkSubscription();

    // Guide bounce animation
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _bounceAnim = Tween<double>(begin: 0.0, end: 8.0).animate(
      CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeInOut),
    );
    _initGuide();
  }

  Future<void> _initGuide() async {
    final prefs = await SharedPreferences.getInstance();
    final shown = prefs.getBool('home_guide_shown') ?? false;
    if (!shown && mounted) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      setState(() => _showGuide = true);
      _bounceCtrl.repeat(reverse: true);
    }
  }

  Future<void> _dismissGuide() async {
    if (!mounted) return;
    setState(() => _showGuide = false);
    _bounceCtrl.stop();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('home_guide_shown', true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _bounceCtrl.dispose();
    super.dispose();
  }

  // ─── Error handling ───────────────────────────────────────────────────────

  Future<void> _loadProgressSafe() async {
    if (!mounted) return;
    setState(() {
      _hasProgressError = false;
      _progressErrorMsg = '';
    });
    try {
      await progressCtrl.loadProgress();
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _hasProgressError = true;
        _progressErrorMsg = _dioErrorMsg(e);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _hasProgressError = true;
        _progressErrorMsg = 'Une erreur inattendue s\'est produite.';
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
    return 'Impossible de charger tes données. Réessaie.';
  }

  Future<void> _checkSubscription() async {
    try {
      final planService = Get.put(PlanService());
      final data = await planService.checkCurrentSubscription();
      if (!mounted) return;
      if (data == null) {
        setState(() => _isSubscriptionActive = false);
        return;
      }
      final sub = data['subscription'];
      final active = data['isActive'] == true ||
          data['active'] == true ||
          data['status']?.toString().toLowerCase() == 'active' ||
          data['hasActiveSubscription'] == true ||
          (sub is Map &&
              (sub['status']?.toString().toLowerCase() == 'active' ||
                  sub['isActive'] == true));
      setState(() => _isSubscriptionActive = active);
    } on DioException catch (e) {
      if (!mounted) return;
      // Réseau absent → fail-open pour ne pas bloquer l'utilisateur
      setState(() => _isSubscriptionActive = e.response == null);
    } catch (_) {
      // Erreur inattendue → ne pas bloquer
    }
  }

  void _showSubscriptionRequired() {
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
                gradient: const LinearGradient(
                  colors: [_kOrange, _kYellow],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
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
              'Accédez à tous les parcours et étapes en illimité.\nSouscrivez dès maintenant et commencez à apprendre.',
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
                  backgroundColor: _kGreen,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text(
                  'Voir les forfaits',
                  style: TextStyle(
                    color: Colors.white,
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
                style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _ctx = context;
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.wait([_loadProgressSafe(), _checkSubscription()]);
          },
          color: _kGreen,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                _buildHeader(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 26),
                      _buildSectionTitleLangue("Mes langues", "Ajouter"),
                      const SizedBox(height: 14),
                      _buildLanguageSection(),
                      const SizedBox(height: 28),
                      _buildSectionTitle("Navigation rapide"),
                      const SizedBox(height: 14),
                      _buildNavigationRow(),
                      const SizedBox(height: 28),
                      _buildSectionTitle("En ce moment"),
                      const SizedBox(height: 14),
                      _buildCurrentPathCard(),
                      const SizedBox(height: 34),
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

  // ─── Header ───────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    final firstName =
        session.user?.firstName ?? LocalStorage.getUserName() ?? "Apprenant";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 24, 16, 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_kGreen, _kGreenDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _kYellow.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _kYellow.withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.local_fire_department_rounded,
                              color: _kYellow, size: 14),
                          SizedBox(width: 5),
                          Text(
                            "Bonne journée !",
                            style: TextStyle(
                              color: _kYellow,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Salut, $firstName 👋",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Prêt pour ta prochaine leçon ?",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () => Get.toNamed('/notifications'),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: const Icon(Icons.notifications_rounded,
                          color: Colors.white, size: 20),
                    ),
                  ),
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: Lottie.asset(
                      'assets/lottie/mascot.json',
                      fit: BoxFit.contain,
                      repeat: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatChip(Icons.auto_stories_rounded, "Apprends", _kYellow),
              const SizedBox(width: 10),
              _buildStatChip(
                  Icons.emoji_events_rounded, "Progresse", Colors.white),
              const SizedBox(width: 10),
              _buildStatChip(Icons.translate_rounded, "Maîtrise", _kOrange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Mes langues ──────────────────────────────────────────────────────────

  Widget _buildLanguageSection() {
    if (_hasProgressError) {
      return _buildErrorWidget(
        icon: Icons.wifi_off_rounded,
        message: _progressErrorMsg,
        onRetry: _loadProgressSafe,
      );
    }

    return Obx(() {
      if (progressCtrl.isLoading.value) return _buildLangSkeleton();

      final entries = progressCtrl.progressList;
      if (entries.isEmpty) return _buildNoLanguageCard();

      if (entries.length == 1) return _buildLangCard(entries.first);

      return Column(
        children: [
          SizedBox(
            height: 180,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (i) => _currentLangPage.value = i,
              itemCount: entries.length,
              itemBuilder: (_, i) => Padding(
                padding:
                    EdgeInsets.only(right: i < entries.length - 1 ? 10 : 0),
                child: _buildLangCard(entries[i]),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  entries.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: _currentLangPage.value == i ? 22 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _currentLangPage.value == i
                          ? _kGreen
                          : _kGreen.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              )),
        ],
      );
    });
  }

  Widget _buildErrorWidget({
    required IconData icon,
    required String message,
    required VoidCallback onRetry,
    Color color = const Color(0xFFE53E3E),
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.card(_ctx),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: color.withValues(alpha: 0.15), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 14, color: AppColors.textSecondary(_ctx), height: 1.5),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text("Réessayer"),
            style: ElevatedButton.styleFrom(
              backgroundColor: _kGreen,
              foregroundColor: Colors.white,
              elevation: 0,
              padding:
                  const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLangCard(UserProgressEntry entry) {
    final pct = (entry.language.progressPercentage / 100.0).clamp(0.0, 1.0);
    final pctInt = entry.language.progressPercentage;
    final code = entry.language.code.toUpperCase();
    final shortCode = code.length >= 2 ? code.substring(0, 2) : code;
    final colors = _langColors(entry.language.name);
    final c1 = colors[0];
    final c2 = colors[1];
    final currentModule = entry.module?.title;
    final currentStep = entry.step?.title;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [c1, c2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: c1.withValues(alpha: 0.35),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 52,
                width: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Text(
                  shortCode,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 17),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.language.name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        entry.level.name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 52,
                height: 52,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: pct,
                      strokeWidth: 4.5,
                      backgroundColor: Colors.white.withValues(alpha: 0.25),
                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                    ),
                    Text(
                      '$pctInt%',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 7,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                currentModule != null
                    ? Icons.menu_book_rounded
                    : Icons.flag_outlined,
                color: Colors.white70,
                size: 14,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  currentModule ??
                      (currentStep?.isNotEmpty == true
                          ? currentStep!
                          : "Continue ton aventure !"),
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoLanguageCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.card(_ctx),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
            color: _kGreen.withValues(alpha: 0.12), width: 1.5),
        boxShadow: [
          BoxShadow(
              color: AppColors.shadow(_ctx),
              blurRadius: 16,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                _kGreen.withValues(alpha: 0.10),
                _kYellow.withValues(alpha: 0.08),
              ]),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.language_rounded, size: 38, color: _kGreen),
          ),
          const SizedBox(height: 14),
          Text("Aucune langue en cours",
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: AppColors.textPrimary(_ctx))),
          const SizedBox(height: 6),
          Text("Commence par choisir une langue à apprendre",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary(_ctx), fontSize: 13)),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: _showAddLanguageSheet,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text("Choisir une langue"),
            style: ElevatedButton.styleFrom(
              backgroundColor: _kGreen,
              foregroundColor: Colors.white,
              elevation: 0,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLangSkeleton() {
    return Container(
      width: double.infinity,
      height: 170,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          _kGreen.withValues(alpha: 0.10),
          _kYellow.withValues(alpha: 0.05),
        ]),
        borderRadius: BorderRadius.circular(26),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: _kGreen, strokeWidth: 2.5),
      ),
    );
  }

  // ─── Navigation rapide ────────────────────────────────────────────────────

  Widget _buildNavigationRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_showGuide) ...[
          _buildGuideContent(),
          const SizedBox(height: 8),
        ],
        Row(
          children: [
            Expanded(
              child: _buildNavBtn(
                Icons.menu_book_rounded,
                "Modules",
                _kGreen,
                () {
                  if (_showGuide) _dismissGuide();
                  _showLanguagePickerSheet();
                },
              ),
            ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildNavBtn(
            Icons.map_rounded,
            "Parcours",
            _kOrange,
            () {
              if (!_isSubscriptionActive) {
                _showSubscriptionRequired();
                return;
              }
              Get.to(() => const ParcoursSelectionPage(), arguments: {
                'showAllPaths': true,
                'userId': session.userId.value.isNotEmpty
                    ? session.userId.value
                    : session.user?.id ?? "",
                'languageId': session.selectedLanguageId.value.isNotEmpty
                    ? session.selectedLanguageId.value
                    : session.user?.selectedLanguageId ?? "",
                'levelId': session.selectedLevelId.value.isNotEmpty
                    ? session.selectedLevelId.value
                    : session.user?.selectedLevelId ?? "",
              });
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildNavBtn(
            Icons.flag_rounded,
            "Étapes",
            _kYellow,
            () {
              if (!_isSubscriptionActive) {
                _showSubscriptionRequired();
                return;
              }
              Get.to(() => const StepsScreensPages(), arguments: {
                'showAllSteps': true,
                'userId': session.userId.value.isNotEmpty
                    ? session.userId.value
                    : session.user?.id ?? "",
                'languageId': session.selectedLanguageId.value.isNotEmpty
                    ? session.selectedLanguageId.value
                    : session.user?.selectedLanguageId ?? "",
                'levelId': session.selectedLevelId.value.isNotEmpty
                    ? session.selectedLevelId.value
                    : session.user?.selectedLevelId ?? "",
              });
            },
          ),
        ),
      ],
        ),
      ],
    );
  }

  Widget _buildGuideContent() {
    return Column(
      children: [
        // ── Bulle tooltip (fixe) ─────────────────────────────────────────
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
                  'Prêt à commencer ? Clique ici pour voir tes modules !',
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
                onTap: _dismissGuide,
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

        // ── Doigt animé — centré exactement sur le card Modules ─────────
        // La nav row = 3 Expanded séparés par 2 × SizedBox(12).
        // Centre du 1er bouton = (totalWidth - 24) / 6
        LayoutBuilder(
          builder: (_, constraints) {
            final btnWidth = (constraints.maxWidth - 24.0) / 3.0;
            final fingerCenterX = btnWidth / 2.0;
            return SizedBox(
              width: constraints.maxWidth,
              height: 46,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedBuilder(
                    animation: _bounceAnim,
                    builder: (_, child) => Positioned(
                      left: fingerCenterX - 18,
                      top: _bounceAnim.value,
                      child: child!,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomPaint(
                          size: const Size(14, 7),
                          painter: _TrianglePainter(color: _kGreen),
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
    );
  }

  Widget _buildNavBtn(
      IconData icon, String label, Color color, VoidCallback onTap) {
    final isYellow = color == _kYellow;
    final iconColor = isYellow ? const Color(0xFF1A1A1A) : Colors.white;
    final labelColor = isYellow ? _kYellowDark : color;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.card(_ctx),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.16),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.78)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.28),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: labelColor),
            ),
          ],
        ),
      ),
    );
  }

  // ─── En ce moment ─────────────────────────────────────────────────────────

  Widget _buildCurrentPathCard() {
    if (_hasProgressError) {
      return _buildErrorWidget(
        icon: Icons.cloud_off_rounded,
        message: 'Impossible de charger le parcours actuel.',
        onRetry: _loadProgressSafe,
        color: _kOrange,
      );
    }

    return Obx(() {
      if (progressCtrl.isLoading.value) {
        return Container(
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              _kGreen.withValues(alpha: 0.06),
              _kYellow.withValues(alpha: 0.04),
            ]),
            borderRadius: BorderRadius.circular(26),
          ),
          child: const Center(
              child:
                  CircularProgressIndicator(color: _kGreen, strokeWidth: 2)),
        );
      }

      final entry = progressCtrl.mostRecentEntry;
      if (entry == null || entry.module == null) return _buildNoPathCard();

      final modulePct = entry.module!.progressPercentage;
      final moduleName = entry.module!.title;
      final pathName = entry.path?.title;
      final stepName = entry.step?.title;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.card(_ctx),
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: _kGreen.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_kGreen, _kGreenDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: _kGreen.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.rocket_launch_rounded,
                      color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Parcours actuel",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary(_ctx))),
                      Text(entry.language.name,
                          style: TextStyle(
                              color: AppColors.textSecondary(_ctx), fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      _kGreen.withValues(alpha: 0.12),
                      _kYellow.withValues(alpha: 0.08),
                    ]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$modulePct%',
                    style: const TextStyle(
                        color: _kGreen,
                        fontWeight: FontWeight.w800,
                        fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _buildPathItem(
                Icons.menu_book_rounded, "Module", moduleName, _kGreen),
            if (pathName != null) ...[
              const SizedBox(height: 8),
              _buildPathItem(
                  Icons.map_rounded, "Parcours", pathName, _kOrange),
            ],
            if (stepName != null) ...[
              const SizedBox(height: 8),
              _buildPathItem(
                  Icons.flag_rounded, "Étape", stepName, _kYellow),
            ],
            const SizedBox(height: 18),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: modulePct / 100.0,
                minHeight: 8,
                backgroundColor: _kGreen.withValues(alpha: 0.10),
                valueColor: const AlwaysStoppedAnimation(_kGreen),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _showLanguagePickerSheet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text("Explorer les modules",
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildPathItem(IconData icon, String type, String value, Color color) {
    final isYellow = color == _kYellow;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: color.withValues(alpha: isYellow ? 0.15 : 0.10),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon,
              color: isYellow ? _kYellowDark : color, size: 14),
        ),
        const SizedBox(width: 10),
        Text("$type : ",
            style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary(_ctx),
                fontWeight: FontWeight.w500)),
        Expanded(
          child: Text(value,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(_ctx)),
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  Widget _buildNoPathCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.card(_ctx),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
            color: _kGreen.withValues(alpha: 0.10), width: 1.5),
        boxShadow: [
          BoxShadow(
              color: AppColors.shadow(_ctx),
              blurRadius: 16,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                _kGreen.withValues(alpha: 0.08),
                _kOrange.withValues(alpha: 0.06),
              ]),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.explore_outlined, size: 38, color: _kGreen),
          ),
          const SizedBox(height: 12),
          Text("Pas encore de parcours",
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppColors.textPrimary(_ctx))),
          const SizedBox(height: 6),
          Text("Choisis un module pour commencer",
              style: TextStyle(color: AppColors.textSecondary(_ctx), fontSize: 12)),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: _showLanguagePickerSheet,
            style: ElevatedButton.styleFrom(
              backgroundColor: _kGreen,
              foregroundColor: Colors.white,
              elevation: 0,
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text("Commencer",
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_kGreen, _kYellow],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Text(title,
            style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary(_ctx))),
      ],
    );
  }

  Widget _buildSectionTitleLangue(String title, String subtitle) {
    return Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_kGreen, _kYellow],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 10),
                Text(title,
                    style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary(_ctx))),
              ],
            ),
            if (controller.user.value?.accountType != 'sub_account_learner')
              GestureDetector(
                onTap: _showAddLanguageSheet,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      _kGreen.withValues(alpha: 0.10),
                      _kYellow.withValues(alpha: 0.08),
                    ]),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: _kGreen.withValues(alpha: 0.2), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add_rounded, color: _kGreen, size: 15),
                      const SizedBox(width: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: _kGreen,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ));
  }

  // ─── Add language bottom sheet ────────────────────────────────────────────

  void _showAddLanguageSheet() {
    final langCtrl = Get.isRegistered<LanguagesController>()
        ? Get.find<LanguagesController>()
        : Get.put(LanguagesController());

    langCtrl.selectedLanguage.value = null;
    langCtrl.selectedLevel.value = null;
    langCtrl.languageLevels.clear();
    langCtrl.loadAllLanguages();

    final enrolledIds =
        progressCtrl.progressList.map((e) => e.language.id).toSet();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddLanguageSheet(
        langCtrl: langCtrl,
        enrolledIds: enrolledIds,
        onSuccess: () {
          _loadProgressSafe();
          Get.snackbar(
            'Langue ajoutée',
            'La nouvelle langue a été ajoutée avec succès.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: _kGreen,
            colorText: Colors.white,
            margin: const EdgeInsets.all(16),
            borderRadius: 16,
            icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
          );
        },
      ),
    );
  }

  // ─── Language picker bottom sheet ─────────────────────────────────────────

  void _navigateToModules(UserProgressEntry entry) {
    session.selectedLanguageId.value = entry.language.id;
    session.selectedLevelId.value = entry.level.id;
    if (Get.isRegistered<HomeController>()) {
      Get.delete<HomeController>(force: true);
    }
    Get.to(
      () => const HomePage(),
      arguments: {
        'languageId': entry.language.id,
        'levelId': entry.level.id,
      },
    );
  }

  void _showLanguagePickerSheet() {
    if (progressCtrl.isLoading.value) {
      Get.snackbar(
        'Chargement...',
        'Tes langues sont en cours de chargement.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: _kGreen,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 16,
      );
      return;
    }

    if (_hasProgressError) {
      Get.snackbar(
        'Erreur de chargement',
        _progressErrorMsg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE53E3E),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 16,
        mainButton: TextButton(
          onPressed: () {
            Get.closeCurrentSnackbar();
            _loadProgressSafe();
          },
          child: const Text('Réessayer',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w700)),
        ),
      );
      return;
    }

    final entries = progressCtrl.progressList;

    if (entries.isEmpty) {
      Get.snackbar(
        'Aucune langue inscrite',
        'Tu n\'as pas encore de langue assignée.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 16,
      );
      return;
    }

    if (entries.length == 1) {
      _navigateToModules(entries.first);
      return;
    }

    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: AppColors.bg(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                    color: AppColors.divider(context),
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_kGreen, _kYellow],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 10),
                Text("Choisir une langue",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary(context))),
              ],
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 14),
              child: Text("Sélectionne la langue pour voir ses modules",
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary(context))),
            ),
            const SizedBox(height: 18),
            ...entries.map((entry) {
              final pct = entry.language.progressPercentage;
              final code = entry.language.code.toUpperCase();
              final shortCode = code.length >= 2 ? code.substring(0, 2) : code;
              final colors = _langColors(entry.language.name);
              final c1 = colors[0];

              return GestureDetector(
                onTap: () {
                  Get.back();
                  _navigateToModules(entry);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card(context),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: c1.withValues(alpha: 0.10),
                          blurRadius: 12,
                          offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [c1, c1.withValues(alpha: 0.72)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.center,
                        child: Text(shortCode,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 15)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(entry.language.name,
                                style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                    color: AppColors.textPrimary(context))),
                            const SizedBox(height: 2),
                            Text(entry.level.name,
                                style: TextStyle(
                                    fontSize: 12, color: AppColors.textSecondary(context))),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: pct / 100.0,
                                minHeight: 6,
                                backgroundColor: Colors.grey[100],
                                valueColor: AlwaysStoppedAnimation<Color>(c1),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text('$pct% complété',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: c1,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: _kGreen.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.chevron_right_rounded,
                            color: _kGreen, size: 20),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}

// ─── Add Language Bottom Sheet ───────────────────────────────────────────────

// ─── Triangle pointer for guide tooltip ─────────────────────────────────────

class _TrianglePainter extends CustomPainter {
  final Color color;
  const _TrianglePainter({required this.color});

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
  bool shouldRepaint(_TrianglePainter old) => old.color != color;
}

// ─── Add Language Bottom Sheet ───────────────────────────────────────────────

class _AddLanguageSheet extends StatefulWidget {
  final LanguagesController langCtrl;
  final Set<String> enrolledIds;
  final VoidCallback onSuccess;

  const _AddLanguageSheet({
    required this.langCtrl,
    required this.enrolledIds,
    required this.onSuccess,
  });

  @override
  State<_AddLanguageSheet> createState() => _AddLanguageSheetState();
}

class _AddLanguageSheetState extends State<_AddLanguageSheet> {
  int _step = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bg(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 32),
      child: _step == 0 ? _buildLanguageStep() : _buildLevelStep(),
    );
  }

  Widget _buildDragHandle(BuildContext context) {
    return Center(
      child: Container(
        width: 44,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.divider(context),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildLanguageStep() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDragHandle(context),
        const SizedBox(height: 18),
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_kGreen, _kYellow],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              "Ajouter une langue",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary(context)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Text(
            "Choisis la langue que tu veux apprendre",
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
          ),
        ),
        const SizedBox(height: 18),
        Obx(() {
          if (widget.langCtrl.isLoading.value) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(
                    color: _kGreen, strokeWidth: 2.5),
              ),
            );
          }
          if (widget.langCtrl.allLanguages.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.language_rounded,
                        size: 40, color: Colors.grey.shade300),
                    const SizedBox(height: 10),
                    Text(
                      "Aucune langue disponible",
                      style: TextStyle(
                          color: Colors.grey[500], fontSize: 14),
                    ),
                  ],
                ),
              ),
            );
          }
          return ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.45,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.langCtrl.allLanguages.length,
              itemBuilder: (_, i) {
                final lang = widget.langCtrl.allLanguages[i];
                final isEnrolled = widget.enrolledIds.contains(lang.id);
                final code = lang.code.toUpperCase();
                final shortCode =
                    code.length >= 2 ? code.substring(0, 2) : code;
                final colors = _langColors(lang.name);
                final c1 = colors[0];
                return GestureDetector(
                  onTap: isEnrolled
                      ? null
                      : () async {
                          widget.langCtrl.selectedLanguage.value = lang;
                          widget.langCtrl.languageLevels.clear();
                          await widget.langCtrl.loadLanguageLevels();
                          if (mounted) setState(() => _step = 1);
                        },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isEnrolled
                          ? _kGreen.withValues(alpha: 0.05)
                          : AppColors.card(context),
                      borderRadius: BorderRadius.circular(20),
                      border: isEnrolled
                          ? Border.all(color: _kGreen, width: 1.8)
                          : null,
                      boxShadow: isEnrolled
                          ? []
                          : [
                              BoxShadow(
                                color: c1.withValues(alpha: 0.10),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isEnrolled
                                  ? [_kGreen, _kGreenDark]
                                  : [c1, c1.withValues(alpha: 0.72)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          alignment: Alignment.center,
                          child: isEnrolled
                              ? const Icon(Icons.check_rounded,
                                  color: Colors.white, size: 22)
                              : Text(shortCode,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 15)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(lang.name,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                      color: isEnrolled
                                          ? _kGreen
                                          : AppColors.textPrimary(context))),
                              const SizedBox(height: 2),
                              if (isEnrolled)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _kGreen.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    "Déjà inscrit",
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: _kGreen,
                                        fontWeight: FontWeight.w600),
                                  ),
                                )
                              else if (lang.description.isNotEmpty)
                                Text(lang.description,
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[500]),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                        if (!isEnrolled)
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: _kGreen.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.chevron_right_rounded,
                                color: _kGreen, size: 20),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildLevelStep() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDragHandle(context),
        const SizedBox(height: 18),
        Row(
          children: [
            GestureDetector(
              onTap: () => setState(() => _step = 0),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.card(context),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.07),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(Icons.arrow_back_ios_new,
                    size: 16, color: AppColors.textPrimary(context)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(() => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Choisir un niveau",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary(context)),
                      ),
                      Text(
                        widget.langCtrl.selectedLanguage.value?.name ?? '',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary(context)),
                      ),
                    ],
                  )),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Obx(() {
          if (widget.langCtrl.isLoadingLevels.value) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(
                    color: _kGreen, strokeWidth: 2.5),
              ),
            );
          }
          final levels = widget.langCtrl.languageLevels;
          if (levels.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.bar_chart_rounded,
                        size: 40, color: Colors.grey.shade300),
                    const SizedBox(height: 10),
                    Text(
                      "Aucun niveau disponible",
                      style: TextStyle(color: Colors.grey[500], fontSize: 14),
                    ),
                  ],
                ),
              ),
            );
          }
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.35,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: levels.length,
                  itemBuilder: (_, i) {
                    final level = levels[i];
                    final levelId = level is Map
                        ? level['id']?.toString() ?? ''
                        : level?.id?.toString() ?? '';
                    final levelName = level is Map
                        ? level['name']?.toString() ?? 'Niveau'
                        : level?.name?.toString() ?? 'Niveau';
                    return Obx(() {
                      final sel = widget.langCtrl.selectedLevel.value;
                      final selId = sel == null
                          ? ''
                          : sel is Map
                              ? sel['id']?.toString() ?? ''
                              : sel?.id?.toString() ?? '';
                      final isSelected =
                          selId == levelId && levelId.isNotEmpty;
                      return GestureDetector(
                        onTap: () =>
                            widget.langCtrl.selectedLevel.value = level,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? _kGreen.withValues(alpha: 0.07)
                                : AppColors.card(context),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isSelected
                                  ? _kGreen
                                  : Colors.transparent,
                              width: 2,
                            ),
                            boxShadow: isSelected
                                ? []
                                : [
                                    BoxShadow(
                                      color: Colors.black
                                          .withValues(alpha: 0.05),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? const LinearGradient(
                                          colors: [_kGreen, _kGreenDark],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : null,
                                  color: isSelected
                                      ? null
                                      : AppColors.cardAlt(context),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '${i + 1}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 15,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.grey[400],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  levelName,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected
                                        ? _kGreen
                                        : AppColors.textPrimary(context),
                                  ),
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check_circle_rounded,
                                    color: _kGreen, size: 22),
                            ],
                          ),
                        ),
                      );
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),
              Obx(() => SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: widget.langCtrl.isLoading.value ||
                              widget.langCtrl.selectedLevel.value == null
                          ? null
                          : () async {
                              final ok = await widget.langCtrl
                                  .addLanguageLevelToList();
                              if (ok && mounted) {
                                Navigator.of(context).pop();
                                widget.onSuccess();
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kGreen,
                        disabledBackgroundColor: Colors.grey.shade200,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: widget.langCtrl.isLoading.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2.5, color: Colors.white),
                            )
                          : const Text(
                              "Confirmer",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15),
                            ),
                    ),
                  )),
            ],
          );
        }),
      ],
    );
  }
}
