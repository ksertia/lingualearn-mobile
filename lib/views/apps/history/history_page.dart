import 'package:fasolingo/helpers/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import 'package:fasolingo/controller/apps/user_progress/user_progress_controller.dart';
import 'package:fasolingo/models/user_progress/user_progress_model.dart';

// ── Palette (matches app-wide design) ────────────────────────────────────────
const Color _kGreen     = Color(0xFF188329);
const Color _kGreenDark = Color(0xFF0F5C1C);
const Color _kYellow    = Color(0xFFF5BF1E);
const Color _kOrange    = Color(0xFFF27F22);
const Color _kBlue      = Color(0xFF0EA5E9);
const Color _kPurple    = Color(0xFF7C3AED);
const Color _kLocked    = Color(0xFFB0BEC5);

// ── Groups all levels for the same language ───────────────────────────────────
class _LangGroup {
  final ProgressLanguageInfo language;
  final List<UserProgressEntry> entries; // one per level

  const _LangGroup({required this.language, required this.entries});

  UserProgressEntry get activeEntry {
    return entries.reduce((a, b) {
      final at = a.language.lastAccessedAt;
      final bt = b.language.lastAccessedAt;
      if (at == null) return b;
      if (bt == null) return a;
      return at.isAfter(bt) ? a : b;
    });
  }

  // Un niveau est terminé si : status 'completed', OU completedModules >= totalModules > 0, OU progressPercentage == 100
  static bool _isLevelDone(ProgressLevelInfo lvl) {
    if (lvl.status.toLowerCase() == 'completed') return true;
    if (lvl.totalModules > 0 && lvl.completedModules >= lvl.totalModules) return true;
    if (lvl.progressPercentage >= 100) return true;
    return false;
  }

  int get completedLevels =>
      entries.where((e) => _isLevelDone(e.level)).length;

  // Total des modules terminés sur TOUS les niveaux de cette langue
  int get totalCompletedModulesAll =>
      entries.fold<int>(0, (sum, e) => sum + e.level.completedModules);

  // Total des modules sur TOUS les niveaux de cette langue
  int get totalModulesAll =>
      entries.fold<int>(0, (sum, e) => sum + e.level.totalModules);

  List<UserProgressEntry> get sortedLevels {
    final copy = entries.toList();
    copy.sort((a, b) {
      final ad = _isLevelDone(a.level) ? 0 : (a.level.status.toLowerCase() == 'locked' ? 2 : 1);
      final bd = _isLevelDone(b.level) ? 0 : (b.level.status.toLowerCase() == 'locked' ? 2 : 1);
      return ad.compareTo(bd);
    });
    return copy;
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late final UserProgressController controller;
  late BuildContext _ctx;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<UserProgressController>()
        ? Get.find<UserProgressController>()
        : Get.put(UserProgressController());
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _relativeTime(DateTime? dt) {
    if (dt == null) return 'Jamais';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return "À l'instant";
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes}min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
    if (diff.inDays == 1) return 'Hier';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays}j';
    if (diff.inDays < 30) return 'Il y a ${(diff.inDays / 7).floor()}sem';
    return 'Il y a ${(diff.inDays / 30).floor()}mois';
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed': return _kGreen;
      case 'started':
      case 'unlocked':
      case 'in_progress': return _kOrange;
      default: return _kLocked;
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'completed': return 'Terminé';
      case 'started': return 'En cours';
      case 'unlocked': return 'Débloqué';
      case 'in_progress': return 'En cours';
      default: return 'Verrouillé';
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed': return Icons.check_circle_rounded;
      case 'started':
      case 'unlocked':
      case 'in_progress': return Icons.play_circle_rounded;
      default: return Icons.lock_rounded;
    }
  }

  String _stepTypeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'quiz': return 'Quiz';
      case 'lesson': return 'Leçon';
      case 'audio': return 'Audio';
      case 'video': return 'Vidéo';
      default: return type;
    }
  }

  IconData _stepTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'quiz': return Icons.quiz_rounded;
      case 'lesson': return Icons.menu_book_rounded;
      case 'audio': return Icons.headphones_rounded;
      case 'video': return Icons.play_circle_outline_rounded;
      default: return Icons.star_rounded;
    }
  }

  String _langEmoji(String name) {
    final n = name.toLowerCase();
  
    if (n.contains('moore') || n.contains('mooré') || n.contains('more')) return '🇧🇫';
    if (n.contains('dioula') || n.contains('dyula')) return '🇧🇫';
    if (n.contains('bissa') || n.contains('bisa')) return '🇧🇫';
    return '🌐';
  }

  // Group entries by language.id, sorted by most recently accessed
  List<_LangGroup> _groupByLanguage(List<UserProgressEntry> entries) {
    final map = <String, List<UserProgressEntry>>{};
    for (final e in entries) {
      map.putIfAbsent(e.language.id, () => []).add(e);
    }
    final groups = map.entries.map((kv) {
      return _LangGroup(language: kv.value.first.language, entries: kv.value);
    }).toList();

    groups.sort((a, b) {
      final at = a.language.lastAccessedAt;
      final bt = b.language.lastAccessedAt;
      if (at == null && bt == null) return 0;
      if (at == null) return 1;
      if (bt == null) return -1;
      return bt.compareTo(at);
    });
    return groups;
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    _ctx = context;
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: Obx(() {
        if (controller.isLoading.value && controller.progressList.isEmpty) {
          return _buildShimmer();
        }
        if (controller.hasError.value && controller.progressList.isEmpty) {
          return _buildErrorState();
        }

        final groups = _groupByLanguage(controller.progressList.toList());

        if (groups.isEmpty) return _buildEmptyState();

        final totalLangs = groups.length;
        final totalCompletedModules =
            groups.fold<int>(0, (sum, g) => sum + g.totalCompletedModulesAll);
        final avgPct = groups.isEmpty
            ? 0
            : groups.map((g) => g.language.progressPercentage).fold(0, (a, b) => a + b) ~/
                groups.length;
        final totalCompletedLevels =
            groups.fold<int>(0, (sum, g) => sum + g.completedLevels);

        return RefreshIndicator(
          color: _kGreen,
          onRefresh: controller.loadProgress,
          child: CustomScrollView(
            slivers: [
              // ── Header banner ──
              SliverToBoxAdapter(child: _buildHeader(totalLangs, avgPct)),

              // ── Summary stats ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: _buildSummaryCard(
                      totalLangs, totalCompletedModules, avgPct, totalCompletedLevels),
                ),
              ),

              // ── Section title ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: _kGreen.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.history_rounded, color: _kGreen, size: 16),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Mes apprentissages',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary(_ctx)),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _kGreen.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$totalLangs langue${totalLangs > 1 ? 's' : ''}',
                          style: const TextStyle(
                              fontSize: 12, color: _kGreen, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Language cards ──
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildLanguageCard(groups[i]),
                    ),
                    childCount: groups.length,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // ── Header banner (compact green, same as other pages) ────────────────────

  Widget _buildHeader(int totalLangs, int avgPct) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.97),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
              color: _kGreen.withValues(alpha: 0.18),
              blurRadius: 24,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Container(
        padding: EdgeInsets.fromLTRB(
          16,
          MediaQuery.of(context).padding.top + 14,
          16,
          14,
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
                    child: Text(
                      '📚 $totalLangs langue${totalLangs > 1 ? 's' : ''}',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Mon Historique',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Retracez votre parcours d\'apprentissage',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75), fontSize: 12),
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
                border:
                    Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1),
              ),
              child: Lottie.asset('assets/lottie/mascot.json',
                  fit: BoxFit.contain, repeat: true),
            ),
          ],
        ),
      ),
    );
  }

  // ── Summary stats card ────────────────────────────────────────────────────

  Widget _buildSummaryCard(
      int langs, int completedMods, int avgPct, int completedLevels) {
    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 4),
      decoration: BoxDecoration(
        color: AppColors.card(_ctx),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
              color: _kGreen.withValues(alpha: 0.13),
              blurRadius: 16,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          _buildSummaryPill(
              Icons.language_rounded, '$langs', 'Langue${langs > 1 ? 's' : ''}', _kBlue),
          _buildSummaryDivider(),
          _buildSummaryPill(
              Icons.check_circle_rounded, '$completedMods', 'Modules', _kGreen),
          _buildSummaryDivider(),
          _buildSummaryPill(
              Icons.military_tech_rounded, '$completedLevels', 'Niveaux', _kOrange),
          _buildSummaryDivider(),
          _buildSummaryPill(
              Icons.trending_up_rounded, '$avgPct%', 'Progression', _kPurple),
        ],
      ),
    );
  }

  Widget _buildSummaryPill(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(height: 5),
            Text(value,
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 1),
            Text(label,
                style: TextStyle(
                    fontSize: 9,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryDivider() =>
      Container(height: 48, width: 1, color: AppColors.divider(_ctx));

  // ── Language card ──────────────────────────────────────────────────────────

  Widget _buildLanguageCard(_LangGroup group) {
    final lang = group.language;
    final entry = group.activeEntry;
    final lvl = entry.level;
    final module = entry.module;
    final path = entry.path;
    final step = entry.step;

    final statusColor = _statusColor(lang.status);
    final pct = lang.progressPercentage.clamp(0, 100).toDouble();

    final List<Color> stripeColors = lang.status.toLowerCase() == 'completed'
        ? [_kGreen, _kYellow]
        : (lang.status.toLowerCase() == 'locked'
            ? [_kLocked, const Color(0xFFCFD8DC)]
            : [_kOrange, _kYellow]);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card(_ctx),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: statusColor.withValues(alpha: 0.14), width: 1.5),
        boxShadow: [
          BoxShadow(
              color: statusColor.withValues(alpha: 0.11),
              blurRadius: 16,
              offset: const Offset(0, 6)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(23),
        child: Stack(
          children: [
            // Left stripe — positioned, s'adapte à la hauteur du contenu
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
            // Card content — décalé de 6px pour laisser place à la bande
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Language header row
                      Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  statusColor,
                                  statusColor.withValues(alpha: 0.65)
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: statusColor.withValues(alpha: 0.28),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(_langEmoji(lang.name),
                                  style: const TextStyle(fontSize: 24)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lang.name,
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary(_ctx)),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    _buildBadge(lang.code.toUpperCase(),
                                        Colors.grey.shade200, Colors.grey.shade600),
                                    const SizedBox(width: 6),
                                    _buildBadge(
                                        _statusLabel(lang.status),
                                        statusColor.withValues(alpha: 0.12),
                                        statusColor),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildProgressRing(pct, statusColor),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Progress bar + time
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: pct / 100,
                                minHeight: 7,
                                backgroundColor: statusColor.withValues(alpha: 0.08),
                                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _relativeTime(lang.lastAccessedAt),
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade400,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      Row(
                        children: [
                          Icon(Icons.grid_view_rounded,
                              size: 13, color: Colors.grey.shade400),
                          const SizedBox(width: 4),
                          Text(
                            '${group.totalCompletedModulesAll} / ${group.totalModulesAll > 0 ? group.totalModulesAll : lvl.totalModules} modules terminés',
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),

                      // ── Niveaux ────────────────────────────────────────────
                      const SizedBox(height: 14),
                      _buildLevelsSection(group),

                      // ── Activité en cours ──────────────────────────────────
                      if (module != null || path != null || step != null) ...[
                        const SizedBox(height: 14),
                        _buildCurrentActivity(module, path, step),
                      ],

                      // ── Mini stats ─────────────────────────────────────────
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          _buildMiniStat(Icons.check_rounded, _kGreen,
                              '${group.totalCompletedModulesAll}', 'Modules'),
                          const SizedBox(width: 8),
                          _buildMiniStat(Icons.military_tech_rounded, _kOrange,
                              '${group.completedLevels}', 'Niveaux ✓'),
                          const SizedBox(width: 8),
                          _buildMiniStat(_statusIcon(lang.status), statusColor,
                              _statusLabel(lang.status), 'Statut'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
    );
  }

  // ── Niveaux section ──────────────────────────────────────────────────────

  Widget _buildLevelsSection(_LangGroup group) {
    final levels = group.sortedLevels;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.layers_rounded, size: 13, color: AppColors.textPrimary(_ctx)),
            const SizedBox(width: 5),
            Text(
              'Niveaux',
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textPrimary(_ctx)),
            ),
            const SizedBox(width: 6),
            if (group.completedLevels > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [_kGreen, Color(0xFF22A63B)]),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_rounded, color: Colors.white, size: 9),
                    const SizedBox(width: 3),
                    Text(
                      '${group.completedLevels} terminé${group.completedLevels > 1 ? 's' : ''}',
                      style: const TextStyle(
                          fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: _kLocked.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Aucun terminé',
                  style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w600),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: levels.map((e) {
              final isCompleted = _LangGroup._isLevelDone(e.level);
              final isActive = !isCompleted &&
                  (e.level.status.toLowerCase() == 'in_progress' ||
                      e.level.status.toLowerCase() == 'started' ||
                      e.level.status.toLowerCase() == 'unlocked');
              final lc = isCompleted ? _kGreen : _statusColor(e.level.status);

              return Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  gradient: isCompleted
                      ? const LinearGradient(colors: [_kGreen, Color(0xFF22A63B)])
                      : null,
                  color: isCompleted ? null : lc.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isCompleted
                        ? Colors.transparent
                        : lc.withValues(alpha: 0.25),
                  ),
                  boxShadow: isCompleted
                      ? [
                          BoxShadow(
                            color: _kGreen.withValues(alpha: 0.22),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isCompleted
                          ? Icons.check_circle_rounded
                          : _statusIcon(e.level.status),
                      color: isCompleted ? Colors.white : lc,
                      size: 13,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      e.level.name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isCompleted ? Colors.white : lc,
                      ),
                    ),
                    if (isActive) ...[
                      const SizedBox(width: 4),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _kOrange,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ── Current activity ──────────────────────────────────────────────────────

  Widget _buildCurrentActivity(
      ProgressModuleInfo? module, ProgressPathInfo? path, ProgressStepInfo? step) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardAlt(_ctx),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kGreen.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.my_location_rounded, size: 13, color: _kGreen),
              const SizedBox(width: 5),
              Text(
                'Activité en cours',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _kGreen,
                    letterSpacing: 0.4),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (module != null)
            _buildActivityRow(Icons.view_module_rounded, _kOrange, 'Module',
                module.title, '${module.completedPaths}/${module.totalPaths} parcours',
                module.status),
          if (path != null) ...[
            if (module != null) const SizedBox(height: 8),
            _buildActivityRow(Icons.route_rounded, _kBlue, 'Parcours', path.title,
                '${path.completedSteps}/${path.totalSteps} étapes', path.status),
          ],
          if (step != null) ...[
            if (path != null || module != null) const SizedBox(height: 8),
            _buildActivityRow(
              _stepTypeIcon(step.stepType),
              _kPurple,
              _stepTypeLabel(step.stepType),
              step.title,
              step.score != null ? 'Score: ${step.score}%' : _statusLabel(step.status),
              step.status,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActivityRow(IconData icon, Color color, String type, String title,
      String sub, String status) {
    final sc = _statusColor(status);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 14),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildBadgeSmall(type, color.withValues(alpha: 0.10), color),
                  const SizedBox(width: 6),
                  _buildBadgeSmall(_statusLabel(status), sc.withValues(alpha: 0.10), sc,
                      icon: _statusIcon(status)),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(_ctx)),
              ),
              const SizedBox(height: 2),
              Text(sub,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
            ],
          ),
        ),
      ],
    );
  }

  // ── Mini stats ─────────────────────────────────────────────────────────────

  Widget _buildMiniStat(IconData icon, Color color, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 15),
            const SizedBox(height: 3),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w800, color: color),
            ),
            const SizedBox(height: 1),
            Text(
              label,
              style: TextStyle(
                  fontSize: 9,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  // ── Small widget helpers ───────────────────────────────────────────────────

  Widget _buildBadge(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(7)),
      child:
          Text(text, style: TextStyle(fontSize: 10, color: fg, fontWeight: FontWeight.w700)),
    );
  }

  Widget _buildBadgeSmall(String text, Color bg, Color fg, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(5)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 9, color: fg),
            const SizedBox(width: 3),
          ],
          Text(text,
              style:
                  TextStyle(fontSize: 10, color: fg, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildProgressRing(double pct, Color color) {
    return SizedBox(
      width: 52,
      height: 52,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: (pct / 100).clamp(0.0, 1.0),
            strokeWidth: 5.5,
            backgroundColor: color.withValues(alpha: 0.10),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          Text(
            '${pct.round()}%',
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w800, color: color),
          ),
        ],
      ),
    );
  }

  // ── Empty / Error / Shimmer states ────────────────────────────────────────

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase(_ctx),
      highlightColor: AppColors.shimmerHighlight(_ctx),
      child: ListView(
        padding: EdgeInsets.fromLTRB(
            16, MediaQuery.of(context).padding.top + kToolbarHeight + 16, 16, 20),
        children: [
          // Header placeholder
          Container(
            height: 160,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(28)),
          ),
          // Summary placeholder
          Container(
            height: 90,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(22)),
          ),
          // Cards
          ...List.generate(
            3,
            (_) => Container(
              height: 220,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(24)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        _buildHeader(0, 0),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset('assets/lottie/mascot.json',
                      width: 150, height: 150),
                  const SizedBox(height: 20),
                  Text(
                    'Pas encore d\'historique',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary(_ctx)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Commencez votre premier module pour voir votre parcours s\'écrire ici.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 14, color: Colors.grey.shade500, height: 1.5),
                  ),
                  const SizedBox(height: 28),
                  GestureDetector(
                    onTap: controller.loadProgress,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [_kGreen, _kGreenDark]),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                              color: _kGreen.withValues(alpha: 0.30),
                              blurRadius: 10,
                              offset: const Offset(0, 4)),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Text('Actualiser',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Column(
      children: [
        _buildHeader(0, 0),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.wifi_off_rounded,
                        color: Colors.red.shade400, size: 40),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Impossible de charger',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary(_ctx)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Vérifiez votre connexion et réessayez.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 14, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: controller.loadProgress,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [_kGreen, _kGreenDark]),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                              color: _kGreen.withValues(alpha: 0.30),
                              blurRadius: 10,
                              offset: const Offset(0, 4)),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Text('Réessayer',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
