import 'package:fasolingo/controller/apps/settings/children_controller.dart';
import 'package:fasolingo/views/apps/setting/widget/child_languages_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fasolingo/model/child_model.dart';

class SousCompte extends StatefulWidget {
  const SousCompte({super.key});

  @override
  State<SousCompte> createState() => _SousCompteState();
}

class _SousCompteState extends State<SousCompte> {
  final ChildrenController controller = Get.put(ChildrenController());

  final TextEditingController searchController = TextEditingController();
  final RxInt selectedFilterIndex = 0.obs;

  final List<Map<String, dynamic>> hardcodedAccounts = const [
    {
      'id': 'local-child-1',
      'username': 'LI-EDU-001',
      'firstName': 'Awa',
      'lastName': 'Diallo',
      'password': 'motdepasse123',
      'email': 'awa@example.com',
      'phone': '+22670123456',
      'profile': {
        'firstName': 'Awa',
        'lastName': 'Diallo',
        'avatarUrl': null,
      },
    },
    {
      'id': 'local-child-2',
      'username': 'LI-EDU-002',
      'firstName': 'Moussa',
      'lastName': 'Traoré',
      'password': 'motdepasse123',
      'email': null,
      'phone': '+22670123457',
      'profile': {
        'firstName': 'Moussa',
        'lastName': 'Traoré',
        'avatarUrl': null,
      },
    },
    {
      'id': 'local-child-3',
      'username': 'LI-EDU-003',
      'firstName': 'Fatou',
      'lastName': 'Ouédraogo',
      'password': 'motdepasse123',
      'email': 'fatou@example.com',
      'phone': null,
      'profile': {
        'firstName': 'Fatou',
        'lastName': 'Ouédraogo',
        'avatarUrl': null,
      },
    },
  ];

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
    return TextField(
      controller: searchController,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: 'Rechercher',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: const Color(0xFFF2F3F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = const ['Tous', 'Avec email', 'Avec téléphone', 'Sans contact'];

    return Obx(
      () => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(filters.length, (i) {
            final selected = selectedFilterIndex.value == i;
            return Padding(
              padding: EdgeInsets.only(right: i == filters.length - 1 ? 0 : 10),
              child: ChoiceChip(
                label: Text(filters[i]),
                selected: selected,
                onSelected: (_) => selectedFilterIndex.value = i,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: selected ? const Color(0xFF2E7D32) : Colors.black87,
                ),
                selectedColor: const Color(0xFFE8F5E9),
                backgroundColor: const Color(0xFFF2F3F5),
                side: BorderSide(
                  color: selected ? const Color(0xFF66BB6A) : Colors.transparent,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  List<ChildModel> _applyFilter(List<ChildModel> data) {
    final idx = selectedFilterIndex.value;
    if (idx == 0) return data;

    bool hasEmail(ChildModel e) => (e.email ?? '').trim().isNotEmpty;
    bool hasPhone(ChildModel e) => (e.phone ?? '').trim().isNotEmpty;

    switch (idx) {
      case 1:
        return data.where(hasEmail).toList();
      case 2:
        return data.where(hasPhone).toList();
      case 3:
        return data.where((e) => !hasEmail(e) && !hasPhone(e)).toList();
      default:
        return data;
    }
  }

  Widget _buildAccountTile(ChildModel account) {
    final fullName = account.displayName;
    final email = account.email;
    final phone = account.phone;

    final initial = fullName.isNotEmpty
        ? fullName.characters.first.toUpperCase()
        : '?';

    final subtitleLine = (email != null && email.trim().isNotEmpty)
        ? email
        : (phone != null && phone.trim().isNotEmpty)
            ? phone
            : 'Aucun contact';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFE8F5E9),
              border: Border.all(color: const Color(0xFF66BB6A), width: 1),
            ),
            alignment: Alignment.center,
            child: Text(
              initial,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: Color(0xFF2E7D32),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName.isEmpty ? 'Sans nom' : fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitleLine,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F3F5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  (phone != null && phone.trim().isNotEmpty) ? 'Actif' : '—',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Icon(Icons.chevron_right, color: Colors.grey.shade500),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        title: const Text('Sous comptes'),
        backgroundColor: const Color(0xFFF6F7F9),
        elevation: 0,
        surfaceTintColor: const Color(0xFFF6F7F9),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Column(
            children: [
              _buildSearchField(),
              const SizedBox(height: 12),
              _buildFilterChips(),
              const SizedBox(height: 16),
              Expanded(
                child: Obx(() {
                  final fallback = hardcodedAccounts
                      .map((e) => ChildModel.fromJson(e))
                      .where((e) => e.id.isNotEmpty)
                      .toList();
                  final source = controller.children.isNotEmpty
                      ? controller.children.toList()
                      : fallback;
                  final list = _applyFilter(_applySearch(source));

                  if (controller.isFetching.value && controller.children.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (list.isEmpty) {
                    return Center(
                      child: Text(
                        'Aucun sous-compte',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
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
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Get.to(
                              () => ChildLanguagesPage(child: child),
                            );
                          },
                          child: _buildAccountTile(child),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateSubAccountSheet,
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add, size: 30),
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
                  'Créer un sous-compte',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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
