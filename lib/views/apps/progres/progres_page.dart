import 'package:fasolingo/controller/apps/progression/progression_detail_controller.dart';
import 'package:fasolingo/controller/apps/session_controller.dart';
import 'package:fasolingo/controller/apps/user_progress/user_progress_controller.dart';
import 'package:fasolingo/helpers/theme/app_colors.dart';
import 'package:fasolingo/models/user_progress/user_progress_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';

// ── Brand palette ──────────────────────────────────────────────────────────────
const Color _kGreen     = Color(0xFF188329);
const Color _kGreenDark = Color(0xFF0F5C1C);
const Color _kYellow    = Color(0xFFF5BF1E);
const Color _kOrange    = Color(0xFFF27F22);
const Color _kBlue      = Color(0xFF0EA5E9);
const Color _kPurple    = Color(0xFF7C3AED);
const Color _kLocked    = Color(0xFFB0BEC5);

// ─────────────────────────────────────────────────────────────────────────────

class ProgresPage extends StatefulWidget {
  const ProgresPage({super.key});

  @override
  State<ProgresPage> createState() => _ProgresPageState();
}

class _ProgresPageState extends State<ProgresPage> {
  bool _isLoading = true;
  static const int _targetXp = 1000;

  late final ProgressionDetailController _detailCtrl;
  late final UserProgressController _progressCtrl;
  late final SessionController _session;

  String _selectedLangId  = '';
  String _selectedLevelId = '';

  // ── Getters délégués au contrôleur ────────────────────────────────────────
  String get _languageName    => _detailCtrl.languageName;
  String get _levelName       => _detailCtrl.nameForLevel(
      _selectedLevelId.isNotEmpty ? _selectedLevelId : _session.selectedLevelId.value);
  int    get _totalXp         => _detailCtrl.totalXp;
  int    get _totalMinutes    => _detailCtrl.totalMinutes;
  int    get _quizScore       => _detailCtrl.avgQuizScore;
  int    get _currentLevelXp  => _detailCtrl.xpForLevel(_session.selectedLevelId.value);
  int    get _completedModules  => _detailCtrl.completedModules;
  int    get _inProgressModules => _detailCtrl.inProgressModules;
  int    get _lockedModules     => _detailCtrl.lockedModules;
  int    get _totalModules      => _detailCtrl.totalModules;

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
                emoji: _langEmoji(e.language.name),
                pct: e.language.progressPercentage.clamp(0, 100),
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
    required String emoji,
    required int pct,
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
              ? const LinearGradient(
                  colors: [_kGreen, _kGreenDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : AppColors.card(context),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? Colors.transparent : _kGreen.withValues(alpha: 0.22),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: _kGreen.withValues(alpha: 0.30), blurRadius: 10, offset: const Offset(0, 4))]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 15)),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.22)
                    : _kGreen.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$pct%',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? Colors.white : _kGreen,
                ),
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

  String _langEmoji(String name) {
    final n = name.toLowerCase();
    if (n.contains('franc') || n.contains('french'))    return '🇫🇷';
    if (n.contains('anglais') || n.contains('english')) return '🇬🇧';
    if (n.contains('espagnol') || n.contains('spanish'))return '🇪🇸';
    if (n.contains('moore') || n.contains('mooré'))     return '🇧🇫';
    if (n.contains('dioula') || n.contains('dyula'))    return '🇧🇫';
    if (n.contains('arabe') || n.contains('arabic'))    return '🇸🇦';
    if (n.contains('allemand') || n.contains('german')) return '🇩🇪';
    return '🌐';
  }

  String _relativeTime(DateTime? dt) {
    if (dt == null) return 'Jamais';
    final d = DateTime.now().difference(dt);
    if (d.inMinutes < 1)  return "À l'instant";
    if (d.inMinutes < 60) return 'Il y a ${d.inMinutes}min';
    if (d.inHours < 24)   return 'Il y a ${d.inHours}h';
    if (d.inDays == 1)    return 'Hier';
    if (d.inDays < 7)     return 'Il y a ${d.inDays}j';
    return 'Il y a ${(d.inDays / 7).floor()}sem';
  }

  // Regroupe les entrées par langue (garde la plus récemment accédée)
  List<UserProgressEntry> _uniqueLanguages(List<UserProgressEntry> all) {
    final map = <String, UserProgressEntry>{};
    for (final e in all) {
      final ex = map[e.language.id];
      if (ex == null) { map[e.language.id] = e; continue; }
      final et = e.language.lastAccessedAt;
      final ext = ex.language.lastAccessedAt;
      if (et != null && (ext == null || et.isAfter(ext))) map[e.language.id] = e;
    }
    final list = map.values.toList()
      ..sort((a, b) {
        final at = a.language.lastAccessedAt;
        final bt = b.language.lastAccessedAt;
        if (at == null && bt == null) return 0;
        if (at == null) return 1;
        if (bt == null) return -1;
        return bt.compareTo(at);
      });
    return list;
  }

  List<_BadgeData> get _badges => [
    _BadgeData('Premiers pas',       '👣', 'Démarrer l\'apprentissage',
        _inProgressModules > 0 || _completedModules > 0),
    _BadgeData('Explorateur',        '🔍', 'Terminer 1 module',      _completedModules >= 1),
    _BadgeData('Persévérant',        '💪', 'Terminer 5 modules',     _completedModules >= 5),
    _BadgeData('Quiz Master',        '🎯', 'Score quiz ≥ 80%',       _quizScore >= 80),
    _BadgeData('1h d\'apprentissage','⏱',  'Passer 1h à apprendre',  _totalMinutes >= 60),
    _BadgeData('XP 1 000',          '⚡',  'Accumuler 1 000 XP',     _totalXp >= 1000),
  ];

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
              color: _kGreen,
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
                              Icons.bar_chart_rounded, _kBlue),
                          const SizedBox(height: 12),
                          _buildModuleProgress(context),
                          const SizedBox(height: 26),
                          _buildSectionTitle(context, 'Mes langues',
                              Icons.language_rounded, _kGreen),
                          const SizedBox(height: 12),
                          _buildLanguageCards(context, _selectedLangId),
                          const SizedBox(height: 26),
                          _buildSectionTitle(context, 'Badges & Récompenses',
                              Icons.military_tech_rounded, _kPurple),
                          const SizedBox(height: 12),
                          _buildBadges(context),
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
          colors: [_kGreen, _kGreenDark],
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '📊 Suivi de progression',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 8),
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
          Lottie.asset('assets/lottie/mascot.json',
              width: 76, height: 76, fit: BoxFit.contain),
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
              colors: [color, _kYellow],
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

  // ── XP Card ────────────────────────────────────────────────────────────────

  Widget _buildXpCard(BuildContext context) {
    final progress = (_currentLevelXp / _targetXp).clamp(0.0, 1.0);
    final pct = (progress * 100).round();
    final remaining = (_targetXp - _currentLevelXp).clamp(0, _targetXp);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _kGreen.withValues(alpha: 0.15), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _kGreen.withValues(alpha: 0.10),
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_kGreen, _kGreenDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: _kGreen.withValues(alpha: 0.30),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('XP du niveau actuel',
                        style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary(context),
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatXp(_currentLevelXp),
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary(context),
                            height: 1.1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 3, left: 4),
                          child: Text(
                            '/ ${_formatXp(_targetXp)} XP',
                            style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary(context),
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_kGreen, Color(0xFF22A63B)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$pct%',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Barre XP animée
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: progress),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (_, value, __) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        Container(
                          height: 12,
                          color: _kGreen.withValues(alpha: 0.10),
                        ),
                        FractionallySizedBox(
                          widthFactor: value,
                          child: Container(
                            height: 12,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [_kGreen, Color(0xFF4ADE80)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.trending_up_rounded,
                              color: _kGreen, size: 14),
                          const SizedBox(width: 5),
                          Text(
                            remaining > 0
                                ? 'Encore $remaining XP pour le prochain niveau'
                                : 'Niveau atteint ! 🎉',
                            style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary(context),
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _kGreen.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${(value * 100).round()}%',
                          style: const TextStyle(
                              color: _kGreen,
                              fontSize: 11,
                              fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Stats Row ──────────────────────────────────────────────────────────────

  Widget _buildStatsRow(BuildContext context) {
    return Row(
      children: [
        _statCard(context, Icons.bolt_rounded, _formatXp(_totalXp),
            'Total XP', _kOrange),
        const SizedBox(width: 12),
        _statCard(context, Icons.timer_rounded, _formatTime(_totalMinutes),
            'Temps total', _kBlue),
        const SizedBox(width: 12),
        _statCard(context, Icons.quiz_rounded, '$_quizScore%',
            'Score quiz', _kGreen),
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
      _ModuleStat('Terminés',      _completedModules,  _kGreen,  Icons.check_circle_rounded),
      _ModuleStat('En cours',      _inProgressModules, _kOrange, Icons.play_circle_rounded),
      _ModuleStat('Verrouillés',   _lockedModules,     _kLocked, Icons.lock_rounded),
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
                '$_totalModules',
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
                  Text('au total',
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
                      value: _totalModules > 0
                          ? _completedModules / _totalModules
                          : 0.0,
                      strokeWidth: 6,
                      backgroundColor: _kLocked.withValues(alpha: 0.20),
                      valueColor: const AlwaysStoppedAnimation(_kGreen),
                    ),
                    Text(
                      '$_completedModules',
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
            final frac = _totalModules > 0
                ? item.count / _totalModules
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
                                '${item.count} / $_totalModules',
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

  // ── Language Cards ─────────────────────────────────────────────────────────

  Widget _buildLanguageCards(BuildContext context, String selectedLangId) {
    return Obx(() {
      if (_progressCtrl.isLoading.value && _progressCtrl.progressList.isEmpty) {
        return _langCardShimmer(context);
      }

      final all = _uniqueLanguages(_progressCtrl.progressList.toList());
      final entries = selectedLangId.isNotEmpty
          ? all.where((e) => e.language.id == selectedLangId).toList()
          : all;

      if (entries.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.card(context),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              'Aucune langue inscrite',
              style: TextStyle(
                  color: AppColors.textSecondary(context), fontSize: 14),
            ),
          ),
        );
      }

      return Column(
        children: entries.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _langCard(context, e),
        )).toList(),
      );
    });
  }

  Widget _langCard(BuildContext context, UserProgressEntry e) {
    final pct    = e.language.progressPercentage.clamp(0, 100).toDouble();
    final emoji  = _langEmoji(e.language.name);
    final done   = e.level.completedModules;
    final total  = e.level.totalModules;
    final lastAt = e.language.lastAccessedAt;

    const List<List<Color>> palette = [
      [Color(0xFF188329), Color(0xFF0F5C1C)],
      [Color(0xFFF27F22), Color(0xFFBF5A0F)],
      [Color(0xFF0EA5E9), Color(0xFF0369A1)],
      [Color(0xFF7C3AED), Color(0xFF5B21B6)],
    ];
    final idx = e.language.name.isNotEmpty
        ? e.language.name.codeUnitAt(0) % palette.length
        : 0;
    final c1 = palette[idx][0];
    final c2 = palette[idx][1];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c1.withValues(alpha: 0.15), width: 1.5),
        boxShadow: [
          BoxShadow(
              color: c1.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          // Avatar emoji
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [c1, c2],
                  begin: Alignment.topLeft, end: Alignment.bottomRight),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: c1.withValues(alpha: 0.28),
                    blurRadius: 10,
                    offset: const Offset(0, 4)),
              ],
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(e.language.name,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary(context))),
                    Text(_relativeTime(lastAt),
                        style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary(context))),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: c1.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(e.level.name,
                          style: TextStyle(
                              fontSize: 10,
                              color: c1,
                              fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      total > 0 ? '$done/$total modules' : 'Aucun module',
                      style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary(context),
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: pct / 100.0),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, __) => ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: v,
                      minHeight: 6,
                      backgroundColor: c1.withValues(alpha: 0.10),
                      valueColor: AlwaysStoppedAnimation<Color>(c1),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${pct.toInt()}% accompli',
                  style: TextStyle(
                      fontSize: 10,
                      color: c1,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _langCardShimmer(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase(context),
      highlightColor: AppColors.shimmerHighlight(context),
      child: Column(
        children: List.generate(2, (_) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            height: 110,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        )),
      ),
    );
  }

  // ── Badges ─────────────────────────────────────────────────────────────────

  Widget _buildBadges(BuildContext context) {
    final badges = _badges;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.68,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: badges.length,
      itemBuilder: (_, i) => _badgeCard(context, badges[i]),
    );
  }

  Widget _badgeCard(BuildContext context, _BadgeData b) {
    return AnimatedOpacity(
      opacity: b.earned ? 1.0 : 0.40,
      duration: const Duration(milliseconds: 400),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: b.earned
              ? _kPurple.withValues(alpha: 0.08)
              : AppColors.cardAlt(context),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: b.earned
                ? _kPurple.withValues(alpha: 0.25)
                : AppColors.border(context),
            width: 1.5,
          ),
          boxShadow: b.earned
              ? [
                  BoxShadow(
                    color: _kPurple.withValues(alpha: 0.10),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Emoji dans cercle
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: b.earned
                    ? _kPurple.withValues(alpha: 0.12)
                    : AppColors.cardAlt(context),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(b.emoji,
                    style: const TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              b.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: b.earned
                    ? AppColors.textPrimary(context)
                    : AppColors.textSecondary(context),
                height: 1.25,
              ),
            ),
            if (b.earned) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: _kPurple,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('✓ Obtenu',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w800)),
              ),
            ],
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
            const SizedBox(height: 24),
            // Language cards
            ...List.generate(2, (_) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                height: 110,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20)),
              ),
            )),
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

class _BadgeData {
  final String label, emoji, desc;
  final bool earned;
  const _BadgeData(this.label, this.emoji, this.desc, this.earned);
}
