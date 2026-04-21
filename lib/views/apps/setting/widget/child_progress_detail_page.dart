import 'package:fasolingo/controller/apps/settings/child_progress_controller.dart';
import 'package:fasolingo/model/child_model.dart';
import 'package:fasolingo/model/child_progress_models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fasolingo/helpers/theme/admin_theme.dart';
import 'package:shimmer/shimmer.dart';
import 'package:lottie/lottie.dart';

class ChildProgressDetailPage extends StatefulWidget {
  final ChildModel child;

  const ChildProgressDetailPage({
    super.key,
    required this.child,
  });

  @override
  State<ChildProgressDetailPage> createState() =>
      _ChildProgressDetailPageState();
}

class _ChildProgressDetailPageState extends State<ChildProgressDetailPage>
    with TickerProviderStateMixin {
  final ChildProgressController controller = Get.put(ChildProgressController());
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    controller.fetchProgress(widget.child.id);
    _animationController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))
          ..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildStatBadge(int value, String label, IconData icon, {bool isHeader = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isHeader ? Colors.white.withOpacity(0.2) : Colors.blueAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isHeader ? Colors.white.withOpacity(0.4) : Colors.blueAccent.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isHeader ? Colors.white : AdminTheme.theme.contentTheme.primary),
          const SizedBox(width: 4),
          Text('$value',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isHeader ? Colors.white : AdminTheme.theme.contentTheme.primary)),
          Text(' $label',
              style: TextStyle(
                  fontSize: 12,
                  color: isHeader ? Colors.white.withOpacity(0.9) : AdminTheme.theme.contentTheme.kB7B7B7)),
        ],
      ),
    );
  }

  Widget _shimmerCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: 100,
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  int _compareLastAccessed(ChildProgressItemModel a, ChildProgressItemModel b) {
    final ad = DateTime.tryParse(a.language?.lastAccessedAt ?? '');
    final bd = DateTime.tryParse(b.language?.lastAccessedAt ?? '');
    if (ad == null && bd == null) return 0;
    if (ad == null) return 1;
    if (bd == null) return -1;
    return bd.compareTo(ad);
  }

  String _formatRelativeTime(String? dateStr) {
    if (dateStr == null) return 'Jamais';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return dateStr;
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays > 0) return '${diff.inDays}j';
    if (diff.inHours > 0) return '${diff.inHours}h';
    return 'Récemment';
  }

  Widget _progressRing({
    required double percent,
    Color? color,
    String? label,
  }) {
    final p = percent.clamp(0.0, 100.0);
    return Column(
      children: [
        SizedBox(
          height: 70,
          width: 70,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: p / 100,
                strokeWidth: 8,
                backgroundColor: AdminTheme.theme.contentTheme.kEDEDED,
                valueColor: AlwaysStoppedAnimation<Color>(
                    color ?? AdminTheme.theme.contentTheme.primary),
              ),
              Text(
                '${p.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AdminTheme.theme.contentTheme.k545454,
                ),
              ),
            ],
          ),
        ),
        if (label != null) ...[
          const SizedBox(height: 6),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  color: AdminTheme.theme.contentTheme.kB7B7B7)),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    AdminTheme.setTheme(context);
    final name = widget.child.displayName;

    return Scaffold(
      backgroundColor: AdminTheme.theme.contentTheme.kDarkColor ?? const Color(0xFFF6F7F9),
      appBar: AppBar(
        toolbarHeight: 80,
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blueAccent.shade700,
                Colors.blueAccent,
              ],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blueAccent.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        ),
        title: Column(
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: () => Get.back(),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.2),
              child: const Icon(Icons.person_search, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value && controller.progress.value == null) {
            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: 5,
              itemBuilder: (_, __) => _shimmerCard(),
            );
          }

          final res = controller.progress.value;
          final items = (res?.data ?? <ChildProgressItemModel>[]).toList();
          items.sort(_compareLastAccessed);

          if (items.isEmpty) {
            return CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset('assets/lottie/Chicken.json',
                          width: 200, height: 200, repeat: true),
                      const SizedBox(height: 24),
                      Text(
                        'Aucune progression encore',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AdminTheme.theme.contentTheme.k545454),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ajoutez des langues à $name pour voir la magie opérer! ✨',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16,
                            color: AdminTheme.theme.contentTheme.kB7B7B7),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.arrow_back, size: 20),
                        label: const Text('Ajouter langues',
                            style: TextStyle(fontSize: 16)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AdminTheme.theme.contentTheme.primary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          final avgProgress = items.isEmpty
              ? 0.0
              : items
                      .map((i) => i.level?.progressPercentage ?? 0.0)
                      .reduce((a, b) => a + b) /
                  items.length;

          return RefreshIndicator(
            color: AdminTheme.theme.contentTheme.primary,
            onRefresh: () => controller.fetchProgress(widget.child.id),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.blueAccent,
                            Colors.blueAccent.shade700,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Hero(
                            tag: 'child_avatar_${widget.child.id}',
                            child: Container(
                              height: 60,
                              width: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.5),
                                    width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 16,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                name.isNotEmpty
                                    ? name.characters.first.toUpperCase()
                                    : 'U',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.blueAccent,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.child.username ?? '—',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white.withOpacity(0.8),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    _buildStatBadge(items.length, 'Langues',
                                        Icons.language, isHeader: true),
                                    const SizedBox(width: 12),
                                    _buildStatBadge(avgProgress.round(),
                                        'Mon. Prog.', Icons.trending_up, isHeader: true),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final it = items[index];
                        final lang = it.language;
                        final lvl = it.level;
                        final languageName = lang?.name ?? '—';
                        final languageCode = lang?.code ?? '—';
                        final languageStatus = lang?.status ?? '—';
                        final lastAccessed = _formatRelativeTime(lang?.lastAccessedAt);
                        final levelName = lvl?.name ?? '—';
                        final levelStatus = lvl?.status ?? '—';
                        final totalModules = lvl?.totalModules ?? 0;
                        final completedModules = lvl?.completedModules ?? 0;
                        final langPercent = lang?.progressPercentage ?? 0.0;
                        final lvlPercent = lvl?.progressPercentage ?? 0.0;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0D000000),
                                blurRadius: 16,
                                offset: Offset(0, 8),
                              ),
                            ],
                            gradient: LinearGradient(
                              colors: [
                                Colors.orange.withOpacity(0.05),
                                Colors.white,
                              ],
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.flag,
                                        size: 24, color: Colors.orange),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          languageName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w800,
                                            color: AdminTheme.theme.contentTheme.k545454,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Text(
                                              languageCode,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: AdminTheme.theme.contentTheme.kB7B7B7,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            if (languageStatus != 'started')
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: Colors.orange.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  languageStatus,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.orange,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      _progressRing(
                                          percent: langPercent,
                                          color: Colors.orange,
                                          label: 'Langue'),
                                      const SizedBox(width: 12),
                                      _progressRing(
                                          percent: lvlPercent,
                                          color: Colors.blueAccent,
                                          label: 'Niveau'),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.orange.withOpacity(0.2)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.school, size: 20, color: Colors.orange),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Niveau: $levelName',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: AdminTheme.theme.contentTheme.k545454,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '$completedModules/$totalModules ${levelStatus == 'started' ? '' : '• $levelStatus'}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AdminTheme.theme.contentTheme.kB7B7B7,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
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
}