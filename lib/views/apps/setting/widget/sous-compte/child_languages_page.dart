import 'package:fasolingo/controller/apps/settings/child_language_assign_controller.dart';
import 'package:fasolingo/helpers/theme/app_colors.dart';
import 'package:fasolingo/models/child_model.dart';
import 'package:fasolingo/models/language_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const Color _kGreen      = Color(0xFF188329);
const Color _kGreenDark  = Color(0xFF0F5C1C);
const Color _kYellow     = Color(0xFFF5BF1E);
const Color _kOrange     = Color(0xFFF27F22);
const Color _kOrangeDark = Color(0xFFC4611A);

class ChildLanguagesPage extends StatefulWidget {
  final ChildModel child;
  const ChildLanguagesPage({super.key, required this.child});

  @override
  State<ChildLanguagesPage> createState() => _ChildLanguagesPageState();
}

class _ChildLanguagesPageState extends State<ChildLanguagesPage> {
  final ChildLanguageAssignController controller =
      Get.put(ChildLanguageAssignController());
  late BuildContext _ctx;

  String? selectedLanguageId;

  @override
  void initState() {
    super.initState();
    controller.fetchLanguages();
    controller.fetchEnrolledLanguages(widget.child.id);
    ever(controller.justAssigned, (bool assigned) {
      if (assigned) {
        controller.justAssigned.value = false;
        Get.key.currentState?.pop();
        Get.key.currentState?.pop();
      }
    });
  }

  String _childName() {
    final name = widget.child.displayName;
    return name.isNotEmpty ? name : 'Sous-compte';
  }

  Color _avatarColor(String name) {
    const colors = [
      Color(0xFF188329), Color(0xFF0284C7), Color(0xFF7C3AED),
      Color(0xFFEA580C), Color(0xFF0891B2), Color(0xFFDB2777),
    ];
    return colors[name.hashCode.abs() % colors.length];
  }

  String _langEmoji(String? name) {
    if (name == null) return '🌐';
    final n = name.toLowerCase();
    if (n.contains('francais') || n.contains('french'))  return '🇫🇷';
    if (n.contains('english') || n.contains('anglais'))  return '🇬🇧';
    if (n.contains('espagnol') || n.contains('spanish')) return '🇪🇸';
    if (n.contains('moore') || n.contains('moré'))       return '🇧🇫';
    if (n.contains('dioula') || n.contains('dyula'))     return '🇧🇫';
    if (n.contains('allemand') || n.contains('german'))  return '🇩🇪';
    if (n.contains('arabe') || n.contains('arabic'))     return '🇸🇦';
    return '🌐';
  }

  Future<void> _openLevelsBottomSheetForSelected() async {
    if (selectedLanguageId == null) return;
    final lang = controller.languages.firstWhere(
      (l) => l.id == selectedLanguageId,
      orElse: () => LanguageModel(id: '', name: '', code: '', isActive: false),
    );
    if (lang.id.isEmpty) return;
    await _openLevelsSheet(lang);
  }

  Future<void> _openLevelsSheet(LanguageModel language) async {
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
    _ctx = context;
    final topPad = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: AppColors.bgAlt(context),
      body: Column(
        children: [
          _buildHeader(topPad),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                children: [
                  Expanded(child: _buildLanguageList()),
                  _buildValidateButton(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────

  Widget _buildHeader(double topPad) {
    final name    = _childName();
    final initial = name.isNotEmpty ? name.characters.first.toUpperCase() : '?';
    final color   = _avatarColor(name);

    return Container(
      padding: EdgeInsets.fromLTRB(20, topPad + 16, 20, 22),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_kGreen, _kGreenDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ligne haut : retour + avatar enfant
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 15),
                ),
              ),
              const Spacer(),
              // Avatar carré arrondi de l'enfant
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 8, offset: const Offset(0, 3)),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(initial,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Titre + icône déco
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Attribuer une langue',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 26,
                            letterSpacing: -0.5)),
                    const SizedBox(height: 5),
                    Text(
                      'Pour $name',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.70), fontSize: 13),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
                ),
                child: const Icon(Icons.language_rounded, color: Colors.white, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Hint intégré dans le header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
            ),
            child: const Row(
              children: [
                Icon(Icons.touch_app_rounded, color: Colors.white70, size: 15),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Sélectionnez une langue puis choisissez un niveau',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Liste des langues ────────────────────────────────────────────────────────

  Widget _buildLanguageList() {
    return Obx(() {
      if (controller.isFetchingLanguages.value && controller.languages.isEmpty) {
        return const Center(child: CircularProgressIndicator(color: _kOrange, strokeWidth: 2.5));
      }

      final list = controller.languages.where((l) => l.isActive == true).toList();

      if (list.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80, height: 80,
                decoration: const BoxDecoration(color: Color(0xFFF3F4F6), shape: BoxShape.circle),
                child: const Icon(Icons.language_rounded, color: Color(0xFFD1D5DB), size: 38),
              ),
              const SizedBox(height: 14),
              const Text('Aucune langue disponible',
                  style: TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.w700, fontSize: 15)),
            ],
          ),
        );
      }

      final enrolled  = list.where((l) =>  controller.enrolledLanguageIds.contains(l.id)).toList();
      final available = list.where((l) => !controller.enrolledLanguageIds.contains(l.id)).toList();

      return RefreshIndicator(
        color: _kOrange,
        onRefresh: controller.fetchLanguages,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 12),
          children: [
            if (enrolled.isNotEmpty) ...[
              _sectionHeader('Déjà inscrit', _kGreen),
              const SizedBox(height: 10),
              ...enrolled.map((l) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _languageTile(l, isEnrolled: true),
              )),
              const SizedBox(height: 14),
            ],
            if (available.isNotEmpty) ...[
              _sectionHeader('Langues disponibles', _kOrange),
              const SizedBox(height: 10),
              ...available.map((l) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _languageTile(l, isEnrolled: false),
              )),
            ],
          ],
        ),
      );
    });
  }

  Widget _sectionHeader(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 3, height: 16,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 8),
        Text(
          label.toUpperCase(),
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: color, letterSpacing: 0.9),
        ),
      ],
    );
  }

  Widget _languageTile(LanguageModel lang, {required bool isEnrolled}) {
    final isSelected = selectedLanguageId == lang.id;

    final Color borderColor = isSelected
        ? _kOrange
        : isEnrolled
            ? _kGreen.withValues(alpha: 0.40)
            : const Color(0xFFEEEEEE);
    final Color nameColor = isSelected
        ? _kOrange
        : isEnrolled
            ? _kGreen
            : AppColors.textPrimary(_ctx);
    final Color iconBg = isSelected
        ? _kOrange.withValues(alpha: 0.09)
        : isEnrolled
            ? _kGreen.withValues(alpha: 0.08)
            : const Color(0xFFF3F4F6);

    return GestureDetector(
      onTap: isEnrolled ? null : () => setState(() => selectedLanguageId = lang.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isEnrolled ? AppColors.cardAlt(_ctx) : AppColors.card(_ctx),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: isSelected ? 2 : 1.5),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? _kOrange.withValues(alpha: 0.14)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: isSelected ? 16 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Column(
            children: [
              // Barre couleur en haut si sélectionné
              if (isSelected)
                Container(
                  height: 3,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [_kOrange, _kYellow]),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    // Emoji dans carré arrondi
                    Container(
                      width: 52, height: 52,
                      decoration: BoxDecoration(
                        color: iconBg,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: Text(_langEmoji(lang.name), style: const TextStyle(fontSize: 26)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lang.name ?? 'Langue',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: nameColor),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            children: [
                              if (lang.code != null)
                                _chip(lang.code!.toUpperCase(), const Color(0xFFF3F4F6), const Color(0xFF6B7280)),
                              if (isEnrolled)
                                _chip('✓ Inscrit', _kGreen.withValues(alpha: 0.10), _kGreen),
                              if (isSelected)
                                _chip('Sélectionné', _kOrange.withValues(alpha: 0.10), _kOrange),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Indicateur droite
                    if (isSelected)
                      Container(
                        width: 30, height: 30,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [_kOrange, _kOrangeDark],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: _kOrange.withValues(alpha: 0.35), blurRadius: 8, offset: const Offset(0, 3))],
                        ),
                        child: const Icon(Icons.check_rounded, color: Colors.white, size: 15),
                      )
                    else if (isEnrolled)
                      Container(
                        width: 30, height: 30,
                        decoration: BoxDecoration(
                          color: _kGreen.withValues(alpha: 0.10),
                          shape: BoxShape.circle,
                          border: Border.all(color: _kGreen.withValues(alpha: 0.25)),
                        ),
                        child: const Icon(Icons.lock_rounded, color: _kGreen, size: 14),
                      )
                    else
                      Container(
                        width: 30, height: 30,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF5F5F5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.chevron_right_rounded, color: Color(0xFFBBBBBB), size: 18),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String label, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(7)),
      child: Text(label, style: TextStyle(fontSize: 11, color: textColor, fontWeight: FontWeight.w700)),
    );
  }

  // ── Bouton valider ───────────────────────────────────────────────────────────

  Widget _buildValidateButton() {
    final active = selectedLanguageId != null;
    return GestureDetector(
      onTap: active ? _openLevelsBottomSheetForSelected : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 54,
        decoration: BoxDecoration(
          gradient: active
              ? const LinearGradient(colors: [_kOrange, _kOrangeDark], begin: Alignment.centerLeft, end: Alignment.centerRight)
              : null,
          color: active ? null : const Color(0xFFEEEEEE),
          borderRadius: BorderRadius.circular(16),
          boxShadow: active
              ? [BoxShadow(color: _kOrange.withValues(alpha: 0.32), blurRadius: 14, offset: const Offset(0, 5))]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.layers_rounded, color: active ? Colors.white : Colors.grey.shade400, size: 20),
            const SizedBox(width: 8),
            Text(
              active ? 'Choisir un niveau →' : 'Sélectionnez une langue',
              style: TextStyle(
                color: active ? Colors.white : Colors.grey.shade400,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bottom sheet : choix du niveau ──────────────────────────────────────────

class _LevelsBottomSheet extends StatelessWidget {
  final ChildLanguageAssignController controller;
  final String? childId;

  const _LevelsBottomSheet({required this.controller, required this.childId});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          // Header fixe
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Obx(() {
              final lang = controller.selectedLanguage.value;
              final langName = (lang?.name ?? '').toString();
              return Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3EB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _kOrange.withValues(alpha: 0.22)),
                    ),
                    child: const Icon(Icons.layers_rounded, color: _kOrange, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Choisir un niveau',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary(context))),
                        if (langName.isNotEmpty)
                          Text(langName,
                              style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: const BoxDecoration(color: Color(0xFFF3F4F6), shape: BoxShape.circle),
                      child: const Icon(Icons.close_rounded, color: Color(0xFF9CA3AF), size: 17),
                    ),
                  ),
                ],
              );
            }),
          ),
          const SizedBox(height: 16),
          // Contenu scrollable
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottomInset),
              child: Obx(() {
                final lang       = controller.selectedLanguage.value;
                final languageId = (lang?.id ?? '').toString();

                if (controller.isFetchingLevels.value) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: CircularProgressIndicator(color: _kOrange, strokeWidth: 2.5)),
                  );
                }

                if (controller.levels.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      children: [
                        Container(
                          width: 70, height: 70,
                          decoration: const BoxDecoration(color: Color(0xFFF3F4F6), shape: BoxShape.circle),
                          child: const Icon(Icons.layers_outlined, color: Color(0xFFD1D5DB), size: 32),
                        ),
                        const SizedBox(height: 14),
                        const Text('Aucun niveau disponible',
                            style: TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.w600, fontSize: 14)),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    // Tuiles de niveaux
                    ...controller.levels.asMap().entries.map((entry) {
                      final idx   = entry.key;
                      final level = entry.value;
                      final id    = level.id;
                      final name  = (level.name ?? '').toString();
                      final desc  = (level.description ?? '').toString();

                      return Obx(() {
                        final selected = controller.selectedLevelId.value == id;
                        return GestureDetector(
                          onTap: () => controller.selectedLevelId.value = id,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: AppColors.card(context),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: selected ? _kGreen : const Color(0xFFEEEEEE),
                                width: selected ? 2 : 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: selected
                                      ? _kGreen.withValues(alpha: 0.14)
                                      : Colors.black.withValues(alpha: 0.04),
                                  blurRadius: selected ? 16 : 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Column(
                                children: [
                                  // Barre verte en haut si sélectionné
                                  if (selected)
                                    Container(
                                      height: 3,
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(colors: [_kGreen, _kYellow]),
                                      ),
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Row(
                                      children: [
                                        // Badge numéro niveau
                                        Container(
                                          width: 42, height: 42,
                                          decoration: BoxDecoration(
                                            gradient: selected
                                                ? const LinearGradient(
                                                    colors: [_kGreen, _kGreenDark],
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                  )
                                                : null,
                                            color: selected ? null : const Color(0xFFF3F4F6),
                                            borderRadius: BorderRadius.circular(12),
                                            boxShadow: selected
                                                ? [BoxShadow(color: _kGreen.withValues(alpha: 0.35), blurRadius: 10, offset: const Offset(0, 4))]
                                                : [],
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            (idx + 1).toString().padLeft(2, '0'),
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w900,
                                              color: selected ? Colors.white : const Color(0xFFBBBBBB),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                name.isEmpty ? 'Niveau ${idx + 1}' : name,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                  color: selected ? _kGreen : AppColors.textPrimary(context),
                                                ),
                                              ),
                                              if (desc.trim().isNotEmpty) ...[
                                                const SizedBox(height: 4),
                                                Text(desc,
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                        fontSize: 12, color: Color(0xFF9CA3AF), height: 1.4)),
                                              ],
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        // Sélecteur
                                        if (selected)
                                          Container(
                                            width: 28, height: 28,
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [_kGreen, _kGreenDark],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              shape: BoxShape.circle,
                                              boxShadow: [BoxShadow(color: _kGreen.withValues(alpha: 0.35), blurRadius: 8, offset: const Offset(0, 3))],
                                            ),
                                            child: const Icon(Icons.check_rounded, color: Colors.white, size: 15),
                                          )
                                        else
                                          Container(
                                            width: 28, height: 28,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(color: const Color(0xFFDDDDDD), width: 2),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      });
                    }),

                    const SizedBox(height: 8),

                    // Bouton assigner
                    Obx(() {
                      final loading    = controller.isAssigning.value;
                      final canAssign  = controller.selectedLevelId.value.isNotEmpty && !loading;
                      return GestureDetector(
                        onTap: canAssign
                            ? () async {
                                if (childId == null || childId!.isEmpty) return;
                                if (languageId.isEmpty) return;
                                final levelId = controller.selectedLevelId.value;
                                if (levelId.isEmpty) return;
                                await controller.assign(
                                  childId: childId!,
                                  languageId: languageId,
                                  levelId: levelId,
                                );
                              }
                            : null,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 54,
                          decoration: BoxDecoration(
                            gradient: canAssign
                                ? const LinearGradient(
                                    colors: [_kGreen, _kGreenDark],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  )
                                : null,
                            color: canAssign ? null : const Color(0xFFEEEEEE),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: canAssign
                                ? [BoxShadow(color: _kGreen.withValues(alpha: 0.32), blurRadius: 14, offset: const Offset(0, 5))]
                                : [],
                          ),
                          child: Center(
                            child: loading
                                ? const SizedBox(
                                    height: 22, width: 22,
                                    child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.check_circle_rounded,
                                          color: canAssign ? Colors.white : Colors.grey.shade400, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        canAssign ? 'Assigner ce niveau' : 'Sélectionnez un niveau',
                                        style: TextStyle(
                                          color: canAssign ? Colors.white : Colors.grey.shade400,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      );
                    }),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
