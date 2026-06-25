import 'package:tibi/controller/apps/langue/langue_controller.dart';
import 'package:tibi/helpers/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';


const Color _kOrange     = Color(0xFFF27F22);



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

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
            20, 12, 20, MediaQuery.of(context).padding.bottom + 16),
        decoration: BoxDecoration(
          color: AppColors.bg(context),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: _buildButtons(context),
      ),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: RefreshIndicator(
                  color: _kOrange,
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
          colors: [_kOrange, _kOrange],
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
              colors: [_kOrange, _kOrange],
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
    return GestureDetector(
      onTap: () => _langCtrl.selectLanguage(lang),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? _kOrange.withValues(alpha: 0.06)
              : AppColors.card(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? _kOrange : AppColors.border(context),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? _kOrange.withValues(alpha: 0.14)
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
                      ? [_kOrange, _kOrange]
                      : [_kOrange.withValues(alpha: 0.12),
                         _kOrange.withValues(alpha: 0.06)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Icon(
                  Icons.language_rounded,
                  color: isSelected ? Colors.white : _kOrange,
                  size: 26,
                ),
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
                      color: isSelected ? _kOrange : AppColors.textPrimary(context),
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
                        color: _kOrange.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        lang.code.toString().toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          color: _kOrange,
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
                    ? const LinearGradient(colors: [_kOrange, _kOrange])
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
                color: _kOrange.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.language_rounded,
                  color: _kOrange, size: 40),
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
        mainAxisSize: MainAxisSize.min,
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
                : (hasSelection ? 'Choisir le niveau' : 'Sélectionner une langue'),
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
                        colors: [_kOrange, _kOrange],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      )
                    : null,
                color: onTap == null ? const Color(0xFFE5E7EB) : null,
                borderRadius: BorderRadius.circular(16),
                boxShadow: onTap != null
                    ? [
                        BoxShadow(
                          color: _kOrange.withValues(alpha: 0.28),
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
                    color: _kOrange.withValues(alpha: 0.40), width: 1.5),
                backgroundColor: _kOrange.withValues(alpha: 0.04),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  color: _kOrange,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
    );
  }
}
