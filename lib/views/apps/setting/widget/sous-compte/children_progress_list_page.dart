import 'package:fasolingo/controller/apps/settings/children_controller.dart';
import 'package:fasolingo/models/child_model.dart';
import 'package:fasolingo/views/apps/setting/widget/sous-compte/child_progress_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

const Color _cpOrange  = Color(0xFFFF7043);
const Color _cpOrange2 = Color(0xFFFFB74D);

class ChildrenProgressListPage extends StatefulWidget {
  const ChildrenProgressListPage({super.key});

  @override
  State<ChildrenProgressListPage> createState() =>
      _ChildrenProgressListPageState();
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

  static const List<String> _animalLotties = [
    'dino.json',
    'elephant.json',
    'cat.json',
    'Dog.json',
    'Lion.json',
    'Chicken.json',
    'poulet.json',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            children: [
              _buildSearchField(),
              const SizedBox(height: 14),
              _buildHeaderCard(),
              const SizedBox(height: 4),
              Expanded(child: _buildList()),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_cpOrange, _cpOrange2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
        ),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
      ),
      leading: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
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
        children: const [
          Text(
            'Progression',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
          ),
          Text(
            'Suivez vos apprenants',
            style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cpOrange.withValues(alpha: 0.18), width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: TextField(
        controller: searchController,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: 'Rechercher un apprenant...',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: Icon(Icons.search_rounded, color: _cpOrange.withValues(alpha: 0.7), size: 22),
          filled: false,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _cpOrange.withValues(alpha: 0.18), width: 1.5),
        boxShadow: [
          BoxShadow(color: _cpOrange.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _cpOrange.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.emoji_events_rounded, color: _cpOrange, size: 22),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Appuyez sur un apprenant pour voir sa progression detaillee.',
              style: TextStyle(fontSize: 13, color: Color(0xFF666666), height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return Obx(() {
      final list = _applySearch(controller.children.toList());

      if (controller.isFetching.value && controller.children.isEmpty) {
        return const Center(child: CircularProgressIndicator(color: _cpOrange));
      }

      if (list.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset('assets/lottie/Chicken.json', width: 140, height: 140),
              const SizedBox(height: 12),
              Text(
                'Aucun apprenant trouve',
                style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w700, fontSize: 16),
              ),
              const SizedBox(height: 6),
              Text(
                'Ajoutez des apprenants depuis "Sous comptes".',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        color: _cpOrange,
        onRefresh: controller.fetchMyChildren,
        child: ListView.separated(
          padding: const EdgeInsets.only(bottom: 80),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final child = list[index];
            return InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => Get.to(() => ChildProgressDetailPage(child: child)),
              child: _buildChildTile(child),
            );
          },
        ),
      );
    });
  }

  Widget _buildChildTile(ChildModel child) {
    final name = child.displayName;
    final initial = name.isNotEmpty ? name.characters.first.toUpperCase() : 'U';
    final subtitle = (child.username ?? '').isNotEmpty
        ? child.username!
        : (child.email ?? '').isNotEmpty
            ? child.email!
            : '—';

    final int idx = name.hashCode.abs() % _animalLotties.length;
    final String animal = _animalLotties[idx];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _cpOrange.withValues(alpha: 0.15), width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                height: 54,
                width: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _cpOrange.withValues(alpha: 0.30), width: 2),
                ),
                child: ClipOval(
                  child: Lottie.asset('assets/lottie/$animal', fit: BoxFit.cover),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [_cpOrange, _cpOrange2],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initial,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A)),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _cpOrange.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.bar_chart_rounded, color: _cpOrange, size: 18),
          ),
        ],
      ),
    );
  }
}
