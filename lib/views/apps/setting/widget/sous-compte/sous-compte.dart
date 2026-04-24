import 'package:fasolingo/controller/apps/settings/children_controller.dart';
import 'package:fasolingo/views/apps/setting/widget/sous-compte/child_languages_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fasolingo/models/child_model.dart';

const Color _scOrange  = Color(0xFFFF7043);
const Color _scOrange2 = Color(0xFFFFB74D);

class SousCompte extends StatefulWidget {
  const SousCompte({super.key});

  @override
  State<SousCompte> createState() => _SousCompteState();
}

class _SousCompteState extends State<SousCompte> {
  final ChildrenController controller = Get.put(ChildrenController());
  final TextEditingController searchController = TextEditingController();
  final List<Map<String, dynamic>> hardcodedAccounts = const [];

  Future<void> _openCreateSubAccountSheet() async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CreateSubAccountBottomSheet(controller: controller),
    );
    if (created == true && mounted) {
      _showChooseLanguageInfo();
    }
  }

  void _showChooseLanguageInfo() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_scOrange, _scOrange2],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _scOrange.withValues(alpha: 0.30),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(Icons.language_rounded,
                  color: Colors.white, size: 30),
            ),
            const SizedBox(height: 18),
            const Text(
              'Apprenant créé !',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Veuillez choisir une langue d\'apprentissage pour votre sous-compte.\nPour cela, veuillez cliquer sur un sous-compte.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.55,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _scOrange,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text(
                  'Compris !',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<ChildModel> _applySearch(List<ChildModel> data) {
    final q = searchController.text.trim().toLowerCase();
    if (q.isEmpty) return data;
    return data.where((e) {
      final full = e.displayName.toLowerCase();
      final email = (e.email ?? '').toLowerCase();
      final phone = (e.phone ?? '').toLowerCase();
      return full.contains(q) || email.contains(q) || phone.contains(q);
    }).toList();
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
              _buildSearchField(),
              const SizedBox(height: 14),
              _buildInfoCard(),
              const SizedBox(height: 4),
              Expanded(child: _buildList()),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_scOrange, _scOrange2],
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
        children: const [
          Text(
            'Mes Apprenants',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
          ),
          Text(
            'Gerez vos sous-comptes',
            style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _scOrange.withValues(alpha: 0.18), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: searchController,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: 'Rechercher un apprenant...',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: Icon(Icons.search_rounded, color: _scOrange.withValues(alpha: 0.7), size: 22),
          filled: false,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
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
        border: Border.all(color: _scOrange.withValues(alpha: 0.18), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _scOrange.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _scOrange.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.people_alt_rounded, color: _scOrange, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Appuyez sur un apprenant pour gerer ses langues, ou + pour en ajouter un.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return Obx(() {
      final fallback = hardcodedAccounts
          .map((e) => ChildModel.fromJson(e))
          .where((e) => e.id.isNotEmpty)
          .toList();
      final source = controller.children.isNotEmpty
          ? controller.children.toList()
          : fallback;
      final list = _applySearch(source);

      if (controller.isFetching.value && controller.children.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(color: _scOrange),
        );
      }

      if (list.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _scOrange.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_add_alt_1_rounded, color: _scOrange, size: 40),
              ),
              const SizedBox(height: 16),
              Text(
                'Aucun apprenant trouve',
                style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w700, fontSize: 16),
              ),
              const SizedBox(height: 6),
              Text(
                'Ajoutez votre premier apprenant !',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        color: _scOrange,
        onRefresh: controller.fetchMyChildren,
        child: ListView.separated(
          padding: const EdgeInsets.only(bottom: 110),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final child = list[index];
            return InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => Get.to(() => ChildLanguagesPage(child: child)),
              child: _buildAccountTile(child),
            );
          },
        ),
      );
    });
  }

  Widget _buildAccountTile(ChildModel account) {
    final fullName = account.displayName;
    final initial = fullName.isNotEmpty ? fullName.characters.first.toUpperCase() : '?';
    final subtitle = (account.email != null && account.email!.trim().isNotEmpty)
        ? account.email!
        : (account.phone != null && account.phone!.trim().isNotEmpty)
            ? account.phone!
            : 'Aucun contact';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _scOrange.withValues(alpha: 0.15), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [_scOrange, _scOrange2],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: _scOrange.withValues(alpha: 0.30),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              initial,
              style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 18),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName.isEmpty ? 'Sans nom' : fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A)),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right_rounded, color: _scOrange.withValues(alpha: 0.6), size: 22),
        ],
      ),
    );
  }

  Widget _buildFab() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_scOrange, _scOrange2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: _scOrange.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: _openCreateSubAccountSheet,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_rounded, size: 30),
      ),
    );
  }
}

class _CreateSubAccountBottomSheet extends StatefulWidget {
  final ChildrenController controller;
  const _CreateSubAccountBottomSheet({required this.controller});

  @override
  State<_CreateSubAccountBottomSheet> createState() =>
      _CreateSubAccountBottomSheetState();
}

class _CreateSubAccountBottomSheetState
    extends State<_CreateSubAccountBottomSheet> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final ok = await widget.controller.createSubAccount(
      firstName: firstNameController.text.trim(),
      lastName: lastNameController.text.trim(),
      password: passwordController.text,
    );
    if (!mounted) return;
    if (ok) Navigator.of(context).pop(true);
  }

  InputDecoration _fieldDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: _scOrange, size: 20),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _scOrange, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }

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
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _scOrange.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.person_add_rounded, color: _scOrange, size: 20),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Creer un apprenant',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A)),
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
            const SizedBox(height: 18),
            TextFormField(
              controller: firstNameController,
              decoration: _fieldDecoration('Prenom', Icons.badge_outlined),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Prenom obligatoire' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: lastNameController,
              decoration: _fieldDecoration('Nom', Icons.badge_outlined),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Nom obligatoire' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: passwordController,
              obscureText: true,
              decoration: _fieldDecoration('Mot de passe', Icons.lock_outline_rounded),
              validator: (v) => (v == null || v.isEmpty) ? 'Mot de passe obligatoire' : null,
            ),
            const SizedBox(height: 20),
            Obx(() => GestureDetector(
              onTap: widget.controller.isLoading.value ? null : _submit,
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  gradient: widget.controller.isLoading.value
                      ? null
                      : const LinearGradient(
                          colors: [_scOrange, _scOrange2],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                  color: widget.controller.isLoading.value ? Colors.grey.shade300 : null,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: widget.controller.isLoading.value
                      ? []
                      : [BoxShadow(color: _scOrange.withValues(alpha: 0.30), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Center(
                  child: widget.controller.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
                      : const Text(
                          'Creer le compte',
                          style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800),
                        ),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
