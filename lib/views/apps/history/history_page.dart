import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import 'package:fasolingo/controller/apps/user_progress/user_progress_controller.dart';
import 'package:fasolingo/models/user_progress/user_progress_model.dart';

const Color _hOrange  = Color(0xFFFF7043);
const Color _hOrange2 = Color(0xFFFFB74D);
const Color _hGreen   = Color(0xFF22C55E);
const Color _hBlue    = Color(0xFF0EA5E9);
const Color _hLocked  = Color(0xFF9E9E9E);
const Color _hPurple  = Color(0xFF7C3AED);

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late final UserProgressController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<UserProgressController>()
        ? Get.find<UserProgressController>()
        : Get.put(UserProgressController());
  }

  String _relativeTime(DateTime? dt) {
    if (dt == null) return 'Jamais';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return "A l'instant";
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes}min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
    if (diff.inDays == 1) return 'Hier';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays}j';
    if (diff.inDays < 30) return 'Il y a ${(diff.inDays / 7).floor()}sem';
    return 'Il y a ${(diff.inDays / 30).floor()}mois';
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed': return _hGreen;
      case 'started':
      case 'unlocked':
      case 'in_progress': return _hOrange;
      default: return _hLocked;
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'completed': return 'Termine';
      case 'started': return 'En cours';
      case 'unlocked': return 'Debloque';
      case 'in_progress': return 'En cours';
      default: return 'Verrouille';
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
      case 'lesson': return 'Lecon';
      case 'audio': return 'Audio';
      case 'video': return 'Video';
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

  // Sort entries: most recently accessed first
  List<UserProgressEntry> _sorted(List<UserProgressEntry> list) {
    final copy = list.toList();
    copy.sort((a, b) {
      final at = a.language.lastAccessedAt;
      final bt = b.language.lastAccessedAt;
      if (at == null && bt == null) return 0;
      if (at == null) return 1;
      if (bt == null) return -1;
      return bt.compareTo(at);
    });
    return copy;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      body: Obx(() {
        if (controller.isLoading.value && controller.progressList.isEmpty) {
          return _shimmerList();
        }

        if (controller.hasError.value && controller.progressList.isEmpty) {
          return _errorState();
        }

        final entries = _sorted(controller.progressList.toList());

        if (entries.isEmpty) {
          return _emptyState();
        }

        // Aggregate summary
        final totalLangs = entries.length;
        final totalCompletedModules = entries
            .map((e) => e.level.completedModules)
            .fold(0, (a, b) => a + b);
        final totalModules = entries
            .map((e) => e.level.totalModules)
            .fold(0, (a, b) => a + b);

        return RefreshIndicator(
          color: _hOrange,
          onRefresh: controller.loadProgress,
          child: CustomScrollView(
            slivers: [
              // ---- STICKY HEADER ----
              SliverToBoxAdapter(child: _buildPageHeader()),

              // ---- SUMMARY BANNER ----
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: _buildSummaryCard(totalLangs, totalCompletedModules, totalModules, entries),
                ),
              ),

              // ---- SECTION TITLE ----
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: _hOrange.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.history_rounded, color: _hOrange, size: 16),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Mes apprentissages',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A)),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _hOrange.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$totalLangs langue${totalLangs > 1 ? 's' : ''}',
                          style: const TextStyle(fontSize: 12, color: _hOrange, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ---- ENTRIES ----
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildLanguageCard(entries[i]),
                    ),
                    childCount: entries.length,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // ─────────────────────────────────────────────────
  //  PAGE HEADER (no AppBar – this is a tab page)
  // ─────────────────────────────────────────────────
  Widget _buildPageHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 20,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_hOrange, _hOrange2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Mon Historique',
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 4),
                Text(
                  'Retracez votre parcours d\'apprentissage',
                  style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.auto_stories_rounded, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────
  //  SUMMARY BANNER
  // ─────────────────────────────────────────────────
  Widget _buildSummaryCard(int langs, int completedMods, int totalMods, List<UserProgressEntry> entries) {
    final avgPct = entries.isEmpty
        ? 0
        : entries.map((e) => e.language.progressPercentage).fold(0, (a, b) => a + b) ~/ entries.length;

    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 4),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _hOrange.withValues(alpha: 0.12), width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 5)),
        ],
      ),
      child: Row(
        children: [
          _summaryChip(Icons.language_rounded, '$langs', 'Langue${langs > 1 ? 's' : ''}', _hBlue),
          _summaryDivider(),
          _summaryChip(Icons.check_circle_rounded, '$completedMods', 'Modules', _hGreen),
          _summaryDivider(),
          _summaryChip(Icons.trending_up_rounded, '$avgPct%', 'Moy.', _hPurple),
        ],
      ),
    );
  }

  Widget _summaryChip(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.10), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _summaryDivider() {
    return Container(height: 50, width: 1, color: Colors.grey.shade200);
  }

  // ─────────────────────────────────────────────────
  //  LANGUAGE CARD
  // ─────────────────────────────────────────────────
  Widget _buildLanguageCard(UserProgressEntry entry) {
    final lang   = entry.language;
    final lvl    = entry.level;
    final module = entry.module;
    final path   = entry.path;
    final step   = entry.step;

    final statusColor = _statusColor(lang.status);
    final pct = lang.progressPercentage.clamp(0, 100);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: statusColor.withValues(alpha: 0.18), width: 1.5),
        boxShadow: [
          BoxShadow(color: statusColor.withValues(alpha: 0.10), blurRadius: 14, offset: const Offset(0, 6)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(21),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top strip
            Container(height: 4, color: statusColor),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---- Language header row ----
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            _langEmoji(lang.name),
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lang.name,
                              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A)),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                _badge(lang.code.toUpperCase(), Colors.grey.shade200, Colors.grey.shade600),
                                const SizedBox(width: 6),
                                _badge(lvl.name, statusColor.withValues(alpha: 0.12), statusColor),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Progress ring
                      _progressRing(pct.toDouble(), statusColor),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // ---- Progress bar ----
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: pct / 100,
                            minHeight: 7,
                            backgroundColor: Colors.grey.shade100,
                            valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _relativeTime(lang.lastAccessedAt),
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Modules count
                  Row(
                    children: [
                      Icon(Icons.grid_view_rounded, size: 13, color: Colors.grey.shade400),
                      const SizedBox(width: 4),
                      Text(
                        '${lvl.completedModules} / ${lvl.totalModules} modules termines',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),

                  // ---- Current activity ----
                  if (module != null || path != null || step != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6F7F9),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.my_location_rounded, size: 13, color: _hOrange),
                              const SizedBox(width: 5),
                              Text(
                                'En ce moment',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: _hOrange,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          if (module != null)
                            _activityRow(
                              Icons.view_module_rounded,
                              _hOrange,
                              'Module',
                              module.title,
                              '${module.completedPaths}/${module.totalPaths} parcours',
                              module.status,
                            ),
                          if (path != null) ...[
                            if (module != null) const SizedBox(height: 8),
                            _activityRow(
                              Icons.route_rounded,
                              _hBlue,
                              'Parcours',
                              path.title,
                              '${path.completedSteps}/${path.totalSteps} etapes',
                              path.status,
                            ),
                          ],
                          if (step != null) ...[
                            if (path != null || module != null) const SizedBox(height: 8),
                            _activityRow(
                              _stepTypeIcon(step.stepType),
                              _hPurple,
                              _stepTypeLabel(step.stepType),
                              step.title,
                              step.score != null ? 'Score: ${step.score}%' : _statusLabel(step.status),
                              step.status,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],

                  // ---- Level stats row ----
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _miniStat(Icons.check_rounded, _hGreen, '${lvl.completedModules}', 'Termines'),
                      const SizedBox(width: 8),
                      _miniStat(Icons.layers_rounded, _hBlue, lvl.name, 'Niveau'),
                      const SizedBox(width: 8),
                      _miniStat(_statusIcon(lang.status), statusColor, _statusLabel(lang.status), 'Statut'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _activityRow(IconData icon, Color color, String type, String title, String sub, String status) {
    final sc = _statusColor(status);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 14),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(type, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: sc.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_statusIcon(status), size: 9, color: sc),
                        const SizedBox(width: 3),
                        Text(_statusLabel(status), style: TextStyle(fontSize: 10, color: sc, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A)),
              ),
              const SizedBox(height: 2),
              Text(sub, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _miniStat(IconData icon, Color color, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: color),
            ),
            const SizedBox(height: 1),
            Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _badge(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(7)),
      child: Text(text, style: TextStyle(fontSize: 10, color: fg, fontWeight: FontWeight.w700)),
    );
  }

  Widget _progressRing(double pct, Color color) {
    return SizedBox(
      width: 52,
      height: 52,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: (pct / 100).clamp(0.0, 1.0),
            strokeWidth: 6,
            backgroundColor: color.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          Text(
            '${pct.round()}%',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: color),
          ),
        ],
      ),
    );
  }

  String _langEmoji(String name) {
    final n = name.toLowerCase();
    if (n.contains('francais') || n.contains('french')) return '';
    if (n.contains('anglais') || n.contains('english')) return '';
    if (n.contains('espagnol') || n.contains('spanish')) return '';
    if (n.contains('moore') || n.contains('more')) return '';
    if (n.contains('dioula') || n.contains('dyula')) return '';
    if (n.contains('bissa') || n.contains('bisa')) return '';
    if (n.contains('arabe') || n.contains('arabic')) return '';
    if (n.contains('allemand') || n.contains('german')) return '';
    return '';
  }

  // ─────────────────────────────────────────────────
  //  STATES
  // ─────────────────────────────────────────────────
  Widget _shimmerList() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 80, 16, 20),
        children: List.generate(
          4,
          (_) => Container(
            height: 220,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Column(
      children: [
        _buildPageHeader(),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset('assets/lottie/mascot.json', width: 160, height: 160),
                  const SizedBox(height: 20),
                  const Text(
                    'Pas encore d\'historique',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Commencez votre premier module pour voir votre parcours s\'ecrire ici.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500, height: 1.5),
                  ),
                  const SizedBox(height: 28),
                  GestureDetector(
                    onTap: controller.loadProgress,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [_hOrange, _hOrange2]),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(color: _hOrange.withValues(alpha: 0.30), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Text('Actualiser', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
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

  Widget _errorState() {
    return Column(
      children: [
        _buildPageHeader(),
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
                    child: Icon(Icons.wifi_off_rounded, color: Colors.red.shade400, size: 40),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Impossible de charger',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Verifiez votre connexion et reessayez.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: controller.loadProgress,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [_hOrange, _hOrange2]),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(color: _hOrange.withValues(alpha: 0.30), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Text('Reessayer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
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
