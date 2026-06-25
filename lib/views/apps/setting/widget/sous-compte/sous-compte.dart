import 'package:tibi/controller/apps/settings/children_controller.dart';
import 'package:tibi/helpers/theme/app_colors.dart';
import 'package:tibi/views/apps/setting/widget/sous-compte/child_languages_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tibi/models/child_model.dart';

const Color _kGreen      = Color(0xFF188329);
const Color _kOrange     = Color(0xFFF27F22);


class SousCompte extends StatefulWidget {
  const SousCompte({super.key});

  @override
  State<SousCompte> createState() => _SousCompteState();
}

class _SousCompteState extends State<SousCompte> {
  final ChildrenController controller = Get.put(ChildrenController());
  final TextEditingController _searchCtrl = TextEditingController();
  late BuildContext _ctx;

  Future<void> _openCreateSheet() async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CreateSubAccountBottomSheet(controller: controller),
    );
    if (created == true && mounted) _showSuccessInfo();
  }

  void _showSuccessInfo() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: AppColors.card(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(color: AppColors.divider(context), borderRadius: BorderRadius.circular(2)),
            ),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [_kOrange, _kOrange], begin: Alignment.topLeft, end: Alignment.bottomRight),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: _kOrange.withValues(alpha: 0.30), blurRadius: 18, offset: const Offset(0, 7))],
              ),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 18),
            Text('Apprenant créé !',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary(context))),
            const SizedBox(height: 10),
            Text(
              'Appuyez sur le profil de l\'apprenant pour lui attribuer une langue d\'apprentissage.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary(context), height: 1.6),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kOrange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text('Compris !',
                    style: TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<ChildModel> _filtered(List<ChildModel> data) {
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return data;
    return data.where((e) {
      return e.displayName.toLowerCase().contains(q) ||
          (e.email ?? '').toLowerCase().contains(q) ||
          (e.phone ?? '').toLowerCase().contains(q);
    }).toList();
  }

  Color _avatarColor(String name) {
    const colors = [
      Color(0xFF188329), Color(0xFF0284C7), Color(0xFF7C3AED),
      Color(0xFFEA580C), Color(0xFF0891B2), Color(0xFFDB2777),
    ];
    return colors[name.hashCode.abs() % colors.length];
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
          Expanded(child: _buildList()),
        ],
      ),
      floatingActionButton: _buildFab(),
    );
  }

  // ── Header avec recherche intégrée ──────────────────────────────────────────

  Widget _buildHeader(double topPad) {
    return Obx(() {
      final count = controller.children.length;
      return Container(
        padding: EdgeInsets.fromLTRB(20, topPad + 16, 20, 22),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_kOrange, _kOrange],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─ Ligne haut : retour + badge + nouveau ─
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
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
                // Badge compteur jaune
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                  decoration: BoxDecoration(
                    color: _kOrange,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: _kOrange.withValues(alpha: 0.45), blurRadius: 8, offset: const Offset(0, 3))],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.people_rounded, size: 13, color: Color(0xFF1A1A1A)),
                      const SizedBox(width: 5),
                      Text('$count',
                          style: const TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.w900, fontSize: 14)),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // Bouton Nouveau — blanc sur orange
                GestureDetector(
                  onTap: _openCreateSheet,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.10), blurRadius: 8, offset: const Offset(0, 3))],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_rounded, color: _kOrange, size: 16),
                        const SizedBox(width: 5),
                        Text('Nouveau', style: TextStyle(color: _kOrange, fontWeight: FontWeight.w800, fontSize: 13)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // ─ Titre + icône déco ─
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Mes Apprenants',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 28,
                              letterSpacing: -0.6)),
                      SizedBox(height: 5),
                      Text('Gérez et suivez vos sous-comptes',
                          style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w400)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                  ),
                  child: const Icon(Icons.school_rounded, color: Colors.white, size: 26),
                ),
              ],
            ),
            const SizedBox(height: 18),
            // ─ Recherche intégrée (style verre dépoli) ─
            Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  const Icon(Icons.search_rounded, color: Colors.white70, size: 19),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (_) => setState(() {}),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'Rechercher un apprenant...',
                        hintStyle: TextStyle(color: Colors.white54, fontSize: 14),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  if (_searchCtrl.text.isNotEmpty) ...[
                    GestureDetector(
                      onTap: () { _searchCtrl.clear(); setState(() {}); },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Icon(Icons.close_rounded, color: Colors.white70, size: 17),
                      ),
                    ),
                  ] else
                    const SizedBox(width: 12),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  // ── Liste ────────────────────────────────────────────────────────────────────

  Widget _buildList() {
    return Obx(() {
      final list = _filtered(controller.children.toList());

      if (controller.isFetching.value && controller.children.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(color: _kOrange, strokeWidth: 2.5),
        );
      }

      if (list.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 90, height: 90,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [_kOrange, _kOrange], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: _kOrange.withValues(alpha: 0.30), blurRadius: 24, offset: const Offset(0, 8))],
                  ),
                  child: const Icon(Icons.people_alt_outlined, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 22),
                Text('Aucun apprenant',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary(_ctx))),
                const SizedBox(height: 9),
                Text(
                  'Appuyez sur "Nouveau" pour ajouter\nvotre premier apprenant.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary(_ctx), fontSize: 14, height: 1.55),
                ),
                const SizedBox(height: 28),
                GestureDetector(
                  onTap: _openCreateSheet,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [_kOrange, _kOrange]),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [BoxShadow(color: _kOrange.withValues(alpha: 0.32), blurRadius: 14, offset: const Offset(0, 5))],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person_add_rounded, color: Colors.white, size: 17),
                        SizedBox(width: 8),
                        Text('Ajouter un apprenant',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return RefreshIndicator(
        color: _kOrange,
        onRefresh: controller.fetchMyChildren,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 110),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) => GestureDetector(
            onTap: () => Get.to(() => ChildLanguagesPage(child: list[i])),
            child: _buildTile(list[i]),
          ),
        ),
      );
    });
  }

  // ── Tuile apprenant ──────────────────────────────────────────────────────────

  Widget _buildTile(ChildModel child) {
    final name    = child.displayName;
    final initial = name.isNotEmpty ? name.characters.first.toUpperCase() : '?';
    final subtitle = (child.email != null && child.email!.trim().isNotEmpty)
        ? child.email!
        : (child.phone != null && child.phone!.trim().isNotEmpty)
            ? child.phone!
            : 'Aucun contact';
    final color = _avatarColor(name);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card(_ctx),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: AppColors.shadow(_ctx), blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          children: [
            // ─ Contenu principal ─
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Avatar carré arrondi + dot actif
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 52, height: 52,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [color, color.withValues(alpha: 0.75)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(color: color.withValues(alpha: 0.38), blurRadius: 12, offset: const Offset(0, 4)),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(initial,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
                      ),
                      // Dot vert actif
                      Positioned(
                        top: -2, right: -2,
                        child: Container(
                          width: 13, height: 13,
                          decoration: BoxDecoration(
                            color: _kGreen,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  // Nom + contact
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name.isEmpty ? 'Sans nom' : name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary(_ctx)),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.mail_outline_rounded, size: 12, color: Colors.grey.shade400),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Chevron dans conteneur
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: Color(0xFF9CA3AF)),
                  ),
                ],
              ),
            ),
            // ─ Barre d'action bas ─
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 11),
              decoration: BoxDecoration(
                color: AppColors.cardAlt(_ctx),
                border: Border(top: BorderSide(color: AppColors.divider(_ctx))),
              ),
              child: Row(
                children: [
                  // Gérer les langues — orange
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: _kOrange.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: const Icon(Icons.language_rounded, size: 13, color: _kOrange),
                      ),
                      const SizedBox(width: 7),
                      const Text('Gérer les langues',
                          style: TextStyle(fontSize: 12, color: _kOrange, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const Spacer(),
                  // Statut actif — vert
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7, height: 7,
                        decoration: const BoxDecoration(color: _kGreen, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 5),
                      const Text('Actif',
                          style: TextStyle(fontSize: 12, color: Color(0xFF6B7280), fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── FAB ──────────────────────────────────────────────────────────────────────

  Widget _buildFab() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_kOrange, _kOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: _kOrange.withValues(alpha: 0.42), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: FloatingActionButton(
        onPressed: _openCreateSheet,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }
}

// ── Bottom sheet création ────────────────────────────────────────────────────

class _CreateSubAccountBottomSheet extends StatefulWidget {
  final ChildrenController controller;
  const _CreateSubAccountBottomSheet({required this.controller});

  @override
  State<_CreateSubAccountBottomSheet> createState() =>
      _CreateSubAccountBottomSheetState();
}

class _CreateSubAccountBottomSheetState extends State<_CreateSubAccountBottomSheet> {
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl  = TextEditingController();
  final _passwordCtrl  = TextEditingController();
  final _formKey       = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final ok = await widget.controller.createSubAccount(
      firstName: _firstNameCtrl.text.trim(),
      lastName:  _lastNameCtrl.text.trim(),
      password:  _passwordCtrl.text,
    );
    if (!mounted) return;
    if (ok) Navigator.of(context).pop(true);
  }

  InputDecoration _dec(String label, IconData icon, {Widget? suffix}) {
    final ctx = context;
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: AppColors.textSecondary(ctx), fontSize: 14, fontWeight: FontWeight.w500),
      prefixIcon: Icon(icon, color: AppColors.textSecondary(ctx), size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: AppColors.inputFill(ctx),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _kOrange, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEF4444)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 8, 20, 20 + bottomInset),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(color: AppColors.divider(context), borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF9E0),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _kOrange.withValues(alpha: 0.22)),
                  ),
                  child: const Icon(Icons.person_add_rounded, color: _kOrange, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Créer un apprenant',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
                      Text('Remplissez les informations ci-dessous',
                          style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(color: Color(0xFFF3F4F6), shape: BoxShape.circle),
                    child: const Icon(Icons.close_rounded, color: Color(0xFF9CA3AF), size: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            TextFormField(
              controller: _firstNameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: _dec('Prénom', Icons.badge_outlined),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Prénom obligatoire' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _lastNameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: _dec('Nom de famille', Icons.badge_outlined),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Nom obligatoire' : null,
            ),
            const SizedBox(height: 12),
            StatefulBuilder(
              builder: (_, setSt) => TextFormField(
                controller: _passwordCtrl,
                obscureText: _obscurePassword,
                decoration: _dec(
                  'Mot de passe',
                  Icons.lock_outline_rounded,
                  suffix: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                      color: const Color(0xFF9CA3AF), size: 20,
                    ),
                    onPressed: () => setSt(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Mot de passe obligatoire' : null,
              ),
            ),
            const SizedBox(height: 24),
            Obx(() {
              final loading = widget.controller.isLoading.value;
              return GestureDetector(
                onTap: loading ? null : _submit,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: loading
                        ? null
                        : const LinearGradient(colors: [_kOrange, _kOrange], begin: Alignment.centerLeft, end: Alignment.centerRight),
                    color: loading ? const Color(0xFFF3F4F6) : null,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: loading
                        ? []
                        : [BoxShadow(color: _kOrange.withValues(alpha: 0.30), blurRadius: 14, offset: const Offset(0, 5))],
                  ),
                  child: Center(
                    child: loading
                        ? const SizedBox(
                            height: 22, width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.5, color: _kOrange))
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.person_add_rounded, color: Colors.white, size: 18),
                              SizedBox(width: 8),
                              Text('Créer le compte',
                                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
                            ],
                          ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
