import 'package:fasolingo/controller/apps/settings/child_language_assign_controller.dart';
import 'package:fasolingo/model/child_model.dart';
import 'package:fasolingo/model/language_model.dart';
import 'package:fasolingo/model/level_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChildLanguagesPage extends StatefulWidget {
  final ChildModel child;

  const ChildLanguagesPage({
    super.key,
    required this.child,
  });

  @override
  State<ChildLanguagesPage> createState() => _ChildLanguagesPageState();
}

class _ChildLanguagesPageState extends State<ChildLanguagesPage> {
  final ChildLanguageAssignController controller =
      Get.put(ChildLanguageAssignController());

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.fetchLanguages();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  String _childName() {
    final name = widget.child.displayName;
    return name.isNotEmpty ? name : 'Sous-compte';
  }

  List<LanguageModel> _applySearch(List<LanguageModel> data) {
    final q = searchController.text.trim().toLowerCase();
    if (q.isEmpty) return data;

    return data.where((e) {
      final name = (e.name ?? '').toLowerCase();
      final code = (e.code ?? '').toLowerCase();
      return name.contains(q) || code.contains(q);
    }).toList();
  }

  Future<void> _openLevelsBottomSheet(LanguageModel language) async {
    if (language.id.isEmpty) return;

    controller.selectedLanguage.value = language;
    await controller.fetchLevels(language.id);

    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LevelsBottomSheet(
        controller: controller,
        childId: widget.child.id,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        title: Text('Langues - ${_childName()}'),
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
                  hintText: 'Rechercher une langue',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: const Color(0xFFF2F3F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: Obx(() {
                  if (controller.isFetchingLanguages.value &&
                      controller.languages.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final list = _applySearch(controller.languages);
                  if (list.isEmpty) {
                    return Center(
                      child: Text(
                        'Aucune langue',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: controller.fetchLanguages,
                    child: ListView.separated(
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final lang = list[index];
                        final name = (lang.name ?? '').toString();
                        final code = (lang.code ?? '').toString();
                        final isActive = lang.isActive == true;

                        return InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => _openLevelsBottomSheet(lang),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
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
                                        color: const Color(0xFF66BB6A),
                                        width: 1),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    code.isNotEmpty
                                        ? code.characters.first.toUpperCase()
                                        : name.isNotEmpty
                                            ? name.characters.first
                                                .toUpperCase()
                                            : '?',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF2E7D32),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name.isEmpty ? 'Sans nom' : name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        code.isEmpty ? 'Code: —' : 'Code: $code',
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
                                const SizedBox(width: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF2F3F5),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    isActive ? 'Active' : 'Inactive',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: isActive
                                          ? const Color(0xFF2E7D32)
                                          : Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
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

class _LevelsBottomSheet extends StatelessWidget {
  final ChildLanguageAssignController controller;
  final String? childId;

  const _LevelsBottomSheet({
    required this.controller,
    required this.childId,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Material(
      color: Colors.white,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: 16 + bottomInset,
        ),
        child: Obx(() {
        final lang = controller.selectedLanguage.value;
        final languageName = (lang?.name ?? '').toString();
        final languageId = (lang?.id ?? '').toString();

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  languageName.isEmpty ? 'Niveaux' : 'Niveaux - $languageName',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (controller.isFetchingLevels.value)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              )
            else ...[
              if (controller.levels.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'Aucun niveau',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.levels.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final level = controller.levels[index];
                    final id = level.id;
                    final name = (level.name ?? '').toString();
                    final desc = (level.description ?? '').toString();

                    return Obx(() {
                      final selected = controller.selectedLevelId.value == id;
                      return InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => controller.selectedLevelId.value = id,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF6F7F9),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: selected
                                  ? const Color(0xFF66BB6A)
                                  : Colors.transparent,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name.isEmpty ? 'Niveau' : name,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    if (desc.trim().isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        desc,
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
                              const SizedBox(width: 10),
                              Container(
                                height: 22,
                                width: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: selected
                                        ? const Color(0xFF2E7D32)
                                        : Colors.grey.shade400,
                                  ),
                                  color: selected
                                      ? const Color(0xFF2E7D32)
                                      : Colors.transparent,
                                ),
                                child: selected
                                    ? const Icon(Icons.check,
                                        size: 14, color: Colors.white)
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      );
                    });
                  },
                ),
              const SizedBox(height: 16),
              Obx(
                () => ElevatedButton(
                  onPressed: controller.isAssigning.value
                      ? null
                      : () async {
                          if (childId == null || childId!.isEmpty) return;
                          if (languageId.isEmpty) return;
                          final levelId = controller.selectedLevelId.value;
                          if (levelId.isEmpty) return;

                          final ok = await controller.assign(
                            childId: childId!,
                            languageId: languageId,
                            levelId: levelId,
                          );
                          if (ok && context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: controller.isAssigning.value
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Assigner',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                ),
              ),
            ],
          ],
        );
      }),
      ),
    );
  }
}
