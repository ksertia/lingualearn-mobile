import 'package:tibi/controller/apps/langue/discover_controller.dart';
import 'package:tibi/helpers/services/langue/discover_service.dart';
import 'package:tibi/models/langue/decouverte_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

const Color _kOrange     = Color(0xFFF27F22);

class LanguageDcouvertPage extends StatefulWidget {
  const LanguageDcouvertPage({super.key});

  @override
  State<LanguageDcouvertPage> createState() => _LanguageDcouvertPageState();
}

class _LanguageDcouvertPageState extends State<LanguageDcouvertPage> {
  final DiscoverController _controller = DiscoverController();

  @override
  void initState() {
    super.initState();
    _controller.init();
    _controller.addListener(() { if (mounted) setState(() {}); });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fond dégradé jaune
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFF27F22),
                    Color(0xFFF27F22),
                    Color(0xFFF27F22),
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // Cercles décoratifs
          Positioned(
              top: -55, right: -35,
              child: _decorCircle(185, 0.07)),
          Positioned(
              top: 90, left: -55,
              child: _decorCircle(150, 0.05)),
          Positioned(
              top: 30, right: 60,
              child: _decorCircle(70, 0.06)),

          // Contenu principal
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildSheet()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _decorCircle(double size, double opacity) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: opacity),
        ),
      );

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        children: [
          // Barre top
          Row(
            children: [
              _buildBackBtn(),
              const Spacer(),
              _buildBadge(),
            ],
          ),
          const SizedBox(height: 16),

          // Mascotte
          Lottie.asset(
            'assets/lottie/mascot.json',
            width: 112, height: 112,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.auto_awesome_rounded, size: 72, color: Colors.white),
          ),
          const SizedBox(height: 10),

          const Text(
            'Explorez une langue !',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 4),

          Text(
            'Quelle culture souhaitez-vous découvrir ?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              color: Colors.white.withValues(alpha: 0.88),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildBackBtn() {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 42, height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: Colors.white.withValues(alpha: 0.30), width: 1),
        ),
        child: const Icon(Icons.arrow_back_ios_new,
            color: Colors.white, size: 18),
      ),
    );
  }

  Widget _buildBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: Colors.white.withValues(alpha: 0.30), width: 1),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.explore_rounded, color: Colors.white, size: 15),
          SizedBox(width: 6),
          Text('Découverte',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ── Sheet blanche ──────────────────────────────────────────────────────────

  Widget _buildSheet() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
              color: Color(0x22000000),
              blurRadius: 24,
              offset: Offset(0, -6)),
        ],
      ),
      child: Column(
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 4),
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color:  Colors.white.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Liste scrollable
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionLabel(),
                  const SizedBox(height: 14),
                  _buildContent(),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // Bouton fixe en bas
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 26),
            child: _buildButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel() {
    return Row(
      children: [
        Container(
          width: 3.5, height: 18,
          decoration: BoxDecoration(
            color: _kOrange,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          'LANGUES DISPONIBLES',
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            color: Color(0xFFAAAAAA),
            letterSpacing: 1.8,
          ),
        ),
      ],
    );
  }

  // ── Contenu (loading / erreur / liste) ────────────────────────────────────

  Widget _buildContent() {
    if (_controller.isLoading && _controller.languages.isEmpty) {
      return _buildSkeleton();
    }
    if (_controller.error != null && _controller.languages.isEmpty) {
      return _buildError();
    }
    return Column(
      children: _controller.languages
          .map((lang) => _buildCard(lang))
          .toList(),
    );
  }

  Widget _buildCard(DiscoverLanguage lang) {
    final meta = _getMeta(lang.name);
    final sel = _controller.selectedLanguage?.code == lang.code;
    final loading = _controller.isLoading && sel;

    return GestureDetector(
      onTap: () => _controller.selectLanguage(lang),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: sel ? _kOrange.withValues(alpha: 0.07) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: sel ? _kOrange : Colors.grey.shade200,
            width: sel ? 2.0 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: sel
                  ? _kOrange.withValues(alpha: 0.16)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: sel ? 18 : 8,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icône colorée
            AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              width: 50, height: 50,
              decoration: BoxDecoration(
                color: sel
                    ? _kOrange.withValues(alpha: 0.15)
                    : const Color(0xFFF2F2F2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(meta.emoji,
                    style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 14),

            // Nom + région
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lang.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: sel ? _kOrange : const Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    meta.region,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFFAAAAAA),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _showPreview(context, lang),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.menu_book_rounded,
                            size: 13, color: _kOrange.withValues(alpha: 0.85)),
                        const SizedBox(width: 4),
                        Text(
                          'Voir le programme',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: _kOrange.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Indicateur check / chevron
            AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              width: 30, height: 30,
              decoration: BoxDecoration(
                color: sel ? _kOrange : const Color(0xFFF2F2F2),
                borderRadius: BorderRadius.circular(9),
              ),
              child: loading
                  ? const Padding(
                      padding: EdgeInsets.all(7),
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Icon(
                      sel
                          ? Icons.check_rounded
                          : Icons.chevron_right_rounded,
                      color: sel ? Colors.white : const Color(0xFFCCCCCC),
                      size: 17,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return Column(
      children: List.generate(3, (i) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 78,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(18),
        ),
      )),
    );
  }

  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Column(
        children: [
          Icon(Icons.cloud_off_rounded, size: 44, color: Colors.red.shade300),
          const SizedBox(height: 10),
          Text(
            _controller.error!,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red.shade600, fontSize: 13.5),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: _controller.init,
            icon: const Icon(Icons.refresh_rounded, size: 17),
            label: const Text('Réessayer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Aperçu du programme ───────────────────────────────────────────────────

  void _showPreview(BuildContext context, DiscoverLanguage lang) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LanguagePreviewSheet(code: lang.code, name: lang.name),
    );
  }

  // ── Bouton CTA ─────────────────────────────────────────────────────────────

  Widget _buildButton() {
    final canGo =
        _controller.selectedLanguage != null && !_controller.isLoading;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: canGo
            ? const LinearGradient(
                colors: [_kOrange, _kOrange],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        color: canGo ? null : const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(16),
        boxShadow: canGo
            ? [
                BoxShadow(
                  color: _kOrange.withValues(alpha: 0.45),
                  blurRadius: 18,
                  offset: const Offset(0, 7),
                )
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: canGo
              ? () => Get.toNamed('/decouverte', arguments: {
                    'data': _controller.demoContent,
                    'languageName': _controller.selectedLanguage!.name,
                  })
              : null,
          child: Center(
            child: Text(
              canGo ? 'Explorer cette langue' : 'Choisissez une langue',
              style: TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w800,
                color: canGo ?  Colors.white : Colors.grey.shade400,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Aperçu du programme complet ──────────────────────────────────────────────

class _LanguagePreviewSheet extends StatefulWidget {
  final String code;
  final String name;
  const _LanguagePreviewSheet({required this.code, required this.name});

  @override
  State<_LanguagePreviewSheet> createState() => _LanguagePreviewSheetState();
}

class _LanguagePreviewSheetState extends State<_LanguagePreviewSheet> {
  final DiscoverService _service = DiscoverService();
  late Future<LanguagePreview> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getLanguagePreview(widget.code);
  }

  void _retry() {
    setState(() => _future = _service.getLanguagePreview(widget.code));
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _kOrange.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.menu_book_rounded, color: _kOrange),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PROGRAMME COMPLET',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        Text(
                          widget.name,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1A1A2E)),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: FutureBuilder<LanguagePreview>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: _kOrange),
                    );
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.cloud_off_rounded,
                                size: 40, color: Colors.red.shade300),
                            const SizedBox(height: 12),
                            const Text(
                              'Impossible de charger le programme.',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 14),
                            ElevatedButton.icon(
                              onPressed: _retry,
                              icon: const Icon(Icons.refresh_rounded, size: 17),
                              label: const Text('Réessayer'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _kOrange,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  final preview = snapshot.data!;
                  return ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    itemCount: preview.levels.length,
                    itemBuilder: (_, i) => _buildLevelSection(preview.levels[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelSection(PreviewLevel level) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _kOrange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  level.code,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  level.name,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A2E)),
                ),
              ),
            ],
          ),
          if (level.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              level.description,
              style: TextStyle(
                  fontSize: 12.5, color: Colors.grey.shade600, height: 1.4),
            ),
          ],
          const SizedBox(height: 10),
          ...level.modules.map(_buildModuleTile),
        ],
      ),
    );
  }

  Widget _buildModuleTile(PreviewModule module) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
          title: Text(
            module.title,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E)),
          ),
          subtitle: module.description.isNotEmpty
              ? Text(
                  module.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style:
                      TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                )
              : null,
          children: module.themes
              .map((theme) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Icon(Icons.circle,
                              size: 6, color: _kOrange),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                theme.title,
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1A1A2E)),
                              ),
                              if (theme.description.isNotEmpty)
                                Text(
                                  theme.description,
                                  style: TextStyle(
                                      fontSize: 11.5,
                                      color: Colors.grey.shade600,
                                      height: 1.3),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

// ── Méta-données par langue ────────────────────────────────────────────────────

class _LangMeta {
  final String emoji;
  final Color color;
  final String region;
  const _LangMeta(this.emoji, this.color, this.region);
}

_LangMeta _getMeta(String name) {
  final n = name.toLowerCase();
  if (n.contains('dioula') || n.contains('jula')) {
    return const _LangMeta('🌍', Color(0xFF43A047), "Afrique de l'Ouest");
  }
  if (n.contains('mooré') || n.contains('moore') || n.contains('mossi')) {
    return const _LangMeta('☀️', Color(0xFFF27F22), 'Peuple Mossi, Burkina Faso');
  }
  if (n.contains('fulfuldé') || n.contains('fulfulde') || n.contains('peul')) {
    return const _LangMeta('🌿', Color(0xFF1E88E5), 'Peuple Peul, Sahel');
  }
  if (n.contains('bissa') || n.contains('bisa')) {
    return const _LangMeta('🎵', Color(0xFF8E24AA), 'Peuple Bissa');
  }
  if (n.contains('gourmantché') || n.contains('gurma')) {
    return const _LangMeta('🌺', Color(0xFFE91E63), 'Est du Burkina Faso');
  }
  return const _LangMeta('🗣️', Color(0xFF00897B), 'Langue africaine');
}
