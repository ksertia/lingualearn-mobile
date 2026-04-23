import 'package:fasolingo/controller/apps/moduls/home_controller.dart';
import 'package:fasolingo/controller/apps/session_controller.dart';
import 'package:fasolingo/controller/apps/user_progress/user_progress_controller.dart';
import 'package:fasolingo/helpers/storage/local_storage.dart';
import 'package:fasolingo/models/user_progress/user_progress_model.dart';
import 'package:fasolingo/views/apps/home/dashboard_screen.dart';
import 'package:fasolingo/views/apps/home/screens/parcours.dart';
import 'package:fasolingo/views/apps/home/screens/stepsscreens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

// ── Palette ────────────────────────────────────────────────────────────────
const _kOrange1 = Color(0xFFFF7043);
const _kOrange2 = Color(0xFFFFB74D);
const _kPurple = Color(0xFF7C3AED);
const _kBlue = Color(0xFF0EA5E9);
const _kBg = Color(0xFFF6F8FF);

const _kLangColors = [
  [Color(0xFF7C3AED), Color(0xFF5B21B6)],
  [Color(0xFF0EA5E9), Color(0xFF0369A1)],
  [Color(0xFF10B981), Color(0xFF047857)],
  [Color(0xFFFF7043), Color(0xFFE64A19)],
  [Color(0xFFF59E0B), Color(0xFFD97706)],
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

class _AcceuilleSreenState extends State<AcceuilleSreen> {
  final SessionController session = Get.find<SessionController>();
  late final UserProgressController progressCtrl;

  final RxInt _currentLangPage = 0.obs;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    progressCtrl = Get.isRegistered<UserProgressController>()
        ? Get.find<UserProgressController>()
        : Get.put(UserProgressController());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: progressCtrl.refresh,
          color: _kOrange1,
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
                      _buildSectionTitle("Mes langues"),
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
      padding: const EdgeInsets.fromLTRB(22, 24, 16, 26),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_kOrange1, _kOrange2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.local_fire_department_rounded,
                          color: Colors.white, size: 14),
                      SizedBox(width: 5),
                      Text(
                        "Bonne journée !",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
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
          SizedBox(
            width: 90,
            height: 90,
            child: Lottie.asset(
              'assets/lottie/mascot.json',
              fit: BoxFit.contain,
              repeat: true,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Mes langues ──────────────────────────────────────────────────────────

  Widget _buildLanguageSection() {
    return Obx(() {
      if (progressCtrl.isLoading.value) return _buildLangSkeleton();

      final entries = progressCtrl.progressList;
      if (entries.isEmpty) return _buildNoLanguageCard();

      if (entries.length == 1) {
        return _buildLangCard(entries.first);
      }

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
                    width: _currentLangPage.value == i ? 20 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _currentLangPage.value == i
                          ? _kOrange1
                          : _kOrange1.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              )),
        ],
      );
    });
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
              // Circular progress
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
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.language_rounded, size: 48, color: Colors.orange.shade200),
          const SizedBox(height: 12),
          const Text("Aucune langue en cours",
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: Color(0xFF1A1A1A))),
          const SizedBox(height: 6),
          Text("Commence par choisir une langue à apprendre",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
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
          _kOrange1.withValues(alpha: 0.10),
          _kOrange2.withValues(alpha: 0.05),
        ]),
        borderRadius: BorderRadius.circular(26),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: _kOrange1, strokeWidth: 2.5),
      ),
    );
  }

  // ─── Navigation rapide ────────────────────────────────────────────────────

  Widget _buildNavigationRow() {
    return Row(
      children: [
        Expanded(
          child: _buildNavBtn(
            Icons.menu_book_rounded,
            "Modules",
            _kPurple,
            _showLanguagePickerSheet,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildNavBtn(
            Icons.map_rounded,
            "Parcours",
            _kBlue,
            () => Get.to(() => const ParcoursSelectionPage(), arguments: {
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
            }),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildNavBtn(
            Icons.flag_rounded,
            "Étapes",
            _kOrange1,
            () => Get.to(() => const StepsScreensPages(), arguments: {
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
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildNavBtn(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.14),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.72)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 12.5, fontWeight: FontWeight.w700, color: color),
            ),
          ],
        ),
      ),
    );
  }

  // ─── En ce moment ─────────────────────────────────────────────────────────

  Widget _buildCurrentPathCard() {
    return Obx(() {
      if (progressCtrl.isLoading.value) {
        return Container(
          height: 120,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(26)),
          child: const Center(
              child:
                  CircularProgressIndicator(color: _kOrange1, strokeWidth: 2)),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 18,
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
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient:
                        const LinearGradient(colors: [_kOrange1, _kOrange2]),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.rocket_launch_rounded,
                      color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Parcours actuel",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1A1A1A))),
                      Text(entry.language.name,
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$modulePct%',
                    style: const TextStyle(
                        color: _kOrange1,
                        fontWeight: FontWeight.w800,
                        fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _buildPathItem(
                Icons.menu_book_rounded, "Module", moduleName, _kPurple),
            if (pathName != null) ...[
              const SizedBox(height: 8),
              _buildPathItem(Icons.map_rounded, "Parcours", pathName, _kBlue),
            ],
            if (stepName != null) ...[
              const SizedBox(height: 8),
              _buildPathItem(Icons.flag_rounded, "Étape", stepName, _kOrange1),
            ],
            const SizedBox(height: 18),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: modulePct / 100.0,
                minHeight: 7,
                backgroundColor: const Color(0xFFF0F0F0),
                valueColor: const AlwaysStoppedAnimation(_kOrange1),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _showLanguagePickerSheet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kOrange1,
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
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 14),
        ),
        const SizedBox(width: 10),
        Text("$type : ",
            style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500)),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A)),
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  Widget _buildNoPathCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.explore_outlined, size: 44, color: Colors.orange.shade200),
          const SizedBox(height: 10),
          const Text("Pas encore de parcours",
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: Color(0xFF1A1A1A))),
          const SizedBox(height: 5),
          Text("Choisis un module pour commencer",
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _showLanguagePickerSheet,
            style: ElevatedButton.styleFrom(
              backgroundColor: _kOrange1,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text("Commencer"),
          ),
        ],
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A1A1A)));
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
        backgroundColor: Colors.black87,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 16,
      );
      return;
    }

    final entries = progressCtrl.progressList;

    if (entries.isEmpty) {
      Get.snackbar(
        'Aucune langue inscrite',
        'Tu n\'as pas encore de langue assignee.',
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
        decoration: const BoxDecoration(
          color: Color(0xFFF8F9FF),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 18),
            const Text("Choisir une langue",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A1A))),
            const SizedBox(height: 4),
            Text("Sélectionne la langue pour voir ses modules",
                style: TextStyle(fontSize: 13, color: Colors.grey[500])),
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
                    color: Colors.white,
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
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                    color: Color(0xFF1A1A1A))),
                            const SizedBox(height: 2),
                            Text(entry.level.name,
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[500])),
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
                      Icon(Icons.chevron_right_rounded,
                          color: Colors.grey[300], size: 22),
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
