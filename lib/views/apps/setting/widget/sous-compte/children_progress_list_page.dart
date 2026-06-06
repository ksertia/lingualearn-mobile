import 'package:fasolingo/controller/apps/settings/children_controller.dart';
import 'package:fasolingo/helpers/theme/app_colors.dart';
import 'package:fasolingo/models/child_model.dart';
import 'package:fasolingo/views/apps/setting/widget/sous-compte/child_progress_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

const Color _kGreen      = Color(0xFF188329);
const Color _kGreenDark  = Color(0xFF0F5C1C);
const Color _kYellow     = Color(0xFFF5BF1E);
const Color _kOrange     = Color(0xFFF27F22);
const Color _kOrangeDark = Color(0xFFC4611A);

class ChildrenProgressListPage extends StatefulWidget {
  const ChildrenProgressListPage({super.key});

  @override
  State<ChildrenProgressListPage> createState() =>
      _ChildrenProgressListPageState();
}

class _ChildrenProgressListPageState extends State<ChildrenProgressListPage> {
  final ChildrenController controller = Get.put(ChildrenController());
  final TextEditingController searchController = TextEditingController();
  late BuildContext _ctx;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<ChildModel> _applySearch(List<ChildModel> data) {
    final q = searchController.text.trim().toLowerCase();
    if (q.isEmpty) return data;
    return data.where((e) {
      final name     = e.displayName.toLowerCase();
      final username = (e.username ?? '').toLowerCase();
      return name.contains(q) || username.contains(q);
    }).toList();
  }

  static const List<String> _animalLotties = [
    'dino.json', 'elephant.json', 'cat.json',
    'Dog.json',  'Lion.json',     'Chicken.json', 'poulet.json',
  ];

  @override
  Widget build(BuildContext context) {
    _ctx = context;
    final topPad = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: AppColors.bgAlt(context),
      body: Column(
        children: [
          _buildHeader(topPad),
          _buildSearchBar(),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildHeader(double topPad) {
    return Obx(() {
      final count = controller.children.length;
      return Container(
        padding: EdgeInsets.fromLTRB(20, topPad + 16, 20, 22),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_kGreen, _kGreenDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 16),
                  ),
                ),
                const Spacer(),
                if (count > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _kYellow,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: _kYellow.withValues(alpha: 0.40), blurRadius: 8, offset: const Offset(0, 3))],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.people_rounded, size: 14, color: Color(0xFF1A1A1A)),
                        const SizedBox(width: 5),
                        Text('$count', style: const TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.w900, fontSize: 15)),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            const Text('Progression',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 26, letterSpacing: -0.5)),
            const SizedBox(height: 4),
            Text('Suivez les avancées de vos apprenants',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.70), fontSize: 13)),
          ],
        ),
      );
    });
  }

  Widget _buildSearchBar() {
    return Container(
      color: AppColors.card(_ctx),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: searchController,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Rechercher un apprenant...',
            hintStyle: const TextStyle(color: Color(0xFFBBBBBB), fontSize: 14),
            prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFFBBBBBB), size: 19),
            suffixIcon: searchController.text.isNotEmpty
                ? GestureDetector(
                    onTap: () { searchController.clear(); setState(() {}); },
                    child: const Icon(Icons.close_rounded, color: Color(0xFF9CA3AF), size: 16),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 11),
          ),
        ),
      ),
    );
  }

  Widget _buildList() {
    return Obx(() {
      final list = _applySearch(controller.children.toList());

      if (controller.isFetching.value && controller.children.isEmpty) {
        return const Center(child: CircularProgressIndicator(color: _kOrange, strokeWidth: 2.5));
      }

      if (list.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 88, height: 88,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [_kOrange, _kOrangeDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: _kOrange.withValues(alpha: 0.28), blurRadius: 20, offset: const Offset(0, 8))],
                  ),
                  child: const Icon(Icons.person_search_outlined, color: Colors.white, size: 38),
                ),
                const SizedBox(height: 20),
                Text('Aucun apprenant',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.textPrimary(_ctx))),
                const SizedBox(height: 8),
                Text(
                  searchController.text.isNotEmpty
                      ? 'Aucun résultat pour votre recherche.'
                      : 'Ajoutez des apprenants depuis\n"Sous comptes".',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14, height: 1.5),
                ),
              ],
            ),
          ),
        );
      }

      return RefreshIndicator(
        color: _kOrange,
        onRefresh: controller.fetchMyChildren,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) => GestureDetector(
            onTap: () => Get.to(() => ChildProgressDetailPage(child: list[index])),
            child: _buildChildCard(list[index]),
          ),
        ),
      );
    });
  }

  Widget _buildChildCard(ChildModel child) {
    final name     = child.displayName;
    final initial  = name.isNotEmpty ? name.characters.first.toUpperCase() : 'U';
    final subtitle = (child.username ?? '').isNotEmpty
        ? '@${child.username}'
        : (child.email ?? '').isNotEmpty
            ? child.email!
            : '—';

    final int    idx    = name.hashCode.abs() % _animalLotties.length;
    final String animal = _animalLotties[idx];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card(_ctx),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          // ── Ligne principale ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Row(
              children: [
                // Animal Lottie avec badge initiale
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 54, height: 54,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFF5F5F5),
                        border: Border.all(color: const Color(0xFFEEEEEE), width: 1.5),
                      ),
                      child: ClipOval(child: Lottie.asset('assets/lottie/$animal', fit: BoxFit.cover)),
                    ),
                    Positioned(
                      bottom: -2, right: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: _kYellow,
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: Text(initial,
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF1A1A1A))),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                // Nom + sous-titre
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary(_ctx))),
                      const SizedBox(height: 3),
                      Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // Badge "Actif" orange
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3EB),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _kOrange.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 6, height: 6,
                          decoration: const BoxDecoration(color: _kOrange, shape: BoxShape.circle)),
                      const SizedBox(width: 5),
                      const Text('Actif', style: TextStyle(fontSize: 11, color: _kOrange, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // ── Séparateur ────────────────────────────────────────────
          const Divider(height: 1, indent: 14, endIndent: 14, color: Color(0xFFF5F5F5)),
          // ── Pied de carte — progression ───────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: Row(
              children: [
                const Icon(Icons.show_chart_rounded, size: 14, color: _kGreen),
                const SizedBox(width: 5),
                const Text('Voir la progression',
                    style: TextStyle(fontSize: 12, color: _kGreen, fontWeight: FontWeight.w700)),
                const Spacer(),
                const Text('Détails',
                    style: TextStyle(fontSize: 12, color: Color(0xFFBBBBBB), fontWeight: FontWeight.w500)),
                const SizedBox(width: 3),
                const Icon(Icons.arrow_forward_ios_rounded, size: 11, color: Color(0xFFBBBBBB)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
