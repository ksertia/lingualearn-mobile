import 'package:fasolingo/controller/apps/settings/child_language_assign_controller.dart';
import 'package:fasolingo/model/child_model.dart';
import 'package:fasolingo/model/language_model.dart';
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

  String? selectedLanguageId;

  @override
  void initState() {
    super.initState();
    controller.fetchLanguages();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String _childName() {
    final name = widget.child.displayName;
    return name.isNotEmpty ? name : 'Sous-compte';
  }

  String _getLanguageEmoji(String? name) {
    if (name == null) return "🌍";
    final lowerName = name.toLowerCase();
    
    if (lowerName.contains("français") || lowerName.contains("french")) {
      return "🗼"; 
    } else if (lowerName.contains("english") || lowerName.contains("anglais")) {
      return "🎯"; 
    } else if (lowerName.contains("español") || lowerName.contains("spanish") || lowerName.contains("espagnol")) {
      return "💃"; 
    } else if (lowerName.contains("mooré") || lowerName.contains("moore") || lowerName.contains("moré")) {
      return "☀️"; 
    } else if (lowerName.contains("dioula") || lowerName.contains("dyula")) {
      return "🌿"; 
    } else if (lowerName.contains("allemand") || lowerName.contains("german")) {
      return "🏰"; 
    } else if (lowerName.contains("italien") || lowerName.contains("italian")) {
      return "🍕"; 
    } else if (lowerName.contains("portugais") || lowerName.contains("portuguese")) {
      return "⚽"; 
    } else if (lowerName.contains("chinois") || lowerName.contains("chinese")) {
      return "🐉"; 
    } else if (lowerName.contains("arabe") || lowerName.contains("arabic")) {
      return "🕌"; 
    } 
    
    return "🌍"; // Default globe
  }

  Future<void> _openLevelsBottomSheetForSelected() async {
    if (selectedLanguageId == null) return;
    final selectedLang = controller.languages.firstWhere(
      (lang) => lang.id == selectedLanguageId,
      orElse: () => LanguageModel(id: '', name: '', code: '', isActive: false),
    );
    if (selectedLang.id.isEmpty) return;
    await _openLevelsBottomSheet(selectedLang);
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
      backgroundColor: const Color(0xFFE3F2FD), // Light blue background
      appBar: AppBar(
        title: Text(
          '🌍 Langues pour ${_childName()}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1565C0),
          ),
        ),
        backgroundColor: const Color(0xFFE3F2FD),
        elevation: 0,
        surfaceTintColor: const Color(0xFFE3F2FD),
        actions: [
          IconButton(
            icon: const Icon(Icons.language, color: Color(0xFFFFC107)),
            onPressed: () {}, // Placeholder
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.orange.shade200,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          '📚',
                          style: TextStyle(fontSize: 24),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Liste des langues disponibles',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.orange.shade800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sélectionnez une langue à attribuer à ${_childName()}. Choisissez celle qui correspond le mieux à ses besoins d\'apprentissage !',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Obx(() {
                  if (controller.isFetchingLanguages.value &&
                      controller.languages.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final list = controller.languages
                      .where((lang) => lang.isActive == true)
                      .toList();
                  if (list.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            '🌍',
                            style: TextStyle(fontSize: 48),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Aucune langue trouvée',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Explore le monde des langues !',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: controller.fetchLanguages,
                    child: ListView.separated(
                      padding: const EdgeInsets.only(
                          bottom: 100), // Space for button
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final lang = list[index];
                        final isSelected = selectedLanguageId == lang.id;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: InkWell(
                            onTap: () => setState(() => selectedLanguageId = lang.id),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.white : Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected ? Colors.orange : Colors.grey.shade200,
                                  width: isSelected ? 3 : 1,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: Colors.orange.withOpacity(0.3),
                                          blurRadius: 15,
                                          offset: const Offset(0, 5),
                                        ),
                                      ]
                                    : [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 10,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.orange.withOpacity(0.1)
                                          : Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Center(
                                      child: Text(
                                        _getLanguageEmoji(lang.name),
                                        style: const TextStyle(fontSize: 28),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          lang.name ?? "Langue",
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w700,
                                            color: isSelected ? Colors.orange.shade800 : Colors.black87,
                                          ),
                                        ),
                                        if (lang.code != null)
                                          Text(
                                            lang.code!.toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade500,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFFFFB347), Color(0xFFFFE259)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      child: const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }),
              ),
              SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: selectedLanguageId != null ? LinearGradient(
                      colors: [Colors.orangeAccent.shade700, Colors.orangeAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ) : LinearGradient(
                      colors: [Colors.grey.shade400, Colors.grey.shade600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x29000000),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: selectedLanguageId != null ? () => _openLevelsBottomSheetForSelected() : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      foregroundColor: selectedLanguageId != null ? Colors.white : Colors.black,
                      padding: EdgeInsets.symmetric(vertical: selectedLanguageId != null ? 20 : 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      '✅ Valider la sélection',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                  ),
                ),
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
                    languageName.isEmpty
                        ? '🎯 Choisis ton niveau'
                        : '🎯 Niveaux - $languageName',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1565C0)),
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
                    child: Column(
                      children: [
                        const Text(
                          '🚀',
                          style: TextStyle(fontSize: 32),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Aucun niveau disponible',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
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
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: InkWell(
                            onTap: () => controller.selectedLevelId.value = id,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: selected ? Colors.white : Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: selected ? Colors.green : Colors.grey.shade200,
                                  width: selected ? 3 : 1,
                                ),
                                boxShadow: selected
                                    ? [
                                        BoxShadow(
                                          color: Colors.green.withOpacity(0.3),
                                          blurRadius: 15,
                                          offset: const Offset(0, 5),
                                        ),
                                      ]
                                    : [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 10,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name.isEmpty ? 'Niveau mystère' : name,
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w700,
                                            color: selected ? Colors.green.shade800 : Colors.black87,
                                          ),
                                        ),
                                        if (desc.trim().isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            desc,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade500,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  if (selected)
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      child: const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                ],
                              ),
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
                      backgroundColor: Colors.orangeAccent,
                      foregroundColor: Colors.black87,
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
                            '🚀 Assigner',
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
