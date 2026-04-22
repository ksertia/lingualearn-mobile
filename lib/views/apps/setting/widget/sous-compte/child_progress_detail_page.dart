import 'package:fasolingo/controller/apps/settings/child_progress_controller.dart';
import 'package:fasolingo/models/child_model.dart';
import 'package:fasolingo/models/child_progress_models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:lottie/lottie.dart';

const Color _pdOrange  = Color(0xFFFF7043);
const Color _pdOrange2 = Color(0xFFFFB74D);
const Color _pdGreen   = Color(0xFF22C55E);

class ChildProgressDetailPage extends StatefulWidget {
  final ChildModel child;

  const ChildProgressDetailPage({super.key, required this.child});

  @override
  State<ChildProgressDetailPage> createState() => _ChildProgressDetailPageState();
}

class _ChildProgressDetailPageState extends State<ChildProgressDetailPage>
    with TickerProviderStateMixin {
  final ChildProgressController controller = Get.put(ChildProgressController());

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
    if (diff.inDays > 0) return '${diff.inDays}j';
    if (diff.inHours > 0) return '${diff.inHours}h';
    return 'Recent';
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
    final name = widget.child.displayName;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(name),
      body: SafeArea(
        top: false,
        child: Obx(() {
          if (controller.isLoading.value && controller.progress.value == null) {
            return _shimmerList();
          }

          final res = controller.progress.value;
          final items = (res?.data ?? <ChildProgressItemModel>[]).toList();
          items.sort(_compareLastAccessed);

          if (items.isEmpty) {
            return _emptyState(name);
          }

          final avgProgress = items
              .map((i) => i.level?.progressPercentage ?? 0.0)
              .reduce((a, b) => a + b) /
              items.length;

          return RefreshIndicator(
            color: _pdOrange,
            onRefresh: () => controller.fetchProgress(widget.child.id),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 100, 16, 0),
                    child: _summaryCard(name, items.length, avgProgress),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
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
    );
  }

  PreferredSizeWidget _buildAppBar(String name) {
    return AppBar(
      toolbarHeight: 76,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_pdOrange, _pdOrange2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      leading: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 17),
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
          ),
          const Text(
            'Progression de l\'apprenant',
            style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(String name, int langCount, double avg) {
    final initial = name.isNotEmpty ? name.characters.first.toUpperCase() : 'U';
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_pdOrange, _pdOrange2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: _pdOrange.withValues(alpha: 0.30),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 58,
            width: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 2.5),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.10), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              initial,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: _pdOrange),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _statChip('$langCount', 'Langues', Icons.language_rounded),
                    const SizedBox(width: 10),
                    _statChip('${avg.round()}%', 'Moy.', Icons.trending_up_rounded),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statChip(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(width: 3),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.85))),
        ],
      ),
    );
  }

  Widget _languageCard(ChildProgressItemModel it) {
    final lang = it.language;
    final lvl  = it.level;
    final languageName   = lang?.name ?? '-';
    final languageCode   = (lang?.code ?? '-').toUpperCase();
    final lastAccessed   = _formatRelativeTime(lang?.lastAccessedAt);
    final levelName      = lvl?.name ?? '-';
    final totalModules   = lvl?.totalModules ?? 0;
    final completedModules = lvl?.completedModules ?? 0;
    final langPercent    = (lang?.progressPercentage ?? 0.0).clamp(0.0, 100.0);
    final lvlPercent     = (lvl?.progressPercentage ?? 0.0).clamp(0.0, 100.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _pdOrange.withValues(alpha: 0.12), width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 14, offset: const Offset(0, 6)),
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
                  color: _pdOrange.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.flag_rounded, size: 22, color: _pdOrange),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      languageName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A)),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(languageCode, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: _pdOrange.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            lastAccessed,
                            style: const TextStyle(fontSize: 11, color: _pdOrange, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _progressRing(percent: langPercent, color: _pdOrange, label: 'Langue'),
              const SizedBox(width: 10),
              _progressRing(percent: lvlPercent, color: _pdGreen, label: 'Niveau'),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.school_rounded, size: 18, color: _pdOrange),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Niveau: $levelName',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A)),
                  ),
                ),
                Text(
                  '$completedModules / $totalModules modules',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _progressRing({required double percent, Color? color, String? label}) {
    return Column(
      children: [
        SizedBox(
          height: 60,
          width: 60,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: percent / 100,
                strokeWidth: 7,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(color ?? _pdOrange),
              ),
              Text(
                '${percent.toStringAsFixed(0)}%',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF444444)),
              ),
            ],
          ),
        ),
        if (label != null) ...[
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
        ],
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
            Lottie.asset('assets/lottie/Chicken.json', width: 160, height: 160),
            const SizedBox(height: 20),
            const Text(
              'Aucune progression',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF444444)),
            ),
            const SizedBox(height: 8),
            Text(
              'Ajoutez des langues a $name pour voir sa progression.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500, height: 1.4),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_pdOrange, _pdOrange2],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(color: _pdOrange.withValues(alpha: 0.30), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: const Text(
                  'Retour',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 100, 16, 20),
      itemCount: 4,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          height: 130,
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}
