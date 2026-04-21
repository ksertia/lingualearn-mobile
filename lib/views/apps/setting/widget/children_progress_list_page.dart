import 'package:fasolingo/controller/apps/settings/children_controller.dart';
import 'package:fasolingo/model/child_model.dart';
import 'package:fasolingo/views/apps/setting/widget/child_progress_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChildrenProgressListPage extends StatefulWidget {
  const ChildrenProgressListPage({super.key});

  @override
  State<ChildrenProgressListPage> createState() => _ChildrenProgressListPageState();
}

class _ChildrenProgressListPageState extends State<ChildrenProgressListPage> {
  final ChildrenController controller = Get.put(ChildrenController());
  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<ChildModel> _applySearch(List<ChildModel> data) {
    final q = searchController.text.trim().toLowerCase();
    if (q.isEmpty) return data;

    return data.where((e) {
      final name = e.displayName.toLowerCase();
      final username = (e.username ?? '').toLowerCase();
      return name.contains(q) || username.contains(q);
    }).toList();
  }

  Widget _childTile(ChildModel child) {
    final name = child.displayName;
    final initial = name.isNotEmpty ? name.characters.first.toUpperCase() : 'U';
    final subtitle = (child.username ?? '').isNotEmpty
        ? child.username!
        : (child.email ?? '').isNotEmpty
            ? child.email!
            : '—';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
              border: Border.all(color: const Color(0xFF66BB6A), width: 1),
            ),
            alignment: Alignment.center,
            child: Text(
              initial,
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 1,
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
          Icon(Icons.chevron_right, color: Colors.grey.shade500),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        title: const Text('Parcour sous comptes'),
        backgroundColor: const Color(0xFFF6F7F9),
        elevation: 0,
        surfaceTintColor: const Color(0xFFF6F7F9),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: Column(
            children: [
              TextField(
                controller: searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Rechercher',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: const Color(0xFFF2F3F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: Obx(() {
                  if (controller.isFetching.value && controller.children.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final list = _applySearch(controller.children.toList());
                  if (list.isEmpty) {
                    return Center(
                      child: Text(
                        'Aucun sous-compte',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: controller.fetchMyChildren,
                    child: ListView.separated(
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final child = list[index];
                        return InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Get.to(() => ChildProgressDetailPage(child: child));
                          },
                          child: _childTile(child),
                        );
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
