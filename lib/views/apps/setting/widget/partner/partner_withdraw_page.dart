import 'package:tibi/helpers/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

const double _soldeDisponible = 8000;
const Color _kOrange     = Color(0xFFF27F22);


class PartnerWithdrawPage extends StatefulWidget {
  const PartnerWithdrawPage({super.key});

  @override
  State<PartnerWithdrawPage> createState() => _PartnerWithdrawPageState();
}

class _PartnerWithdrawPageState extends State<PartnerWithdrawPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  late BuildContext _ctx;

  int _selectedMethodIndex = 0;
  bool _isSubmitting = false;

  static const _methods = [
    _PayMethod(name: 'Orange Money', logo: Icons.circle, color: Color(0xFFFF6900), bg: Color(0xFFFFF0E5)),
    _PayMethod(name: 'Moov Money',   logo: Icons.circle, color: Color(0xFF0066CC), bg: Color(0xFFFFF0E5)),
  ];

  double get _montantSaisi =>
      double.tryParse(_amountCtrl.text.replaceAll(' ', '')) ?? 0;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    _showSuccessSheet();
  }

  void _showSuccessSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: AppColors.card(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4,
                decoration: BoxDecoration(color: AppColors.divider(context), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 32),
            Container(
              width: 72, height: 72,
              decoration: const BoxDecoration(color: Color(0xFFFFF9E0), shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded, color: _kOrange, size: 36),
            ),
            const SizedBox(height: 20),
            Text(
              'Demande envoyee !',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary(context)),
            ),
            const SizedBox(height: 10),
            Text(
              'Votre demande de retrait de ${_amountCtrl.text} FCFA\nest en cours de traitement.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary(context), height: 1.5),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kOrange, foregroundColor: const Color(0xFF1A1A1A),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Retour au tableau de bord',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _ctx = context;
    return Scaffold(
      backgroundColor: AppColors.bgPartner(context),
      appBar: AppBar(
        backgroundColor: AppColors.card(context),
        surfaceTintColor: AppColors.card(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, size: 18, color: AppColors.textPrimary(context)),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Demande de retrait',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary(context)),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildSoldeCard(),
            const SizedBox(height: 24),
            _buildAmountSection(),
            const SizedBox(height: 24),
            _buildMethodSection(),
            const SizedBox(height: 24),
            _buildPhoneSection(),
            const SizedBox(height: 24),
            _buildRecap(),
            const SizedBox(height: 32),
            _buildSubmitButton(),
            const SizedBox(height: 16),
            _buildNote(),
          ],
        ),
      ),
    );
  }

  // ── Solde disponible ────────────────────────────────────────────────────────

  Widget _buildSoldeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_kOrange, _kOrange],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: _kOrange.withValues(alpha: 0.30), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.savings_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Solde disponible',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13, fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '8 000 FCFA',
                  style: TextStyle(
                    color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Disponible',
              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // ── Montant ─────────────────────────────────────────────────────────────────

  Widget _buildAmountSection() {
    return _section(
      title: 'Montant a retirer',
      icon: Icons.payments_rounded,
      iconColor: _kOrange,
      iconBg: const Color(0xFFFFF9E0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _amountCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (_) => setState(() {}),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary(_ctx)),
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 18),
              suffixText: 'FCFA',
              suffixStyle: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF),
              ),
              filled: true, fillColor: AppColors.inputFill(_ctx),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                borderSide: const BorderSide(color: _kOrange, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Colors.redAccent),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Veuillez saisir un montant';
              final val = double.tryParse(v);
              if (val == null || val <= 0) return 'Montant invalide';
              if (val > _soldeDisponible) return 'Montant superieur au solde disponible';
              return null;
            },
          ),
          const SizedBox(height: 12),
          // Raccourcis montant
          Row(
            children: [500, 2000, 5000, 8000].map((v) {
              final label = v == 8000 ? 'Tout' : '$v';
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    _amountCtrl.text = v.toString();
                    setState(() {});
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: _montantSaisi == v ? _kOrange : AppColors.card(_ctx),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _montantSaisi == v ? _kOrange : const Color(0xFFE5E7EB),
                      ),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600,
                        color: _montantSaisi == v ? const Color(0xFF1A1A1A) : const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── Méthode de paiement ─────────────────────────────────────────────────────

  Widget _buildMethodSection() {
    return _section(
      title: 'Methode de paiement',
      icon: Icons.account_balance_wallet_rounded,
      iconColor:  Colors.black,
      iconBg:  Colors.grey.shade200,
      child: Column(
        children: _methods.asMap().entries.map((e) {
          final i = e.key;
          final m = e.value;
          final isSelected = _selectedMethodIndex == i;
          return Padding(
            padding: EdgeInsets.only(bottom: i < _methods.length - 1 ? 10 : 0),
            child: GestureDetector(
              onTap: () => setState(() => _selectedMethodIndex = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected ? m.bg : AppColors.card(_ctx),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? m.color : const Color(0xFFE5E7EB),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(color: m.bg, borderRadius: BorderRadius.circular(10)),
                      child: Icon(Icons.account_balance_wallet_rounded, color: m.color, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        m.name,
                        style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600,
                          color: isSelected ? m.color : const Color(0xFF1A1A1A),
                        ),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 22, height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? m.color : Colors.transparent,
                        border: Border.all(
                          color: isSelected ? m.color : const Color(0xFFD1D5DB),
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check_rounded, color: Colors.white, size: 13)
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Numéro de téléphone ─────────────────────────────────────────────────────

  Widget _buildPhoneSection() {
    return _section(
      title: 'Numero ${_methods[_selectedMethodIndex].name}',
      icon: Icons.phone_android_rounded,
      iconColor:  Colors.black,
      iconBg: Colors.grey.shade200,
      child: TextFormField(
        controller: _phoneCtrl,
        keyboardType: TextInputType.phone,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          hintText: 'Ex: 0612345678',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: const Icon(Icons.phone_rounded, color: Color(0xFF9CA3AF), size: 20),
          filled: true, fillColor: AppColors.inputFill(_ctx),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
            borderSide: const BorderSide(color: _kOrange, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.redAccent),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
          ),
        ),
        validator: (v) {
          if (v == null || v.isEmpty) return 'Numero requis';
          if (v.length < 8) return 'Numero invalide';
          return null;
        },
      ),
    );
  }

  // ── Récapitulatif ───────────────────────────────────────────────────────────

  Widget _buildRecap() {
    final montant = _montantSaisi;
    final frais = montant > 0 ? (montant * 0.01).roundToDouble() : 0.0;
    final net = montant > 0 ? montant - frais : 0.0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recapitulatif',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
          const SizedBox(height: 14),
          _recapRow('Montant demande',  montant > 0 ? '${montant.toStringAsFixed(0)} FCFA' : '—',  false),
          const SizedBox(height: 8),
          _recapRow('Frais de traitement', montant > 0 ? '- ${frais.toStringAsFixed(0)} FCFA' : '—', false),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: Color(0xFFF3F4F6)),
          ),
          _recapRow('Montant net recu', net > 0 ? '${net.toStringAsFixed(0)} FCFA' : '—', true),
        ],
      ),
    );
  }

  Widget _recapRow(String label, String value, bool isTotal) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
              fontSize: isTotal ? 14 : 13,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
              color: isTotal ? const Color(0xFF1A1A1A) : const Color(0xFF6B7280),
            )),
        Text(value,
            style: TextStyle(
              fontSize: isTotal ? 15 : 13,
              fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
              color: isTotal ? _kOrange : const Color(0xFF1A1A1A),
            )),
      ],
    );
  }

  // ── Bouton soumettre ────────────────────────────────────────────────────────

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity, height: 56,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: _kOrange, foregroundColor: const Color(0xFF1A1A1A),
          disabledBackgroundColor: _kOrange.withValues(alpha: 0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 22, height: 22,
                child: CircularProgressIndicator(color: Color(0xFF1A1A1A), strokeWidth: 2.5),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.send_rounded, size: 18),
                  SizedBox(width: 10),
                  Text('Envoyer la demande',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ],
              ),
      ),
    );
  }

  // ── Note informative ────────────────────────────────────────────────────────

  Widget _buildNote() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: Color(0xFFD97706), size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Les retraits sont traites sous 24 a 48h ouvrables. Assurez-vous que le numero saisi est correct.',
              style: TextStyle(
                fontSize: 12, color: Color(0xFF92400E), height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helper section ──────────────────────────────────────────────────────────

  Widget _section({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(9)),
              child: Icon(icon, color: iconColor, size: 16),
            ),
            const SizedBox(width: 10),
            Text(title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

// ── Modèle méthode paiement ────────────────────────────────────────────────────

class _PayMethod {
  final String name;
  final IconData logo;
  final Color color;
  final Color bg;
  const _PayMethod({required this.name, required this.logo, required this.color, required this.bg});
}
