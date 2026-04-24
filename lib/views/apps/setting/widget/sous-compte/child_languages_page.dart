import 'package:fasolingo/controller/apps/settings/child_language_assign_controller.dart';
import 'package:fasolingo/models/child_model.dart';
import 'package:fasolingo/models/language_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const Color _clOrange  = Color(0xFFFF7043);
const Color _clOrange2 = Color(0xFFFFB74D);
const Color _clGreen   = Color(0xFF22C55E);

class ChildLanguagesPage extends StatefulWidget {
  final ChildModel child;

  const ChildLanguagesPage({super.key, required this.child});

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
    controller.fetchEnrolledLanguages(widget.child.id);
    // Dès que l'assignation réussit, fermer le bottom sheet et retourner à SousCompte.
    // On utilise le NavigatorState directement pour éviter que Get.back() tente
    // de fermer la snackbar "succès" encore en animation (assertion GetX).
    ever(controller.justAssigned, (bool assigned) {
      if (assigned) {
        controller.justAssigned.value = false;
        Get.key.currentState?.pop(); // ferme le bottom sheet
        Get.key.currentState?.pop(); // retourne à SousCompte
      }
    });
  }

  String _childName() {
    final name = widget.child.displayName;
    return name.isNotEmpty ? name : 'Sous-compte';
  }

  String _getLanguageEmoji(String? name) {
    if (name == null) return '';
    final n = name.toLowerCase();
    if (n.contains('francais') || n.contains('french')) return '';
    if (n.contains('english') || n.contains('anglais')) return '';
    if (n.contains('espagnol') || n.contains('spanish')) return '';
    if (n.contains('moore') || n.contains('more')) return '';
    if (n.contains('dioula') || n.contains('dyula')) return '';
    if (n.contains('allemand') || n.contains('german')) return '';
    if (n.contains('arabe') || n.contains('arabic')) return '';
    return '';
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
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            children: [
              _buildInfoCard(),
              const SizedBox(height: 4),
              Expanded(child: _buildLanguageList()),
              _buildValidateButton(),
              const SizedBox(height: 16),
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
            colors: [_clOrange, _clOrange2],
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
        children: [
          Text(
            _childName(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
          ),
          const Text(
            'Attribuer une langue',
            style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _clOrange.withValues(alpha: 0.18), width: 1.5),
        boxShadow: [
          BoxShadow(color: _clOrange.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _clOrange.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.language_rounded, color: _clOrange, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Selectionnez une langue, puis choisissez un niveau pour l\'apprenant.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageList() {
    return Obx(() {
      if (controller.isFetchingLanguages.value && controller.languages.isEmpty) {
        return const Center(child: CircularProgressIndicator(color: _clOrange));
      }

      final list = controller.languages.where((l) => l.isActive == true).toList();

      if (list.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: _clOrange.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.language_rounded, color: _clOrange, size: 38),
              ),
              const SizedBox(height: 14),
              Text(
                'Aucune langue disponible',
                style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ],
          ),
        );
      }

      final enrolled = list.where((l) => controller.enrolledLanguageIds.contains(l.id)).toList();
      final available = list.where((l) => !controller.enrolledLanguageIds.contains(l.id)).toList();

      return RefreshIndicator(
        color: _clOrange,
        onRefresh: controller.fetchLanguages,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 16),
          children: [
            if (enrolled.isNotEmpty) ...[
              _sectionHeader('Deja inscrit', Icons.check_circle_rounded, _clGreen),
              const SizedBox(height: 8),
              ...enrolled.map((lang) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _languageTile(lang, isEnrolled: true),
              )),
              const SizedBox(height: 8),
            ],
            if (available.isNotEmpty) ...[
              _sectionHeader('Autres langues', Icons.add_circle_rounded, _clOrange),
              const SizedBox(height: 8),
              ...available.map((lang) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _languageTile(lang, isEnrolled: false),
              )),
            ],
          ],
        ),
      );
    });
  }

  Widget _sectionHeader(String label, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 6),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: color,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }

  Widget _languageTile(LanguageModel lang, {required bool isEnrolled}) {
    final isSelected = selectedLanguageId == lang.id;
    final borderColor = isSelected
        ? _clOrange
        : isEnrolled
            ? _clGreen.withValues(alpha: 0.50)
            : Colors.grey.shade200;
    final borderWidth = isSelected ? 2.0 : isEnrolled ? 1.5 : 1.5;
    final shadowColor = isSelected
        ? _clOrange.withValues(alpha: 0.18)
        : isEnrolled
            ? _clGreen.withValues(alpha: 0.10)
            : Colors.black.withValues(alpha: 0.05);
    final iconBg = isSelected
        ? _clOrange.withValues(alpha: 0.10)
        : isEnrolled
            ? _clGreen.withValues(alpha: 0.10)
            : Colors.grey.shade100;

    return GestureDetector(
      onTap: () => setState(() => selectedLanguageId = lang.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor, width: borderWidth),
          boxShadow: [
            BoxShadow(color: shadowColor, blurRadius: isSelected ? 14 : 8, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(14)),
              child: Center(
                child: Text(_getLanguageEmoji(lang.name), style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lang.name ?? 'Langue',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? _clOrange
                          : isEnrolled
                              ? _clGreen
                              : const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (lang.code != null)
                        Text(
                          lang.code!.toUpperCase(),
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w600),
                        ),
                      if (isEnrolled) ...[
                        if (lang.code != null) const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: _clGreen.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.check_rounded, size: 10, color: _clGreen),
                              SizedBox(width: 3),
                              Text(
                                'Deja inscrit',
                                style: TextStyle(fontSize: 10, color: _clGreen, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (isSelected)
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_clOrange, _clOrange2],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 15),
              )
            else if (isEnrolled)
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: _clGreen.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.refresh_rounded, color: _clGreen, size: 15),
              )
            else
              Icon(Icons.chevron_right_rounded, color: Colors.grey.shade300, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildValidateButton() {
    final active = selectedLanguageId != null;
    return GestureDetector(
      onTap: active ? _openLevelsBottomSheetForSelected : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 54,
        decoration: BoxDecoration(
          gradient: active
              ? const LinearGradient(
                  colors: [_clOrange, _clOrange2],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          color: active ? null : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
          boxShadow: active
              ? [BoxShadow(color: _clOrange.withValues(alpha: 0.30), blurRadius: 12, offset: const Offset(0, 5))]
              : [],
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: active ? Colors.white : Colors.grey.shade400,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Valider la selection',
                style: TextStyle(
                  color: active ? Colors.white : Colors.grey.shade400,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
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

  const _LevelsBottomSheet({required this.controller, required this.childId});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20 + bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Obx(() {
        final lang = controller.selectedLanguage.value;
        final languageName = (lang?.name ?? '').toString();
        final languageId   = (lang?.id ?? '').toString();

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _clOrange.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.layers_rounded, color: _clOrange, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    languageName.isEmpty ? 'Choisir un niveau' : 'Niveaux — $languageName',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A)),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close_rounded, color: Colors.grey.shade500),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (controller.isFetchingLevels.value)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator(color: _clOrange)),
              )
            else ...[
              if (controller.levels.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      Icon(Icons.info_outline_rounded, color: Colors.grey.shade400, size: 36),
                      const SizedBox(height: 8),
                      Text(
                        'Aucun niveau disponible',
                        style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600),
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
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final level = controller.levels[index];
                    final id   = level.id;
                    final name = (level.name ?? '').toString();
                    final desc = (level.description ?? '').toString();

                    return Obx(() {
                      final selected = controller.selectedLevelId.value == id;
                      return GestureDetector(
                        onTap: () => controller.selectedLevelId.value = id,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: selected ? _clGreen : Colors.grey.shade200,
                              width: selected ? 2 : 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: selected
                                    ? _clGreen.withValues(alpha: 0.15)
                                    : Colors.black.withValues(alpha: 0.04),
                                blurRadius: selected ? 12 : 6,
                                offset: const Offset(0, 4),
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
                                      name.isEmpty ? 'Niveau sans nom' : name,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: selected ? _clGreen : const Color(0xFF1A1A1A),
                                      ),
                                    ),
                                    if (desc.trim().isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        desc,
                                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500, height: 1.3),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              if (selected)
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [_clGreen, Color(0xFF4ADE80)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
                                )
                              else
                                Icon(Icons.radio_button_unchecked_rounded, color: Colors.grey.shade300, size: 22),
                            ],
                          ),
                        ),
                      );
                    });
                  },
                ),
              const SizedBox(height: 18),
              Obx(() => GestureDetector(
                onTap: controller.isAssigning.value
                    ? null
                    : () async {
                        if (childId == null || childId!.isEmpty) return;
                        if (languageId.isEmpty) return;
                        final levelId = controller.selectedLevelId.value;
                        if (levelId.isEmpty) return;
                        await controller.assign(
                          childId: childId!,
                          languageId: languageId,
                          levelId: levelId,
                        );
                      },
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: controller.isAssigning.value
                        ? null
                        : const LinearGradient(
                            colors: [_clOrange, _clOrange2],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                    color: controller.isAssigning.value ? Colors.grey.shade300 : null,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: controller.isAssigning.value
                        ? []
                        : [BoxShadow(color: _clOrange.withValues(alpha: 0.30), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Center(
                    child: controller.isAssigning.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                          )
                        : const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Assigner ce niveau',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15),
                              ),
                            ],
                          ),
                  ),
                ),
              )),
            ],
          ],
        );
      }),
    );
  }
}
