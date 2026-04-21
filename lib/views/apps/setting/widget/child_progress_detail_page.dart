import 'package:fasolingo/controller/apps/settings/child_progress_controller.dart';
import 'package:fasolingo/model/child_model.dart';
import 'package:fasolingo/model/child_progress_models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

class _ChildProgressDetailPageState extends State<ChildProgressDetailPage> {
  final ChildProgressController controller = Get.put(ChildProgressController());

  @override
  void initState() {
    super.initState();
    controller.fetchProgress(widget.child.id);
  }

  Widget _progressRing({
    required double percent,
    required String title,
    required String subtitle,
    Color color = const Color(0xFF2E7D32),
  }) {
    final p = percent.clamp(0, 100);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          )
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            height: 64,
            width: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: p / 100,
                  strokeWidth: 8,
                  backgroundColor: const Color(0xFFE9ECEF),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
                Text(
                  '${p.toStringAsFixed(0)}%',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _progressRingsRow({
    required double languagePercent,
    required double levelPercent,
  }) {
    final double lp = languagePercent.clamp(0, 100).toDouble();
    final double vp = levelPercent.clamp(0, 100).toDouble();

    Widget ring(double p, Color color) {
      return SizedBox(
        height: 64,
        width: 64,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: p / 100,
              strokeWidth: 8,
              backgroundColor: const Color(0xFFE9ECEF),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
            Text(
              '${p.toStringAsFixed(0)}%',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        ring(lp, const Color(0xFF2E7D32)),
        const SizedBox(width: 12),
        ring(vp, const Color(0xFF1565C0)),
      ],
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

  @override
  Widget build(BuildContext context) {
    final name = widget.child.displayName;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        title: Text(name),
        backgroundColor: const Color(0xFFF6F7F9),
        elevation: 0,
        surfaceTintColor: const Color(0xFFF6F7F9),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value && controller.progress.value == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final res = controller.progress.value;
          final items = (res?.data ?? <ChildProgressItemModel>[]).toList();
          items.sort(_compareLastAccessed);

          return RefreshIndicator(
            onRefresh: () => controller.fetchProgress(widget.child.id),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 14,
                        offset: Offset(0, 6),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 46,
                        width: 46,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFE8F5E9),
                          border: Border.all(
                              color: const Color(0xFF66BB6A), width: 1),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          name.isNotEmpty
                              ? name.characters.first.toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.child.username ?? '—',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (items.isEmpty)
                  _progressRing(
                    percent: 0,
                    title: 'Aucune progression',
                    subtitle: 'Aucune langue assignée à ce sous-compte',
                    color: const Color(0xFF2E7D32),
                  )
                else
                  ...items.map((it) {
                    final lang = it.language;
                    final lvl = it.level;
                    final languageName = lang?.name ?? '—';
                    final languageCode = lang?.code ?? '—';
                    final languageStatus = lang?.status ?? '—';
                    final lastAccessed = lang?.lastAccessedAt;
                    final levelName = lvl?.name ?? '—';
                    final levelStatus = lvl?.status ?? '—';
                    final totalModules = lvl?.totalModules ?? 0;
                    final completedModules = lvl?.completedModules ?? 0;
                    final langPercent = lang?.progressPercentage ?? 0;
                    final lvlPercent = lvl?.progressPercentage ?? 0;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x14000000),
                              blurRadius: 14,
                              offset: Offset(0, 6),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        languageName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Code: $languageCode • Statut: $languageStatus',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade600,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      if (lastAccessed != null &&
                                          lastAccessed.trim().isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          'Dernier accès: $lastAccessed',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                _progressRingsRow(
                                  languagePercent: langPercent,
                                  levelPercent: lvlPercent,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF6F7F9),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Niveau: $levelName',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'Modules: $completedModules/$totalModules • $levelStatus',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade700,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
              ],
            ),
          );
        }),
      ),
    );
  }
}
