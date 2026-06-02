import 'package:fasolingo/controller/apps/settings/child_progress_controller.dart';
import 'package:fasolingo/helpers/theme/app_colors.dart';
import 'package:fasolingo/models/child_model.dart';
import 'package:fasolingo/models/child_progress_models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:lottie/lottie.dart';

const Color _kGreen     = Color(0xFF188329);
const Color _kGreenDark = Color(0xFF0F5C1C);
const Color _kYellow    = Color(0xFFF5BF1E);
const Color _kOrange    = Color(0xFFF27F22);

class ChildProgressDetailPage extends StatefulWidget {
  final ChildModel child;
  const ChildProgressDetailPage({super.key, required this.child});

  @override
  State<ChildProgressDetailPage> createState() => _ChildProgressDetailPageState();
}

class _ChildProgressDetailPageState extends State<ChildProgressDetailPage>
    with TickerProviderStateMixin {
  final ChildProgressController controller = Get.put(ChildProgressController());
  late BuildContext _ctx;

  static const List<String> _animalLotties = [
    'dino.json', 'elephant.json', 'cat.json',
    'Dog.json',  'Lion.json',     'Chicken.json', 'poulet.json',
  ];

  @override
  void initState() {
    super.initState();
    controller.fetchProgress(widget.child.id);
  }

  String _formatRelativeTime(String? dateStr) {
    if (dateStr == null) return 'Jamais';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return dateStr;
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return 'Il y a ${diff.inDays}j';
    if (diff.inHours > 0) return 'Il y a ${diff.inHours}h';
    return 'Récemment';
  }

  String _mostRecentActivity(List<ChildProgressItemModel> items) {
    DateTime? latest;
    for (final item in items) {
      final d = DateTime.tryParse(item.language?.lastAccessedAt ?? '');
      if (d != null && (latest == null || d.isAfter(latest))) latest = d;
    }
    if (latest == null) return 'Jamais';
    final diff = DateTime.now().difference(latest);
    if (diff.inDays > 0) return 'Il y a ${diff.inDays}j';
    if (diff.inHours > 0) return 'Il y a ${diff.inHours}h';
    return 'Récemment';
  }

  String? _extractName(dynamic field) {
    if (field == null) return null;
    if (field is Map) return field['name']?.toString();
    return null;
  }

  String _langEmoji(String? name) {
    if (name == null) return '🌐';
    final n = name.toLowerCase();
    if (n.contains('francais') || n.contains('french'))  return '🇫🇷';
    if (n.contains('english') || n.contains('anglais'))  return '🇬🇧';
    if (n.contains('espagnol') || n.contains('spanish')) return '🇪🇸';
    if (n.contains('moore') || n.contains('moré'))       return '🇧🇫';
    if (n.contains('dioula') || n.contains('dyula'))     return '🇧🇫';
    if (n.contains('allemand') || n.contains('german'))  return '🇩🇪';
    if (n.contains('arabe') || n.contains('arabic'))     return '🇸🇦';
    return '🌐';
  }

  int _compareLastAccessed(ChildProgressItemModel a, ChildProgressItemModel b) {
    final ad = DateTime.tryParse(a.language?.lastAccessedAt ?? '');
    final bd = DateTime.tryParse(b.language?.lastAccessedAt ?? '');
    if (ad == null && bd == null) return 0;
    if (ad == null) return 1;
    if (bd == null) return -1;
    return bd.compareTo(ad);
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final name   = widget.child.displayName;

    _ctx = context;
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: Column(
        children: [
          _buildHeader(topPad, name),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.progress.value == null) {
                return _shimmerList();
              }

              final res   = controller.progress.value;
              final items = (res?.data ?? <ChildProgressItemModel>[]).toList();
              items.sort(_compareLastAccessed);

              if (items.isEmpty) return _emptyState(name);

              final totalCompleted = items.fold<int>(0, (s, i) => s + (i.level?.completedModules ?? 0));
              final totalModules   = items.fold<int>(0, (s, i) => s + (i.level?.totalModules ?? 0));
              final avgProgress    = items
                  .map((i) => i.level?.progressPercentage ?? 0.0)
                  .reduce((a, b) => a + b) / items.length;
              final bestItem = items.reduce((a, b) =>
                  (a.level?.progressPercentage ?? 0) >= (b.level?.progressPercentage ?? 0) ? a : b);

              return RefreshIndicator(
                color: _kGreen,
                onRefresh: () => controller.fetchProgress(widget.child.id),
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: _buildOverviewPanel(
                          items: items,
                          avgProgress: avgProgress,
                          totalCompleted: totalCompleted,
                          totalModules: totalModules,
                          bestItem: bestItem,
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                        child: Row(
                          children: [
                            Container(
                              width: 3, height: 16,
                              decoration: BoxDecoration(
                                color: _kOrange, borderRadius: BorderRadius.circular(2)),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'LANGUES SUIVIES',
                              style: TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w800,
                                color: _kOrange, letterSpacing: 0.9,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${items.length} langue${items.length > 1 ? 's' : ''}',
                              style: const TextStyle(
                                  fontSize: 12, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _languageCard(items[index]),
                          childCount: items.length,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(double topPad, String name) {
    final int idx    = name.hashCode.abs() % _animalLotties.length;
    final String animal = _animalLotties[idx];

    return Container(
      padding: EdgeInsets.fromLTRB(16, topPad + 16, 0, 0),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_kGreen, _kGreenDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(right: 90, top: 0,
            child: Container(width: 60, height: 60,
              decoration: BoxDecoration(shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06)))),
          Positioned(right: 130, bottom: 20,
            child: Container(width: 30, height: 30,
              decoration: BoxDecoration(shape: BoxShape.circle,
                color: _kYellow.withValues(alpha: 0.20)))),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 17),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.w800, fontSize: 21)),
                            const Text(
                              'Progression de l\'apprenant',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 90,
                child: Lottie.asset('assets/lottie/$animal', height: 88, fit: BoxFit.contain),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Overview Panel ────────────────────────────────────────────────────────

  Widget _buildOverviewPanel({
    required List<ChildProgressItemModel> items,
    required double avgProgress,
    required int totalCompleted,
    required int totalModules,
    required ChildProgressItemModel bestItem,
  }) {
    final lastActivity = _mostRecentActivity(items);
    final bestLangName = bestItem.language?.name ?? '-';
    final bestLangPct  = (bestItem.level?.progressPercentage ?? 0.0).round();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card(_ctx),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
              color: _kGreen.withValues(alpha: 0.10),
              blurRadius: 20,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Anneau de progression globale
          _buildRingProgress(avgProgress),
          const SizedBox(width: 20),
          // Colonne de stats
          Expanded(
            child: Column(
              children: [
                _overviewRow(
                  icon: Icons.school_rounded,
                  iconColor: _kOrange,
                  label: 'Modules terminés',
                  value: '$totalCompleted / $totalModules',
                  valueColor: _kOrange,
                ),
                const SizedBox(height: 12),
                _overviewRow(
                  icon: Icons.access_time_rounded,
                  iconColor: _kGreen,
                  label: 'Dernière activité',
                  value: lastActivity,
                  valueColor: _kGreen,
                ),
                const SizedBox(height: 12),
                _overviewRow(
                  icon: Icons.emoji_events_rounded,
                  iconColor: _kYellow,
                  label: 'Meilleure langue',
                  value: '$bestLangName  $bestLangPct%',
                  valueColor: const Color(0xFF1A1A1A),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRingProgress(double avgProgress) {
    return SizedBox(
      width: 88, height: 88,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 88, height: 88,
            child: CircularProgressIndicator(
              value: avgProgress / 100,
              backgroundColor: _kGreen.withValues(alpha: 0.10),
              valueColor: const AlwaysStoppedAnimation<Color>(_kGreen),
              strokeWidth: 8,
              strokeCap: StrokeCap.round,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${avgProgress.round()}%',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w900, color: _kGreen),
              ),
              const Text(
                'moy.',
                style: TextStyle(
                    fontSize: 9, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _overviewRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Row(
      children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 14),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                style: const TextStyle(
                    fontSize: 10, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w500)),
              Text(value,
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700, color: valueColor)),
            ],
          ),
        ),
      ],
    );
  }

  // ── Language Card ─────────────────────────────────────────────────────────

  Widget _languageCard(ChildProgressItemModel it) {
    final lang = it.language;
    final lvl  = it.level;

    final languageName   = lang?.name ?? '-';
    final lastAccessed   = _formatRelativeTime(lang?.lastAccessedAt);
    final levelName      = lvl?.name ?? '-';
    final totalMods      = lvl?.totalModules ?? 0;
    final completedMods  = lvl?.completedModules ?? 0;
    final langPercent    = (lang?.progressPercentage ?? 0.0).clamp(0.0, 100.0);
    final lvlPercent     = (lvl?.progressPercentage ?? 0.0).clamp(0.0, 100.0);
    final moduleName     = _extractName(it.module) ?? _extractName(it.path);
    final emoji          = _langEmoji(lang?.name);

    // Badge état
    final String stateLabel;
    final Color  stateColor;
    if (lvlPercent >= 100) {
      stateLabel = 'Terminé';
      stateColor = _kGreen;
    } else if (lvlPercent > 0) {
      stateLabel = 'En cours';
      stateColor = _kOrange;
    } else {
      stateLabel = 'Débutant';
      stateColor = const Color(0xFF9CA3AF);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.card(_ctx),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 14,
              offset: const Offset(0, 5)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            // Barre dégradée en haut
            Container(
              height: 4,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_kGreen, _kYellow, _kOrange],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── En-tête langue ────────────────────────────────────
                  Row(
                    children: [
                      Container(
                        width: 52, height: 52,
                        decoration: BoxDecoration(
                          color: _kGreen.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: _kGreen.withValues(alpha: 0.12)),
                        ),
                        alignment: Alignment.center,
                        child: Text(emoji, style: const TextStyle(fontSize: 26)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(languageName,
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary(_ctx))),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                _badge(
                                  icon: Icons.access_time_rounded,
                                  label: lastAccessed,
                                  color: _kOrange,
                                ),
                                const SizedBox(width: 6),
                                _badgeDot(stateLabel, stateColor),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Mini anneau par carte
                      SizedBox(
                        width: 46, height: 46,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 46, height: 46,
                              child: CircularProgressIndicator(
                                value: lvlPercent / 100,
                                backgroundColor: _kGreen.withValues(alpha: 0.10),
                                valueColor: const AlwaysStoppedAnimation<Color>(_kGreen),
                                strokeWidth: 4.5,
                                strokeCap: StrokeCap.round,
                              ),
                            ),
                            Text('${lvlPercent.round()}%',
                              style: const TextStyle(
                                  fontSize: 10, fontWeight: FontWeight.w800, color: _kGreen)),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),
                  Container(height: 1, color: const Color(0xFFF0F0F0)),
                  const SizedBox(height: 14),

                  // ── Barres de progression ─────────────────────────────
                  _progressBar('Progression langue', langPercent, _kGreen),
                  const SizedBox(height: 10),
                  _progressBar('Progression niveau', lvlPercent, _kYellow),

                  const SizedBox(height: 14),

                  // ── Niveau + modules ──────────────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F7F4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _kGreen.withValues(alpha: 0.12)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.school_rounded, size: 18, color: _kGreen),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(levelName,
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary(_ctx))),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: _kOrange.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text('$completedMods / $totalMods modules',
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w700, color: _kOrange)),
                        ),
                      ],
                    ),
                  ),

                  // ── Module en cours (si disponible) ───────────────────
                  if (moduleName != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                      decoration: BoxDecoration(
                        color: _kOrange.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _kOrange.withValues(alpha: 0.14)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: _kOrange.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.play_circle_outline_rounded,
                                size: 15, color: _kOrange),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Module en cours',
                                  style: TextStyle(
                                      fontSize: 10, color: Color(0xFF9CA3AF),
                                      fontWeight: FontWeight.w500)),
                                Text(moduleName,
                                  style: const TextStyle(
                                      fontSize: 13, fontWeight: FontWeight.w700,
                                      color: _kOrange),
                                  maxLines: 1, overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers widgets ───────────────────────────────────────────────────────

  Widget _badge({required IconData icon, required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _badgeDot(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6, height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _progressBar(String label, double percent, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
              style: const TextStyle(
                  fontSize: 12, color: Color(0xFF888888), fontWeight: FontWeight.w600)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('${percent.toStringAsFixed(0)}%',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: color)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: percent / 100,
            backgroundColor: color.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 9,
          ),
        ),
      ],
    );
  }

  Widget _emptyState(String name) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset('assets/lottie/Chicken.json', width: 150, height: 150),
            const SizedBox(height: 16),
            Text('Aucune progression',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary(_ctx))),
            const SizedBox(height: 8),
            Text(
              'Aucune langue assignée à $name pour le moment.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500, height: 1.5),
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_kGreen, _kGreenDark],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                        color: _kGreen.withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 5)),
                  ],
                ),
                child: const Text('Retour',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      itemCount: 4,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          height: 220,
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }
}
