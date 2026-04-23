import 'package:fasolingo/controller/apps/subscription/subscription_controller.dart';
import 'package:fasolingo/helpers/services/souscription/payment_service.dart';
import 'package:fasolingo/helpers/utils/ui_mixins.dart';
import 'package:fasolingo/models/souscription/souscription_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const _kOrange = Color(0xFFFF7043);
const _kAmber  = Color(0xFFFFB74D);
const _kBg     = Color(0xFFEDE8E3);
const _kDark   = Color(0xFF1A1A1A);

class SubscriptionPlansPage extends StatefulWidget {
  final bool isBottomSheet;
  const SubscriptionPlansPage({super.key, this.isBottomSheet = false});

  @override
  State<SubscriptionPlansPage> createState() => _SubscriptionPlansPageState();
}

class _SubscriptionPlansPageState extends State<SubscriptionPlansPage>
    with UIMixin {
  final PlanController controller = Get.put(PlanController());
  final _paymentService = Get.put(PaymentService());

  int _currentStep = 1;
  String _selectedMethod = "";
  PlanModel? _selectedPlan;

  final _phoneCtrl = TextEditingController();
  final _otpCtrl   = TextEditingController();
  bool    _isSubmitting    = false;
  String? _paymentRequestId;
  double? _paidAmount;
  String? _paidCurrency;
  String? _paymentError;
  String? _instructions;

  final List<String> allBenefits = [
    "Accès à TOUS les contenus",
    "Qualité Ultra HD et 4K",
    "Zéro publicité",
    "Visionnage hors-ligne illimité",
    "Accès prioritaire aux nouveautés",
    "Support client VIP 24h/7j",
    "Multi-écrans (Jusqu'à 4 appareils)",
  ];

  // ─── BUILD PRINCIPAL ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (widget.isBottomSheet) {
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: Container(
          color: _kBg,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.92,
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade200,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                _buildModalHeader(),
                Flexible(child: _buildModalStepContent()),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: _kDark),
          onPressed: () => Get.back(),
        ),
      ),
      body: _buildStandalonePlanList(),
    );
  }

  // ─── HEADER STEPPER ──────────────────────────────────────────────────────────

  Widget _buildModalHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          if (_currentStep > 1)
            IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.orange.shade700, size: 20),
              onPressed: () => setState(() {
                if (_currentStep == 3) _resetPaymentState();
                _currentStep--;
              }),
            )
          else
            const SizedBox(width: 48),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _stepCircle("1", _currentStep >= 1),
                _stepLine(_currentStep >= 2),
                _stepCircle("2", _currentStep >= 2),
                _stepLine(_currentStep >= 3),
                _stepCircle("3", _currentStep >= 3),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: Colors.grey.shade400),
            onPressed: () => Get.back(),
          ),
        ],
      ),
    );
  }

  // ─── ROUTEUR D'ÉTAPES ────────────────────────────────────────────────────────

  Widget _buildModalStepContent() {
    switch (_currentStep) {
      case 1:  return _buildModalPlanList();
      case 2:  return _buildModalMethodList();
      case 3:  return _buildModalPhoneOTP();
      default: return const SizedBox();
    }
  }

  // ─── ÉTAPE 1 : CHOIX DU FORFAIT ──────────────────────────────────────────────

  Widget _buildModalPlanList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator(color: _kOrange));
      }
      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _sectionTitle("Choisissez votre forfait"),
            const SizedBox(height: 6),
            _sectionSubtitle("Profitez du meilleur de TiBi sans limites."),
            const SizedBox(height: 24),
            ...controller.plans.asMap().entries.map((e) => _buildPlanCard(
                  e.value,
                  _benefitsForIndex(e.key),
                  onSelect: () => setState(() {
                    _selectedPlan = e.value;
                    _currentStep  = 2;
                  }),
                )),
            const SizedBox(height: 40),
          ],
        ),
      );
    });
  }

  // ─── ÉTAPE 2 : MOYEN DE PAIEMENT ─────────────────────────────────────────────

  Widget _buildModalMethodList() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          _sectionTitle("Moyen de paiement"),
          const SizedBox(height: 6),
          if (_selectedPlan != null)
            _sectionSubtitle(
              "Forfait : ${_selectedPlan!.planName}  •  ${_selectedPlan!.priceMonthly} ${_selectedPlan!.currency}",
            ),
          const SizedBox(height: 28),
          _paymentTile(
            "Orange Money",
            "Burkina Faso",
            const Color(0xFFFF6D00),
            Icons.account_balance_wallet_rounded,
            () => setState(() { _selectedMethod = "OM"; _currentStep = 3; }),
          ),
          _paymentTile(
            "Moov Money",
            "Moov Africa",
            const Color(0xFF1565C0),
            Icons.account_balance_wallet_rounded,
            () => setState(() { _selectedMethod = "MOOV"; _currentStep = 3; }),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ─── ÉTAPE 3 : NUMÉRO + OTP ──────────────────────────────────────────────────

  Widget _buildModalPhoneOTP() {
    final isOrange  = _selectedMethod == "OM";
    final codeSent  = _paymentRequestId != null; // seulement utilisé pour Moov

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          _sectionTitle("Finaliser le paiement"),
          const SizedBox(height: 24),

          // ── Récapitulatif ──
          if (_selectedPlan != null) _buildRecap(codeSent),
          const SizedBox(height: 24),

          // ══════════════════════════════════════════════════════════════
          // ORANGE MONEY — formulaire unique (phone + USSD + OTP ensemble)
          // ══════════════════════════════════════════════════════════════
          if (isOrange) ...[
            _labeledField(
              label: "NUMÉRO DE TÉLÉPHONE",
              child: TextField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: _kDark, fontWeight: FontWeight.w600),
                decoration: _fieldDeco(hint: "+226 75 00 00 00"),
              ),
            ),
            const SizedBox(height: 16),

            // Instruction USSD
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.phone_in_talk_rounded,
                          color: Colors.orange.shade700, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        "Code USSD à composer",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.orange.shade800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Composez *144*4*6*${_selectedPlan!.priceMonthly}# sur votre téléphone Orange, puis entrez le code OTP reçu ci-dessous.",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.orange.shade700,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            _labeledField(
              label: "CODE OTP",
              child: TextField(
                controller: _otpCtrl,
                keyboardType: TextInputType.number,
                maxLength: 6,
                style: const TextStyle(
                  color: _kDark,
                  fontSize: 26,
                  letterSpacing: 10,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
                decoration: _fieldDeco(hint: "• • • • • •", counterText: ""),
              ),
            ),
            const SizedBox(height: 24),
            _actionButton(
              label: "Payer maintenant",
              loading: _isSubmitting,
              onTap: _initiateAndConfirmOrange,
            ),
          ],

          // ══════════════════════════════════════════════════════════════
          // MOOV MONEY — 2 phases : d'abord envoi SMS, puis saisie OTP
          // ══════════════════════════════════════════════════════════════
          if (!isOrange) ...[
            // Phase 1 : numéro de téléphone
            if (!codeSent) ...[
              _labeledField(
                label: "NUMÉRO DE TÉLÉPHONE",
                child: TextField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: _kDark, fontWeight: FontWeight.w600),
                  decoration: _fieldDeco(hint: "+226 70 00 00 00"),
                ),
              ),
              const SizedBox(height: 24),
              _actionButton(
                label: "Envoyer le code SMS",
                loading: _isSubmitting,
                onTap: _initiatePayment,
              ),
            ],

            // Phase 2 : saisie OTP après réception SMS
            if (codeSent) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.sms_rounded, color: Colors.green.shade600, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Code OTP envoyé par SMS au ${_phoneCtrl.text}",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _labeledField(
                label: "CODE OTP",
                child: TextField(
                  controller: _otpCtrl,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  style: const TextStyle(
                    color: _kDark,
                    fontSize: 26,
                    letterSpacing: 10,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                  decoration: _fieldDeco(hint: "• • • • • •", counterText: ""),
                ),
              ),
              const SizedBox(height: 24),
              _actionButton(
                label: "Confirmer le paiement",
                loading: _isSubmitting,
                onTap: _confirmPayment,
              ),
            ],
          ],

          // ── Erreur ──
          if (_paymentError != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade400, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _paymentError!,
                      style: TextStyle(
                        color: Colors.red.shade600,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, color: Colors.grey.shade400, size: 14),
              const SizedBox(width: 6),
              Text(
                "Paiement sécurisé chiffré SSL",
                style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildRecap(bool codeSent) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF3E0), Color(0xFFFFF0DC)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _kOrange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.workspace_premium_rounded,
                    color: _kOrange, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedPlan!.planName,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700, color: _kDark),
                  ),
                  Text(
                    "Abonnement mensuel",
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ],
          ),
          Text(
            codeSent
                ? "${_paidAmount?.toStringAsFixed(0)} $_paidCurrency"
                : "${_selectedPlan!.priceMonthly} ${_selectedPlan!.currency}",
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.w900, color: _kOrange),
          ),
        ],
      ),
    );
  }

  // ─── LOGIQUE PAIEMENT ────────────────────────────────────────────────────────

  String get _methodApi => _selectedMethod == "OM" ? "orange_money" : "moov_money";

  Future<void> _initiatePayment() async {
    if (_phoneCtrl.text.trim().isEmpty) {
      setState(() => _paymentError = "Veuillez saisir votre numéro de téléphone.");
      return;
    }
    setState(() { _isSubmitting = true; _paymentError = null; });
    try {
      final res = await _paymentService.initiatePayment(
        planId: _selectedPlan!.id,
        paymentMethod: _methodApi,
        phoneNumber: _phoneCtrl.text.trim(),
      );
      setState(() {
        _paymentRequestId = res['paymentRequestId'] as String?;
        _paidAmount       = (res['amount'] as num?)?.toDouble();
        _paidCurrency     = res['currency'] as String?;
        _instructions     = res['instructions'] as String?;
      });
    } catch (e) {
      setState(() => _paymentError = "Erreur lors de l'envoi du code. Vérifiez votre numéro.");
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _confirmPayment() async {
    if (_otpCtrl.text.trim().length < 4) {
      setState(() => _paymentError = "Veuillez saisir le code OTP reçu.");
      return;
    }
    setState(() { _isSubmitting = true; _paymentError = null; });
    try {
      await _paymentService.confirmPayment(
        paymentRequestId: _paymentRequestId!,
        otpCode: _otpCtrl.text.trim(),
      );
      Get.back();
      Get.snackbar(
        "Abonnement activé !",
        "Votre abonnement est maintenant actif.",
        backgroundColor: _kOrange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 14,
      );
    } catch (e) {
      setState(() => _paymentError = "Code OTP incorrect ou expiré. Réessayez.");
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _initiateAndConfirmOrange() async {
    if (_phoneCtrl.text.trim().isEmpty) {
      setState(() => _paymentError = "Veuillez saisir votre numéro de téléphone.");
      return;
    }
    if (_otpCtrl.text.trim().length < 4) {
      setState(() => _paymentError = "Veuillez saisir le code OTP.");
      return;
    }
    setState(() { _isSubmitting = true; _paymentError = null; });
    try {
      final res = await _paymentService.initiatePayment(
        planId: _selectedPlan!.id,
        paymentMethod: _methodApi,
        phoneNumber: _phoneCtrl.text.trim(),
      );
      final requestId = res['paymentRequestId'] as String?;
      if (requestId == null) throw Exception("paymentRequestId manquant");
      await _paymentService.confirmPayment(
        paymentRequestId: requestId,
        otpCode: _otpCtrl.text.trim(),
      );
      Get.back();
      Get.snackbar(
        "Abonnement activé !",
        "Votre abonnement est maintenant actif.",
        backgroundColor: _kOrange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 14,
      );
    } catch (e) {
      setState(() => _paymentError = "Erreur de paiement. Vérifiez votre numéro et votre code OTP.");
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _resetPaymentState() {
    _paymentRequestId = null;
    _paidAmount       = null;
    _paidCurrency     = null;
    _paymentError     = null;
    _instructions     = null;
    _otpCtrl.clear();
  }

  // ─── MODE PAGE STANDALONE ────────────────────────────────────────────────────

  Widget _buildStandalonePlanList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator(color: _kOrange));
      }
      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            _sectionTitle("Choisissez votre forfait"),
            const SizedBox(height: 6),
            _sectionSubtitle("Profitez du meilleur de TiBi sans limites."),
            const SizedBox(height: 32),
            ...controller.plans.asMap().entries.map((e) => _buildPlanCard(
                  e.value,
                  _benefitsForIndex(e.key),
                  onSelect: () => _openPaymentBottomSheet(e.value),
                )),
            const SizedBox(height: 40),
          ],
        ),
      );
    });
  }

  void _openPaymentBottomSheet(PlanModel plan) {
    int step = 2;
    String method = "";
    Get.bottomSheet(
      StatefulBuilder(builder: (context, setModalState) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F2EE),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade200,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                Row(
                  children: [
                    if (step > 2)
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios,
                            color: Colors.orange.shade700, size: 20),
                        onPressed: () => setModalState(() => step--),
                      )
                    else
                      const Spacer(),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _stepCircle("1", step >= 1),
                          _stepLine(step >= 2),
                          _stepCircle("2", step >= 2),
                          _stepLine(step >= 3),
                          _stepCircle("3", step >= 3),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(Icons.close, color: Colors.grey.shade400),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                if (step == 2)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle("Moyen de paiement"),
                      const SizedBox(height: 20),
                      _paymentTile("Orange Money", "Burkina Faso",
                          const Color(0xFFFF6D00),
                          Icons.account_balance_wallet_rounded,
                          () => setModalState(() { method = "OM"; step = 3; })),
                      _paymentTile("Moov Money", "Moov Africa",
                          const Color(0xFF1565C0),
                          Icons.account_balance_wallet_rounded,
                          () => setModalState(() { method = "MOOV"; step = 3; })),
                    ],
                  ),

                if (step == 3)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle("Finaliser le paiement"),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFF3E0), Color(0xFFFFF0DC)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(plan.planName,
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: _kDark)),
                            Text(
                              "${plan.priceMonthly} ${plan.currency}",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: _kOrange,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      _standaloneField("NUMÉRO DE TÉLÉPHONE", "+226 70 00 00 00"),
                      const SizedBox(height: 16),
                      _standaloneField("CODE OTP", "• • • • • •"),
                      const SizedBox(height: 8),
                      Text(
                        method == "OM"
                            ? "Composez *144*4*6*montant# pour l'OTP Orange"
                            : "Composez *555*montant# pour l'OTP Moov",
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: ElevatedButton(
                          onPressed: () => Get.back(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _kOrange,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text(
                            "Confirmer le paiement",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_outline, color: Colors.grey.shade400, size: 14),
                    const SizedBox(width: 6),
                    Text("Paiement sécurisé chiffré SSL",
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      }),
      isScrollControlled: true,
    );
  }

  // ─── PLAN CARD ───────────────────────────────────────────────────────────────

  List<String> _benefitsForIndex(int index) {
    if (index == 0) return allBenefits.sublist(0, 3);
    if (index == 1) return allBenefits.sublist(0, 5);
    return allBenefits;
  }

  Widget _buildPlanCard(PlanModel plan, List<String> benefits,
      {required VoidCallback onSelect}) {
    final isPremium = plan.planName.toLowerCase().contains('prenium') ||
        plan.planName.toLowerCase().contains('gold') ||
        plan.planName.toLowerCase().contains('premium');

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isPremium ? _kOrange : Colors.orange.shade100,
          width: isPremium ? 2.5 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isPremium
                ? _kOrange.withValues(alpha: 0.25)
                : Colors.black.withValues(alpha: 0.10),
            blurRadius: isPremium ? 24 : 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Top gradient strip for premium
          if (isPremium)
            Positioned(
              top: 0, left: 0, right: 0,
              child: Container(
                height: 4,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [_kOrange, _kAmber]),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isPremium
                                ? _kOrange.withValues(alpha: 0.1)
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isPremium
                                ? Icons.workspace_premium_rounded
                                : Icons.star_border_rounded,
                            color: isPremium ? _kOrange : Colors.grey.shade400,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              plan.planName,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: _kDark,
                              ),
                            ),
                            Text(
                              isPremium ? "Le plus populaire" : "Idéal pour débuter",
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (isPremium)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [_kOrange, _kAmber]),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "RECOMMANDÉ",
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: Colors.white),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 20),

                // Prix
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isPremium
                          ? [const Color(0xFFFFF3E0), const Color(0xFFFFF0DC)]
                          : [Colors.grey.shade50, Colors.grey.shade100],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isPremium
                          ? Colors.orange.shade200
                          : Colors.grey.shade200,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        plan.priceMonthly,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: isPremium ? _kOrange : Colors.grey.shade700,
                          height: 1,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          "${plan.currency} / mois",
                          style: TextStyle(
                              fontSize: 13, color: Colors.grey.shade500),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Bénéfices
                ...benefits.map((text) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: isPremium
                                  ? _kOrange.withValues(alpha: 0.1)
                                  : Colors.grey.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check,
                              size: 13,
                              color: isPremium ? _kOrange : Colors.grey.shade400,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              text,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),

                const SizedBox(height: 20),

                // Bouton
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: onSelect,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isPremium ? _kOrange : Colors.grey.shade100,
                      foregroundColor:
                          isPremium ? Colors.white : Colors.grey.shade700,
                      elevation: isPremium ? 0 : 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Choisir ce forfait",
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: isPremium ? Colors.white : Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 18,
                          color: isPremium ? Colors.white : Colors.grey.shade600,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── WIDGETS PARTAGÉS ────────────────────────────────────────────────────────

  Widget _sectionTitle(String text) => Text(
        text,
        style: const TextStyle(
            fontSize: 22, fontWeight: FontWeight.w900, color: _kDark),
      );

  Widget _sectionSubtitle(String text) => Text(
        text,
        style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
      );

  Widget _stepCircle(String n, bool active) => Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: active ? _kOrange : Colors.grey.shade200,
          shape: BoxShape.circle,
          boxShadow: active
              ? [
                  BoxShadow(
                    color: _kOrange.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : [],
        ),
        child: Center(
          child: Text(
            n,
            style: TextStyle(
              color: active ? Colors.white : Colors.grey.shade400,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      );

  Widget _stepLine(bool active) => Container(
        width: 28,
        height: 2.5,
        decoration: BoxDecoration(
          color: active ? _kOrange : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(2),
        ),
      );

  Widget _paymentTile(
      String title, String sub, Color color, IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(title,
            style: const TextStyle(
                color: _kDark, fontWeight: FontWeight.w700, fontSize: 15)),
        subtitle: Text(sub,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
        trailing: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.arrow_forward_ios,
              color: Colors.grey.shade400, size: 13),
        ),
      ),
    );
  }

  Widget _labeledField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade500,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  InputDecoration _fieldDeco({required String hint, String? counterText}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400),
      counterText: counterText,
      filled: true,
      fillColor: Colors.white,
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
    );
  }

  Widget _actionButton({
    required String label,
    required bool loading,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(colors: [_kOrange, _kAmber]),
        boxShadow: [
          BoxShadow(
            color: _kOrange.withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 58,
        child: ElevatedButton(
          onPressed: loading ? null : onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
          ),
          child: loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5),
                )
              : Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _standaloneField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade500,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          style: const TextStyle(color: _kDark),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            filled: true,
            fillColor: Colors.white,
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
          ),
        ),
      ],
    );
  }
}
