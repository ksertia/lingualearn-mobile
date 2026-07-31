import 'package:tibi/controller/apps/progression/progression_detail_controller.dart';
import 'package:tibi/controller/apps/session_controller.dart';
import 'package:tibi/controller/apps/settings/children_controller.dart';
import 'package:tibi/controller/apps/user_progress/user_progress_controller.dart';
import 'package:tibi/helpers/theme/app_colors.dart';
import 'package:tibi/models/child_model.dart';
import 'package:tibi/models/progression/progression_detail_model.dart';
import 'package:tibi/models/user_progress/user_progress_model.dart';
import 'package:tibi/views/apps/setting/widget/sous-compte/child_progress_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:collection/collection.dart';
import 'package:lottie/lottie.dart';
import 'package:tibi/widgets/mascots/zaki_mascot.dart';
import 'package:shimmer/shimmer.dart';

// ── Brand palette ──────────────────────────────────────────────────────────────
const Color _kGreen      = Color(0xFF188329);
const Color _kLocked    = Color(0xFFB0BEC5);
const Color _kOrange     = Color(0xFFF27F22);



class ProgresPage extends StatefulWidget {
  const ProgresPage({super.key});

  @override
  State<ProgresPage> createState() => _ProgresPageState();
}

class _ProgresPageState extends State<ProgresPage> {
  bool _isLoading = true;

  late final ProgressionDetailController _detailCtrl;
  late final UserProgressController _progressCtrl;
  late final SessionController _session;
  late final ChildrenController _childrenCtrl;

  String _selectedLangId  = '';
  String _selectedLevelId = '';
  bool   _childrenExpanded = false;

  // ── Getters délégués au contrôleur ────────────────────────────────────────
  String get _languageName    => _detailCtrl.languageName;
  String get _levelName       => _detailCtrl.nameForLevel(
      _selectedLevelId.isNotEmpty ? _selectedLevelId : _session.selectedLevelId.value);
  int    get _totalXp         => _detailCtrl.totalXp;
  int    get _totalMinutes       => _detailCtrl.totalMinutes;
  int    get _quizScore          => _detailCtrl.avgQuizScore;
      ProgLevel? get _selectedLevel  => _detailCtrl.levels.firstWhereOrNull(
        (l) => l.id == _selectedLevelId,
      );
  int    get _levelTotalModules    => _selectedLevel?.modules.length ?? 0;
  int    get _levelCompletedModules => _selectedLevel?.completedModuleCount ?? 0;
  int    get _levelInProgressModules => _selectedLevel?.inProgressModuleCount ?? 0;
  int    get _levelLockedModules     => _selectedLevel?.lockedModuleCount ?? 0;
  int    get _levelProgressPct       => _selectedLevel?.progressPercent ?? 0;

  // ── Init ───────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _session = Get.find<SessionController>();
    _detailCtrl = Get.isRegistered<ProgressionDetailController>()
        ? Get.find<ProgressionDetailController>()
        : Get.put(ProgressionDetailController());
    _progressCtrl = Get.isRegistered<UserProgressController>()
        ? Get.find<UserProgressController>()
        : Get.put(UserProgressController());
    _childrenCtrl = Get.isRegistered<ChildrenController>()
        ? Get.find<ChildrenController>()
        : Get.put(ChildrenController());
    _selectedLangId  = _session.selectedLanguageId.value;
    _selectedLevelId = _session.selectedLevelId.value;
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final langId = _selectedLangId.isNotEmpty
        ? _selectedLangId
        : (_session.selectedLanguageId.value.isNotEmpty
            ? _session.selectedLanguageId.value
            : _session.user?.selectedLanguageId ?? '');
    await Future.wait([
      _detailCtrl.load(
        userId: _session.userId.value.isNotEmpty
            ? _session.userId.value
            : _session.user?.id ?? '',
        languageId: langId,
      ),
      _progressCtrl.loadProgress(),
      _childrenCtrl.fetchMyChildren(),
    ]);
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _switchLanguage(UserProgressEntry entry) async {
    if (_selectedLangId == entry.language.id) return;
    setState(() {
      _selectedLangId  = entry.language.id;
      _selectedLevelId = entry.level.id;
      _isLoading = true;
    });
    await _detailCtrl.load(
      userId: _session.userId.value.isNotEmpty
          ? _session.userId.value
          : _session.user?.id ?? '',
      languageId: entry.language.id,
    );
    if (mounted) setState(() => _isLoading = false);
  }

  List<UserProgressEntry> _uniqueLanguages(List<UserProgressEntry> all) {
    final map = <String, UserProgressEntry>{};
    for (final e in all) {
      final ex = map[e.language.id];
      if (ex == null) { map[e.language.id] = e; continue; }
      final et = e.language.lastAccessedAt;
      final ext = ex.language.lastAccessedAt;
      if (et != null && (ext == null || et.isAfter(ext))) map[e.language.id] = e;
    }
    return map.values.toList()
      ..sort((a, b) {
        final at = a.language.lastAccessedAt;
        final bt = b.language.lastAccessedAt;
        if (at == null && bt == null) return 0;
        if (at == null) return 1;
        if (bt == null) return -1;
        return bt.compareTo(at);
      });
  }

  // ── Language selector ─────────────────────────────────────────────────────

  Widget _buildLangSelector(BuildContext context) {
    return Obx(() {
      final entries = _uniqueLanguages(_progressCtrl.progressList.toList());
      if (entries.length < 2) return const SizedBox.shrink();
      return Container(
        color: AppColors.bg(context),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
          child: Row(
            children: entries.map((e) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildSelectorPill(
                context: context,
                label: e.language.name,
                isSelected: _selectedLangId == e.language.id,
                onTap: () => _switchLanguage(e),
              ),
            )).toList(),
          ),
        ),
      );
    });
  }

  Widget _buildSelectorPill({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(colors: [_kOrange, _kOrange])
              : null,
          color: isSelected ? null : AppColors.card(context),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? Colors.transparent : _kOrange.withValues(alpha: 0.35),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: _kOrange.withValues(alpha: 0.30), blurRadius: 10, offset: const Offset(0, 4))]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.language_rounded,
                size: 14,
                color: isSelected ? Colors.white : _kOrange),
            const SizedBox(width: 7),
            Text(label,
              style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : AppColors.textPrimary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _formatTime(int min) {
    if (min <= 0) return '0m';
    if (min < 60) return '${min}m';
    final h = min ~/ 60; final m = min % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }

  String _formatXp(int xp) {
    if (xp >= 10000) return '${(xp / 1000).toStringAsFixed(0)}k';
    if (xp >= 1000)  return '${(xp / 1000).toStringAsFixed(1)}k';
    return '$xp';
  }



  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: Column(
        children: [
          _buildHeader(context),
          _buildLangSelector(context),
          Expanded(
            child: RefreshIndicator(
              color: _kOrange,
              onRefresh: _load,
              child: _isLoading
                  ? _buildShimmer(context)
                  : SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                        16, 20, 16,
                        MediaQuery.of(context).padding.bottom + 28,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildXpCard(context),
                          const SizedBox(height: 26),
                          _buildSectionTitle(context, 'Mes exploits',
                              Icons.emoji_events_rounded, _kOrange),
                          const SizedBox(height: 12),
                          _buildStatsRow(context),
                          const SizedBox(height: 26),
                          _buildSectionTitle(context, 'Progression des modules',
                              Icons.bar_chart_rounded, _kOrange),
                          const SizedBox(height: 12),
                          _buildModuleProgress(context),
                          const SizedBox(height: 26),
                          _buildChildrenSection(context),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20, MediaQuery.of(context).padding.top + 16, 20, 24,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_kOrange, _kOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ma Progression',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  children: [
                    if (_languageName.isNotEmpty)
                      _headerChip(_languageName, Icons.language_rounded),
                    if (_levelName.isNotEmpty)
                      _headerChip(_levelName, Icons.layers_rounded),
                  ],
                ),
              ],
            ),
          ),
          const ZakiMascot(mood: ZakiMood.happy, size: ZakiSize.sm),
        ],
      ),
    );
  }

  Widget _headerChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 12),
          const SizedBox(width: 5),
          Text(text,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  // ── Section title ──────────────────────────────────────────────────────────

  Widget _buildSectionTitle(
      BuildContext context, String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          width: 4, height: 20,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, _kOrange],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 15),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary(context)),
        ),
      ],
    );
  }

  // ── Language Progress Circle Card ──────────────────────────────────────────

  Widget _buildXpCard(BuildContext context) {
    final progress = _levelTotalModules > 0
        ? (_levelCompletedModules / _levelTotalModules).clamp(0.0, 1.0)
        : 0.0;
    final pct = _selectedLevel != null
        ? _levelProgressPct
        : (progress * 100).round();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _kOrange.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Cercle gauche + infos droite ───────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Cercle 120px — SizedBox explicite sur l'indicateur pour forcer la taille
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: progress),
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeOutCubic,
                builder: (_, value, __) => SizedBox(
                  width: 120,
                  height: 120,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: CircularProgressIndicator(
                          value: value,
                          strokeWidth: 11,
                          strokeCap: StrokeCap.round,
                          backgroundColor: _kOrange.withValues(alpha: 0.10),
                          valueColor: const AlwaysStoppedAnimation(_kOrange),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$pct%',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary(context),
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'progression',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary(context),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // Langue + niveau — alignés à gauche du côté droit
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: _kOrange.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.language_rounded,
                              color: _kOrange, size: 15),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _languageName.isNotEmpty ? _languageName : '—',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_levelName.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.grey.shade200, width: 1),
                        ),
                        child: Text(
                          _levelName,
                          style: const TextStyle(
                            fontSize: 12,
                            color: _kOrange,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // ── Stats en bas ───────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.bg(context),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _circleStatCol(context, Icons.check_circle_rounded,
                    '$_levelCompletedModules', 'Terminés', _kGreen),
                Container(width: 1, height: 32, color: AppColors.border(context)),
                _circleStatCol(context, Icons.play_circle_rounded,
                    '$_levelInProgressModules', 'En cours', _kOrange),
                Container(width: 1, height: 32, color: AppColors.border(context)),
                _circleStatCol(context, Icons.lock_rounded,
                    '$_levelLockedModules', 'Verrouillés', _kLocked),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleStatCol(BuildContext context, IconData icon, String value,
      String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary(context))),
        const SizedBox(height: 2),
        Text(label,
            style: TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary(context),
                fontWeight: FontWeight.w500)),
      ],
    );
  }

  // ── Stats Row ──────────────────────────────────────────────────────────────

  Widget _buildStatsRow(BuildContext context) {
    return Row(
      children: [
        _statCard(context, Icons.bolt_rounded, _formatXp(_totalXp),
            'Total XP', Colors.black),
        const SizedBox(width: 12),
        _statCard(context, Icons.timer_rounded, _formatTime(_totalMinutes),
            'Temps total', Colors.black),
        const SizedBox(width: 12),
        _statCard(context, Icons.quiz_rounded, '$_quizScore%',
            'Score quiz', Colors.black),
      ],
    );
  }

  Widget _statCard(BuildContext context, IconData icon, String value,
      String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.card(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.15), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                  fontSize: 17, fontWeight: FontWeight.w900, color: color),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary(context),
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  // ── Module Progress ────────────────────────────────────────────────────────

  Widget _buildModuleProgress(BuildContext context) {
    final items = [
      _ModuleStat('Terminés',      _levelCompletedModules,  _kGreen,  Icons.check_circle_rounded),
      _ModuleStat('En cours',      _levelInProgressModules, _kOrange, Icons.play_circle_rounded),
      _ModuleStat('Verrouillés',   _levelLockedModules,     _kLocked, Icons.lock_rounded),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
              color: AppColors.shadow(context),
              blurRadius: 12,
              offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        children: [
          // Résumé rapide en haut
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$_levelTotalModules',
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary(context)),
              ),
              const SizedBox(width: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('modules',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary(context),
                          fontWeight: FontWeight.w600)),
                  Text('dans ce niveau',
                      style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary(context))),
                ],
              ),
              const Spacer(),
              // Mini donut indicatif
              SizedBox(
                width: 52,
                height: 52,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: _levelTotalModules > 0
                          ? _levelCompletedModules / _levelTotalModules
                          : 0.0,
                      strokeWidth: 6,
                      backgroundColor: _kLocked.withValues(alpha: 0.20),
                      valueColor: const AlwaysStoppedAnimation(_kGreen),
                    ),
                    Text(
                      '$_levelCompletedModules',
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: _kGreen),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 16),
          // Barres détaillées
          ...items.map((item) {
            final frac = _levelTotalModules > 0
                ? item.count / _levelTotalModules
                : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: item.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(item.icon, color: item.color, size: 15),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(item.label,
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary(context))),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: item.color.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${item.count} / $_levelTotalModules',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: item.color,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 7),
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: frac.clamp(0.0, 1.0)),
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeOutCubic,
                          builder: (_, v, __) => ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: v,
                              minHeight: 7,
                              backgroundColor:
                                  item.color.withValues(alpha: 0.10),
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(item.color),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Children Section ──────────────────────────────────────────────────────

  static const List<String> _animalLotties = [
    'dino.json', 'elephant.json', 'cat.json',
    'Dog.json',  'Lion.json',     'Chicken.json', 'poulet.json',
  ];

  Widget _buildChildrenSection(BuildContext context) {
    return Obx(() {
      final children = _childrenCtrl.children.toList();
      if (children.isEmpty) return const SizedBox.shrink();

      return GestureDetector(
        onTap: () => setState(() => _childrenExpanded = !_childrenExpanded),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: AppColors.card(context),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _childrenExpanded
                  ? _kOrange.withValues(alpha: 0.35)
                  : AppColors.border(context),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: _childrenExpanded
                    ? _kOrange.withValues(alpha: 0.10)
                    : Colors.black.withValues(alpha: 0.04),
                blurRadius: _childrenExpanded ? 16 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // ── Header ───────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _kOrange.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.people_rounded,
                          color: _kOrange, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mes apprenants',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary(context)),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${children.length} compte${children.length > 1 ? 's' : ''} rattaché${children.length > 1 ? 's' : ''}',
                            style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary(context),
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    // Badge nombre
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _kOrange.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${children.length}',
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: _kOrange),
                      ),
                    ),
                    const SizedBox(width: 10),
                    AnimatedRotation(
                      turns: _childrenExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 250),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: _childrenExpanded
                            ? _kOrange
                            : AppColors.textSecondary(context),
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
              // ── Liste dépliable ───────────────────────────────────
              AnimatedSize(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                child: _childrenExpanded
                    ? Column(
                        children: [
                          const Divider(height: 1),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                            child: Column(
                              children: children.map((child) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: GestureDetector(
                                  onTap: () => Get.to(() =>
                                      ChildProgressDetailPage(child: child)),
                                  child: _buildChildCard(context, child),
                                ),
                              )).toList(),
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildChildCard(BuildContext context, ChildModel child) {
    final name     = child.displayName;
    final initial  = name.isNotEmpty ? name.characters.first.toUpperCase() : 'U';
    final subtitle = (child.username ?? '').isNotEmpty
        ? '@${child.username}'
        : (child.email ?? '').isNotEmpty
            ? child.email!
            : '—';
    final idx    = name.hashCode.abs() % _animalLotties.length;
    final animal = _animalLotties[idx];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Row(
              children: [
                // Avatar animal Lottie + initiale
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 54, height: 54,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFF5F5F5),
                        border: Border.all(
                            color: const Color(0xFFEEEEEE), width: 1.5),
                      ),
                      child: ClipOval(
                          child: Lottie.asset('assets/lottie/$animal',
                              fit: BoxFit.cover)),
                    ),
                    Positioned(
                      bottom: -2, right: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: _kOrange,
                          borderRadius: BorderRadius.circular(7),
                          border:
                              Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: Text(initial,
                            style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF1A1A1A))),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                // Nom + sous-titre
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary(context))),
                      const SizedBox(height: 3),
                      Text(subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF9CA3AF))),
                    ],
                  ),
                ),
                // Badge Actif
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF9E0),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: _kOrange.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                          width: 6, height: 6,
                          decoration: const BoxDecoration(
                              color: _kOrange, shape: BoxShape.circle)),
                      const SizedBox(width: 5),
                      const Text('Actif',
                          style: TextStyle(
                              fontSize: 11,
                              color: _kOrange,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, indent: 14, endIndent: 14,
              color: Color(0xFFF5F5F5)),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: Row(
              children: [
                const Icon(Icons.show_chart_rounded,
                    size: 14, color: _kOrange),
                const SizedBox(width: 5),
                const Text('Voir la progression',
                    style: TextStyle(
                        fontSize: 12,
                        color: _kOrange,
                        fontWeight: FontWeight.w700)),
                const Spacer(),
                const Text('Détails',
                    style: TextStyle(
                        fontSize: 12, color: Color(0xFFBBBBBB))),
                const SizedBox(width: 3),
                const Icon(Icons.arrow_forward_ios_rounded,
                    size: 11, color: Color(0xFFBBBBBB)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Shimmer ────────────────────────────────────────────────────────────────

  Widget _buildShimmer(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase(context),
      highlightColor: AppColors.shimmerHighlight(context),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // XP card
            Container(
              height: 140,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24)),
            ),
            const SizedBox(height: 24),
            // Stats row
            Row(
              children: List.generate(3, (_) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: _ < 2 ? 12 : 0),
                  child: Container(
                    height: 110,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              )),
            ),
            const SizedBox(height: 24),
            // Module card
            Container(
              height: 180,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Data classes ───────────────────────────────────────────────────────────────

class _ModuleStat {
  final String label;
  final int count;
  final Color color;
  final IconData icon;
  const _ModuleStat(this.label, this.count, this.color, this.icon);
}

