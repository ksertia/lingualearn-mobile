import 'package:tibi/controller/apps/langue/langue_controller.dart';
import 'package:tibi/helpers/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ── Palette ───────────────────────────────────────────────────────────────────
const Color _kGreen     = Color(0xFF188329);
const Color _kblack    = Colors.black;
const Color _kOrange     = Color(0xFFF27F22);

// ── Niveau colors & icons ─────────────────────────────────────────────────────
const _levelMeta = [
  _LevelMeta(_kblack,  Icons.grass_rounded,   'Niveau de base'),
  _LevelMeta(_kOrange, Icons.park_rounded,    'Niveau intermédiaire'),
  _LevelMeta(_kGreen, Icons.forest_rounded,  'Niveau avancé'),
];

class _LevelMeta {
  final Color color;
  final IconData icon;
  final String hint;
  const _LevelMeta(this.color, this.icon, this.hint);
}

// ─────────────────────────────────────────────────────────────────────────────

class ChoisieNiveauPage extends StatefulWidget {
  const ChoisieNiveauPage({super.key});

  @override
  State<ChoisieNiveauPage> createState() => _ChoisieNiveauPageState();
}

class _ChoisieNiveauPageState extends State<ChoisieNiveauPage>
    with SingleTickerProviderStateMixin {
  late final LanguagesController _langCtrl;
  late final AnimationController _enterCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset>  _slideAnim;

  @override
  void initState() {
    super.initState();
    _langCtrl = Get.find<LanguagesController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _langCtrl.loadLanguageLevels();
    });

    _enterCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 520));
    _fadeAnim  = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeIn);
    _slideAnim = Tween<Offset>(
            begin: const Offset(0, 0.18), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _enterCtrl, curve: Curves.easeOutCubic));

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
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: _buildBody(context),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Get.back(),
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
              const SizedBox(width: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Étape 2 / 2',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700)),
              ),
              const Spacer(),
              // Badge langue sélectionnée
              Obx(() {
                final name =
                    _langCtrl.selectedLanguage.value?.name ?? '';
                if (name.isEmpty) return const SizedBox.shrink();
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                        width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.language_rounded,
                          color: Colors.white, size: 14),
                      const SizedBox(width: 6),
                      Text(name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Choisir votre niveau',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Les leçons seront adaptées à votre niveau',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ── Body ───────────────────────────────────────────────────────────────────

  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (_langCtrl.isLoadingLevels.value &&
                  _langCtrl.languageLevels.isEmpty) {
                return _buildLoading(context);
              }
              if (_langCtrl.languageLevels.isEmpty) {
                return _buildEmpty(context);
              }
              return ListView.separated(
                physics: const BouncingScrollPhysics(),
                itemCount: _langCtrl.languageLevels.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (_, i) =>
                    _buildLevelCard(context, _langCtrl.languageLevels[i], i),
              );
            }),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 28),
            child: _buildCta(context),
          ),
        ],
      ),
    );
  }

  // ── Level card ─────────────────────────────────────────────────────────────

  Widget _buildLevelCard(BuildContext context, dynamic level, int index) {
    return Obx(() {
      // Résolution de l'id sélectionné
      final sel = _langCtrl.selectedLevel.value;
      final selId = sel == null
          ? null
          : sel is Map
              ? sel['id']?.toString()
              : sel?.id?.toString();

      final lvlId = level is Map
          ? level['id']?.toString() ?? ''
          : level?.id?.toString() ?? '';

      final isSelected = selId != null && selId == lvlId;

      final name = level is Map
          ? level['name']?.toString() ?? ''
          : level?.name?.toString() ?? '';
      final desc = level is Map
          ? level['description']?.toString() ?? ''
          : level?.description?.toString() ?? '';

      final meta = _levelMeta[index % _levelMeta.length];
      final c    = meta.color;
      // Couleur active : toujours _kOrange quand sélectionné
      final activeColor = isSelected ? _kOrange : c;

      return GestureDetector(
        onTap: () => _langCtrl.selectLevel(level),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isSelected
                ? activeColor.withValues(alpha: 0.06)
                : AppColors.card(context),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? activeColor : AppColors.border(context),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? activeColor.withValues(alpha: 0.16)
                    : AppColors.shadow(context),
                blurRadius: isSelected ? 20 : 8,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icône niveau
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 58, height: 58,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isSelected
                        ? [activeColor, activeColor.withValues(alpha: 0.70)]
                        : [c.withValues(alpha: 0.10),
                           c.withValues(alpha: 0.05)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  meta.icon,
                  size: 28,
                  color: isSelected ? Colors.white : c,
                ),
              ),
              const SizedBox(width: 16),

              // Texte
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? activeColor
                            : AppColors.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      desc.isNotEmpty ? desc : meta.hint,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary(context),
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (isSelected) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: activeColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_rounded,
                                color: activeColor, size: 11),
                            const SizedBox(width: 4),
                            Text('Sélectionné',
                                style: TextStyle(
                                    color: activeColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Indicateur
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 28, height: 28,
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(colors: [activeColor, activeColor.withValues(alpha: 0.70)])
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
    });
  }

  // ── CTA button ─────────────────────────────────────────────────────────────

  Widget _buildCta(BuildContext context) {
    return Obx(() {
      final hasLevel = _langCtrl.selectedLevel.value != null;
      final loading  = _langCtrl.isLoading.value;

      return SizedBox(
        width: double.infinity,
        height: 56,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: hasLevel
                ? const LinearGradient(
                    colors: [_kOrange, _kOrange],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : null,
            color: hasLevel ? null : const Color(0xFFE5E7EB),
            borderRadius: BorderRadius.circular(16),
            boxShadow: hasLevel
                ? [
                    BoxShadow(
                      color: _kOrange.withValues(alpha: 0.30),
                      blurRadius: 18,
                      offset: const Offset(0, 7),
                    ),
                  ]
                : [],
          ),
          child: ElevatedButton(
            onPressed: (!hasLevel || loading)
                ? null
                : () async {
                    if (_langCtrl.selectedLanguage.value == null) {
                      Get.snackbar(
                        'Oups',
                        'Veuillez recommencer la sélection de la langue.',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                      Get.offAllNamed('/selection');
                      return;
                    }
                    final ok = await _langCtrl.saveLevelSelection();
                    if (ok) Get.offAllNamed('/HomeScreen');
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: loading
                ? const SizedBox(
                    width: 22, height: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        hasLevel ? "C'est parti !" : 'Sélectionner un niveau',
                        style: TextStyle(
                          color: hasLevel
                              ? Colors.white
                              : const Color(0xFF9CA3AF),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                      if (hasLevel) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.rocket_launch_rounded,
                            color: Colors.white, size: 18),
                      ],
                    ],
                  ),
          ),
        ),
      );
    });
  }

  // ── States ─────────────────────────────────────────────────────────────────

  Widget _buildLoading(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 48, height: 48,
            child: CircularProgressIndicator(
              color: _kOrange,
              strokeWidth: 3,
              backgroundColor: _kOrange.withValues(alpha: 0.12),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Chargement des niveaux…',
            style: TextStyle(
              color: AppColors.textSecondary(context),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _kOrange.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.layers_rounded,
                color: _kOrange, size: 38),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun niveau disponible',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }
}
