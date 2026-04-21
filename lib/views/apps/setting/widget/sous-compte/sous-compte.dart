import 'package:fasolingo/controller/apps/settings/children_controller.dart';
import 'package:fasolingo/views/apps/setting/widget/sous-compte/child_languages_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fasolingo/models/child_model.dart';

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
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CreateSubAccountBottomSheet(
        controller: controller,
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

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF9C4), Color(0xFFE8F5E9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: searchController,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: 'Rechercher un apprenant',
          prefixIcon: const Icon(Icons.search, color: Color(0xFFFFC107)),
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildAccountTile(ChildModel account, int index) {
    final fullName = account.displayName;
    final email = account.email;
    final phone = account.phone;

    final initial =
        fullName.isNotEmpty ? fullName.characters.first.toUpperCase() : '?';

    final subtitleLine = (email != null && email.trim().isNotEmpty)
        ? '$email'
        : (phone != null && phone.trim().isNotEmpty)
            ? ' $phone'
            : 'Aucun contact';

    // Fun colors for each tile
    final tileColors = [
      const Color(0xFFFFF3E0), // Light orange
      const Color(0xFFFFF9C4), // Light yellow
      const Color(0xFFE3F2FD), // Light blue
      const Color(0xFFFCE4EC), // Light pink
      const Color(0xFFF3E5F5), // Light purple
    ];
    final color = tileColors[index % tileColors.length];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 10,
            offset: Offset(0, 5),
          )
        ],
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
      ),
      child: Row(
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [const Color(0xFFFF9800), const Color(0xFFFFC107)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x29000000),
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              initial,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      fullName.isEmpty ? 'Sans nom' : fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1565C0),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text('', style: TextStyle(fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitleLine,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          const Icon(Icons.chevron_right, color: Color(0xFFFF9800), size: 24),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color(0xFFE3F2FD), // Light blue background for a fun feel
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios_new)),
        title: const Text(
          ' Mes Petits Apprenants',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1565C0),
          ),
        ),
        //backgroundColor: const Color(0xFFE3F2FD),
        elevation: 0,
        //surfaceTintColor: const Color(0xFFE3F2FD),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Column(
            children: [
              _buildSearchField(),
              const SizedBox(height: 16),
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
                    const SizedBox(width: 8),
                    Text(
                      'Liste de mes apprenants',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.orange.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Clique sur un apprenant pour gérer ses langues, ou utilise le bouton + pour en ajouter un nouveau et agrandir ta petite équipe !',
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
                  final fallback = hardcodedAccounts
                      .map((e) => ChildModel.fromJson(e))
                      .where((e) => e.id.isNotEmpty)
                      .toList();
                  final source = controller.children.isNotEmpty
                      ? controller.children.toList()
                      : fallback;
                  final list = _applySearch(source);

                  if (controller.isFetching.value &&
                      controller.children.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (list.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            '',
                            style: TextStyle(fontSize: 48),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Aucun apprenant trouvé',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Ajoute ton premier apprenant !',
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
                    onRefresh: controller.fetchMyChildren,
                    child: ListView.separated(
                      padding: const EdgeInsets.only(bottom: 110),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final child = list[index];
                        return InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            Get.to(
                              () => ChildLanguagesPage(child: child),
                            );
                          },
                          child: _buildAccountTile(child, index),
                        );
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF9800), Color(0xFFFFC107)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Color(0x29000000),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _openCreateSubAccountSheet,
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
          child: const Icon(Icons.add, size: 32),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class _CreateSubAccountBottomSheet extends StatefulWidget {
  final ChildrenController controller;

  const _CreateSubAccountBottomSheet({
    required this.controller,
  });

  @override
  State<_CreateSubAccountBottomSheet> createState() =>
      _CreateSubAccountBottomSheetState();
}

class _CreateSubAccountBottomSheetState
    extends State<_CreateSubAccountBottomSheet> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    passwordController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final ok = await widget.controller.createSubAccount(
      firstName: firstNameController.text.trim(),
      lastName: lastNameController.text.trim(),
      password: passwordController.text,
      email: emailController.text,
      phone: phoneController.text,
    );

    if (!mounted) return;
    if (ok) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: 16 + bottomInset,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Créer un nouvel apprenti',
                  style: TextStyle(
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
            TextFormField(
              controller: firstNameController,
              decoration: const InputDecoration(labelText: 'Prénom'),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Prénom obligatoire';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: lastNameController,
              decoration: const InputDecoration(labelText: 'Nom'),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Nom obligatoire';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Mot de passe'),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Mot de passe obligatoire';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email (optionnel)'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: phoneController,
              decoration:
                  const InputDecoration(labelText: 'Téléphone (optionnel)'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            Obx(
              () => ElevatedButton(
                onPressed: widget.controller.isLoading.value ? null : _submit,
                child: widget.controller.isLoading.value
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Créer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
