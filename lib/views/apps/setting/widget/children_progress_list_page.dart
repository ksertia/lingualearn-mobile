import 'package:fasolingo/controller/apps/settings/children_controller.dart';
import 'package:fasolingo/model/child_model.dart';
import 'package:fasolingo/views/apps/setting/widget/child_progress_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:animate_do/animate_do.dart';

class ChildrenProgressListPage extends StatefulWidget {
  const ChildrenProgressListPage({super.key});

  @override
  State<ChildrenProgressListPage> createState() =>
      _ChildrenProgressListPageState();
}

class _ChildrenProgressListPageState
    extends State<ChildrenProgressListPage> {
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

  List<String> get animalLotties => [
        'dino.json',
        'elephant.json',
        'cat.json',
        'Dog.json',
        'Lion.json',
        'Chicken.json',
        'poulet.json'
      ];

  Widget _childTile(ChildModel child) {
    final name = child.displayName;
    final initial =
        name.isNotEmpty ? name.characters.first.toUpperCase() : 'U';

    final subtitle = (child.username ?? '').isNotEmpty
        ? child.username!
        : (child.email ?? '').isNotEmpty
            ? child.email!
            : '—';

    final int index = name.hashCode.abs() % animalLotties.length;
    final String animal = animalLotties[index];

    final Color cardColor = Color.lerp(
Colors.orangeAccent[200]!,
      Colors.orangeAccent[400]!,
      index / animalLotties.length,
    )!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cardColor.withOpacity(0.6), Colors.white],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: cardColor.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Colors.teal[300]!,
                      Colors.blue[300]!,
                    ],
                  ),
                  border: Border.all(color: Colors.teal[100]!, width: 3),
                ),
                child: ClipOval(
                  child: Lottie.asset(
                    'assets/lottie/$animal',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.teal[100],
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    initial,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.emoji_events, color: Colors.teal),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFE3F2FD),
            Color(0xFFF1F8E9),
            Color(0xFFE8F5E8),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('👦 Progress des Champions! 🎉'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Get.back(),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: '🔍 Rechercher...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Header container moved after search
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.orange.withOpacity(0.2)),
                  ),
                  child: const Text(
                    '📋 Liste des utilisateurs enfants',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Obx(() {
                    final list = _applySearch(
                        controller.children.toList());

                    if (list.isEmpty) {
                      return const Center(
                        child: Text('Aucun enfant'),
                      );
                    }

                    return ListView.separated(
                      itemCount: list.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final child = list[index];
                        return InkWell(
                          onTap: () {
                            Get.to(() =>
                                ChildProgressDetailPage(
                                    child: child));
                          },
                          child: _childTile(child),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
