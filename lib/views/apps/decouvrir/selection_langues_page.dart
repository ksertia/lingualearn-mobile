import 'package:fasolingo/controller/apps/langue/langue_controller.dart';
import 'package:fasolingo/helpers/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

// ── Palette ───────────────────────────────────────────────────────────────────
const Color _kGreen     = Color(0xFF188329);
const Color _kGreenDark = Color(0xFF0F5C1C);
const Color _kYellow    = Color(0xFFF5BF1E);

// ─────────────────────────────────────────────────────────────────────────────

class LanguageSelectionPage extends StatefulWidget {
  const LanguageSelectionPage({super.key});

  @override
  State<LanguageSelectionPage> createState() => _LanguageSelectionPageState();
}

class _LanguageSelectionPageState extends State<LanguageSelectionPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _enterCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  late final LanguagesController _langCtrl;

  @override
  void initState() {
    super.initState();
    _langCtrl = Get.isRegistered<LanguagesController>()
        ? Get.find<LanguagesController>()
        : Get.put(LanguagesController());

    _enterCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 550));
    _fadeAnim  = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeIn);
    _slideAnim = Tween<Offset>(
            begin: const Offset(0, 0.18), end: Offset.zero)
        .animate(CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOutCubic));

    _enterCtrl.forward();
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    super.dispose();
  }

  // ── Lang emoji ─────────────────────────────────────────────────────────────

  String _emoji(String? name) {
    if (name == null) return '🌍';
    final n = name.toLowerCase();
    if (n.contains('moore') || n.contains('mooré'))   return '🌍';
    if (n.contains('dioula') || n.contains('dyula'))  return '🌿';
    if (n.contains('fulfuldé') || n.contains('peul')) return '☀️';
    if (n.contains('bissa') || n.contains('bisa'))    return '🎶';
    if (n.contains('français') || n.contains('french')) return '📖';
    if (n.contains('anglais') || n.contains('english')) return '🗣️';
    if (n.contains('arabe') || n.contains('arabic'))  return '📜';
    return '🌍';
  }

  static const List<List<Color>> _palette = [
    [Color(0xFF188329), Color(0xFF0F5C1C)],
    [Color(0xFFF27F22), Color(0xFFBF5A0F)],
    [Color(0xFF0EA5E9), Color(0xFF0369A1)],
    [Color(0xFF7C3AED), Color(0xFF5B21B6)],
    [Color(0xFFF5BF1E), Color(0xFF8B6B00)],
  ];

  List<Color> _colors(String name) {
    final i = name.isNotEmpty ? name.codeUnitAt(0) % _palette.length : 0;
    return _palette[i];
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: RefreshIndicator(
                  color: _kGreen,
                  onRefresh: _langCtrl.loadAllLanguages,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSubtitle(context),
                        const SizedBox(height: 20),
                        _buildList(context),
                        const SizedBox(height: 28),
                        _buildButtons(context),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 16, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_kGreen, _kGreenDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.20), width: 1),
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.white, size: 16),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('Étape 1 / 2',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Choisir une langue',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Quelle langue voulez-vous apprendre ?',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Subtitle ───────────────────────────────────────────────────────────────

  Widget _buildSubtitle(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4, height: 20,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_kGreen, _kYellow],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'Langues disponibles',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary(context),
          ),
        ),
      ],
    );
  }

  // ── Language list ──────────────────────────────────────────────────────────

  Widget _buildList(BuildContext context) {
    return Obx(() {
      if (_langCtrl.isLoading.value && _langCtrl.allLanguages.isEmpty) {
        return _buildShimmer(context);
      }

      if (_langCtrl.allLanguages.isEmpty) {
        return _buildEmpty(context);
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _langCtrl.allLanguages.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final lang = _langCtrl.allLanguages[i];
          return Obx(() {
            final isSelected =
                _langCtrl.selectedLanguage.value?.id == lang.id;
            return _buildLangCard(context, lang, isSelected, i);
          });
        },
      );
    });
  }

  Widget _buildLangCard(BuildContext context, dynamic lang,
      bool isSelected, int index) {
    final colors = _colors(lang.name ?? '');
    final c1 = colors[0];

    return GestureDetector(
      onTap: () => _langCtrl.selectLanguage(lang),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? c1.withValues(alpha: 0.06)
              : AppColors.card(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? c1 : AppColors.border(context),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? c1.withValues(alpha: 0.14)
                  : AppColors.shadow(context),
              blurRadius: isSelected ? 18 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icône langue
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isSelected
                      ? [c1, colors[1]]
                      : [c1.withValues(alpha: 0.12),
                         c1.withValues(alpha: 0.06)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(_emoji(lang.name),
                    style: const TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(width: 14),
            // Nom + code
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lang.name ?? 'Langue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? c1 : AppColors.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 3),
                  if (lang.description != null &&
                      (lang.description as String).isNotEmpty)
                    Text(
                      lang.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary(context),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  else if (lang.code != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: c1.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        lang.code.toString().toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          color: c1,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Indicateur sélection
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 28, height: 28,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(colors: [c1, colors[1]])
                    : null,
                color: isSelected ? null : AppColors.cardAlt(context),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSelected ? Icons.check_rounded : Icons.circle_outlined,
                color: isSelected
                    ? Colors.white
                    : AppColors.textSecondary(context),
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── States ─────────────────────────────────────────────────────────────────

  Widget _buildShimmer(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase(context),
      highlightColor: AppColors.shimmerHighlight(context),
      child: Column(
        children: List.generate(4, (_) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            height: 82,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        )),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _kGreen.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.language_rounded,
                  color: _kGreen, size: 40),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune langue disponible',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Buttons ────────────────────────────────────────────────────────────────

  Widget _buildButtons(BuildContext context) {
    return Obx(() {
      final hasSelection = _langCtrl.selectedLanguage.value != null;
      final hasLevel     = _langCtrl.selectedLevel.value != null;
      final isLoading    = _langCtrl.isLoading.value;
      final hasList      = _langCtrl.selectedLanguageLevels.isNotEmpty;

      return Column(
        children: [
          // Bouton "Ajouter cette langue" (visible si sélection complète)
          if (hasSelection && hasLevel)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _btn(
                context,
                label: 'Ajouter cette langue',
                isPrimary: false,
                isLoading: isLoading,
                onTap: () => _langCtrl.addLanguageLevelToList(),
              ),
            ),

          // Bouton principal
          _btn(
            context,
            label: hasList
                ? 'Continuons !'
                : (hasSelection ? 'Choisir le niveau →' : 'Sélectionner une langue'),
            isPrimary: hasSelection || hasList,
            isLoading: isLoading,
            onTap: (!hasSelection && !hasList) || isLoading
                ? null
                : () async {
                    if (hasList) {
                      await _langCtrl.confirmAndGoToHome();
                      return;
                    }
                    if (hasSelection && !hasLevel) {
                      await _langCtrl.confirmLanguageSelection();
                      return;
                    }
                    if (hasSelection && hasLevel) {
                      await _langCtrl.confirmAndGoToHome();
                    }
                  },
          ),
        ],
      );
    });
  }

  Widget _btn(
    BuildContext context, {
    required String label,
    required bool isPrimary,
    required bool isLoading,
    VoidCallback? onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: isPrimary
          ? DecoratedBox(
              decoration: BoxDecoration(
                gradient: onTap != null
                    ? const LinearGradient(
                        colors: [_kGreen, _kGreenDark],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      )
                    : null,
                color: onTap == null ? const Color(0xFFE5E7EB) : null,
                borderRadius: BorderRadius.circular(16),
                boxShadow: onTap != null
                    ? [
                        BoxShadow(
                          color: _kGreen.withValues(alpha: 0.28),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : [],
              ),
              child: ElevatedButton(
                onPressed: isLoading ? null : onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5))
                    : Text(
                        label,
                        style: TextStyle(
                          color: onTap != null
                              ? Colors.white
                              : const Color(0xFF9CA3AF),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            )
          : OutlinedButton(
              onPressed: isLoading ? null : onTap,
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                    color: _kGreen.withValues(alpha: 0.40), width: 1.5),
                backgroundColor: _kGreen.withValues(alpha: 0.04),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  color: _kGreen,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
    );
  }
}
