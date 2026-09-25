import 'package:flutter/material.dart';
import 'package:tibi/models/langue/decouverte_model.dart';

// Palette inspirée de la maquette "leçon culturelle"
const Color _terra     = Color(0xFFBF4E2C);
const Color _terraSoft = Color(0xFFF3D9C8);
const Color _terraDeep = Color(0xFF8F3A1F);
const Color _indigo     = Color(0xFF33455E);
const Color _indigoSoft = Color(0xFFDCE1E8);
const Color _gold     = Color(0xFFAD7A1E);
const Color _goldSoft = Color(0xFFF1DFB0);
const Color _green     = Color(0xFF2E6B4C);
const Color _greenSoft = Color(0xFFD9E7DE);
const Color _ink       = Color(0xFF241A12);

// Affiche un contenu de type "course" (leçon démo) en cartes par section,
// une par bloc (introduction / vocabulaire / exemples / points clés / résumé).
class StepDiscoveryCourse extends StatelessWidget {
  final DemoContent content;

  const StepDiscoveryCourse({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final blocks = [...content.blocks]
      ..sort((a, b) => a.index.compareTo(b.index));

    final vocabTerms = blocks
        .where((b) => b.sectionType == 'lesson')
        .expand((b) => _parseVocab(b.content))
        .map((e) => e.key)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildIdentity(),
          const SizedBox(height: 22),
          if (blocks.isEmpty && content.summary != null)
            _buildParagraphCard(
              meta: _metaFor('introduction'),
              label: 'Objectif',
              text: content.summary!,
            )
          else
            for (final block in blocks) _buildSectionCard(block, vocabTerms),
        ],
      ),
    );
  }

  // ── En-tête ────────────────────────────────────────────────────────────────

  Widget _buildIdentity() {
    return Column(
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [_green, Color(0xFF16402C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: _green.withValues(alpha: 0.35),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.auto_awesome_rounded,
              color: Colors.white, size: 32),
        ),
        const SizedBox(height: 12),
        Text(
          'COURS',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content.title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w800,
            color: _ink,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  // ── Cartes de section ──────────────────────────────────────────────────────

  Widget _buildSectionCard(DemoBlock block, List<String> vocabTerms) {
    final meta = _metaFor(block.sectionType);
    final label = (block.caption != null && block.caption!.trim().isNotEmpty)
        ? block.caption!
        : _fallbackLabel(block.sectionType);

    switch (block.sectionType) {
      case 'lesson':
        final pairs = _parseVocab(block.content);
        if (pairs.isEmpty) {
          return _buildParagraphCard(meta: meta, label: label, text: block.content);
        }
        return _buildCard(
          meta: meta,
          label: label,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < pairs.length; i++)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    border: i == 0
                        ? null
                        : Border(top: BorderSide(color: Colors.grey.shade200)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 86,
                        child: Text(
                          pairs[i].key,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13.5,
                              color: _terraDeep),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          pairs[i].value,
                          style: TextStyle(
                              fontSize: 13, color: Colors.grey.shade700, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );

      case 'example':
        final rows = _parseExamples(block.content);
        if (rows.isEmpty) {
          return _buildParagraphCard(meta: meta, label: label, text: block.content);
        }
        return _buildCard(
          meta: meta,
          label: label,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < rows.length; i++)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    border: i == 0
                        ? null
                        : Border(top: BorderSide(color: Colors.grey.shade200)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _greenSoft,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('${i + 1}',
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _green)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(rows[i].key,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13.5,
                                    color: _ink)),
                            if (rows[i].value.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(rows[i].value,
                                  style: TextStyle(
                                      fontSize: 12.5, color: Colors.grey.shade600)),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );

      case 'key_point':
        final bullets = _splitSentences(block.content);
        return _buildCard(
          meta: meta,
          label: label,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final bullet in bullets)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Transform.rotate(
                          angle: 0.78,
                          child: Container(
                            width: 6,
                            height: 6,
                            color: _gold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(bullet,
                            style: const TextStyle(fontSize: 13.5, height: 1.5, color: _ink)),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );

      case 'summary':
        return _buildCard(
          meta: meta,
          label: label,
          dark: true,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(block.content,
                  style: const TextStyle(fontSize: 14, height: 1.5, color: Color(0xFFEFE4D0))),
              if (vocabTerms.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: vocabTerms
                      .map((term) => Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(7),
                              border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.2)),
                            ),
                            child: Text(term,
                                style: const TextStyle(
                                    fontSize: 11, color: Color(0xFFF4E9D6))),
                          ))
                      .toList(),
                ),
              ],
            ],
          ),
        );

      case 'introduction':
      default:
        return _buildParagraphCard(meta: meta, label: label, text: block.content);
    }
  }

  Widget _buildParagraphCard({
    required _SectionMeta meta,
    required String label,
    required String text,
  }) {
    return _buildCard(
      meta: meta,
      label: label,
      dark: meta.dark,
      body: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          height: 1.55,
          color: meta.dark ? const Color(0xFFEFE4D0) : _ink,
        ),
      ),
    );
  }

  Widget _buildCard({
    required _SectionMeta meta,
    required String label,
    required Widget body,
    bool dark = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: dark ? _ink : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: dark ? null : Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(width: 4, color: meta.accent),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 14, 15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: dark
                              ? Colors.white.withValues(alpha: 0.12)
                              : meta.iconBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(meta.icon,
                            size: 14, color: dark ? Colors.white : meta.iconFg),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          label.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                            color: dark ? const Color(0xFFE8D9BF) : meta.iconFg,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  body,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Parsing best-effort du texte des blocks ────────────────────────────────

List<MapEntry<String, String>> _parseVocab(String content) {
  final pairs = <MapEntry<String, String>>[];
  for (final sentence in content.split('. ')) {
    final s = sentence.trim();
    final idx = s.indexOf(' = ');
    if (idx <= 0) continue;
    final term = s.substring(0, idx).trim();
    var definition = s.substring(idx + 3).trim();
    if (definition.endsWith('.')) {
      definition = definition.substring(0, definition.length - 1);
    }
    if (term.isNotEmpty && definition.isNotEmpty) {
      pairs.add(MapEntry(term, definition));
    }
  }
  return pairs;
}

List<MapEntry<String, String>> _parseExamples(String content) {
  final rows = <MapEntry<String, String>>[];
  final parts = content
      .split(RegExp(r'\d+\)\s*'))
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty);
  for (final part in parts) {
    final idx = part.indexOf('→');
    if (idx > 0) {
      rows.add(MapEntry(
        part.substring(0, idx).trim(),
        part.substring(idx + 1).trim(),
      ));
    } else {
      rows.add(MapEntry(part, ''));
    }
  }
  return rows;
}

List<String> _splitSentences(String content) {
  return content
      .split('. ')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .map((s) => s.endsWith('.') ? s : '$s.')
      .toList();
}

class _SectionMeta {
  final IconData icon;
  final Color accent;
  final Color iconBg;
  final Color iconFg;
  final bool dark;

  const _SectionMeta({
    required this.icon,
    required this.accent,
    required this.iconBg,
    required this.iconFg,
    this.dark = false,
  });
}

_SectionMeta _metaFor(String sectionType) {
  switch (sectionType) {
    case 'introduction':
      return const _SectionMeta(
        icon: Icons.track_changes_rounded,
        accent: _indigo,
        iconBg: _indigoSoft,
        iconFg: _indigo,
      );
    case 'lesson':
      return const _SectionMeta(
        icon: Icons.menu_book_rounded,
        accent: _terra,
        iconBg: _terraSoft,
        iconFg: _terraDeep,
      );
    case 'example':
      return const _SectionMeta(
        icon: Icons.forum_rounded,
        accent: _green,
        iconBg: _greenSoft,
        iconFg: _green,
      );
    case 'key_point':
      return const _SectionMeta(
        icon: Icons.auto_awesome_rounded,
        accent: _gold,
        iconBg: _goldSoft,
        iconFg: _gold,
      );
    case 'summary':
      return const _SectionMeta(
        icon: Icons.check_circle_rounded,
        accent: _ink,
        iconBg: Colors.white24,
        iconFg: Colors.white,
        dark: true,
      );
    default:
      return const _SectionMeta(
        icon: Icons.info_rounded,
        accent: _indigo,
        iconBg: _indigoSoft,
        iconFg: _indigo,
      );
  }
}

String _fallbackLabel(String sectionType) {
  switch (sectionType) {
    case 'introduction':
      return 'Objectif';
    case 'lesson':
      return 'Vocabulaire';
    case 'example':
      return 'Exemples';
    case 'key_point':
      return 'Points clés';
    case 'summary':
      return 'Résumé';
    default:
      return 'Contenu';
  }
}
