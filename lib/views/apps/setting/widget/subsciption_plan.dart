import 'package:fasolingo/helpers/my_widgets/my_text.dart';
import 'package:fasolingo/helpers/utils/ui_mixins.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SubscriptionPlansPage extends StatefulWidget {
  const SubscriptionPlansPage({super.key});

  @override
  State<SubscriptionPlansPage> createState() => _SubscriptionPlansPageState();
}

class _SubscriptionPlansPageState extends State<SubscriptionPlansPage> with UIMixin {
  int selectedPlan = 1;
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController cardController = TextEditingController();

  final List<Map<String, dynamic>> plans = [
    {
      "id": "monthly",
      "title": "Mensuel",
      "price": "2 000 FCFA",
      "subtitle": "Facturé chaque mois",
      "savings": null,
    },
    {
      "id": "yearly",
      "title": "Annuel",
      "price": "15 000 FCFA",
      "subtitle": "Facturé une fois par an",
      "savings": "Économisez 35%",
    },
  ];

  final List<String> benefits = [
    "Accès illimité à tous les parcours",
    "Apprentissage de toutes les langues (Mooré, Dioula, etc.)",
    "Zéro publicité intempestive",
    "Certificats de fin de module",
    "Mode hors-ligne disponible",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: contentTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: contentTheme.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // --- HEADER ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [const Color(0xFFFFD700), Colors.orange.shade700],
                ),
              ),
              child: const Icon(Icons.auto_awesome_rounded, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 16),
            MyText.titleLarge(
              "Lingualearn Premium",
              fontWeight: 800,
              fontSize: 28,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            MyText.bodyMedium(
              "Maîtrisez les langues nationales sans aucune limite.",
              textAlign: TextAlign.center,
              color: contentTheme.black.withOpacity(0.6),
            ),

            const SizedBox(height: 32),

            // --- AVANTAGES ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: contentTheme.primary.withOpacity(0.03),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: benefits.map((benefit) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: Colors.green, size: 22),
                      const SizedBox(width: 12),
                      Expanded(child: MyText.bodyMedium(benefit, fontWeight: 500)),
                    ],
                  ),
                )).toList(),
              ),
            ),

            const SizedBox(height: 32),

            // --- PLANS ---
            ...List.generate(plans.length, (index) => _buildPlanCard(index)),

            const SizedBox(height: 32),

            // --- BOUTON D'ACHAT ---
            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: () => _processPayment(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: contentTheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: 4,
                  shadowColor: contentTheme.primary.withOpacity(0.4),
                ),
                child: MyText.titleMedium(
                  "Commencer maintenant",
                  color: Colors.white,
                  fontWeight: 700,
                ),
              ),
            ),

            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline_rounded, size: 14, color: contentTheme.black.withOpacity(0.4)),
                const SizedBox(width: 4),
                MyText.bodySmall(
                  "Paiement 100% sécurisé",
                  color: contentTheme.black.withOpacity(0.4),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(int index) {
    bool isSelected = selectedPlan == index;
    var plan = plans[index];

    return GestureDetector(
      onTap: () => setState(() => selectedPlan = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? contentTheme.primary : contentTheme.kE6E6E6,
            width: isSelected ? 2.5 : 1,
          ),
          color: isSelected ? contentTheme.primary.withOpacity(0.08) : Colors.white,
          boxShadow: isSelected ? [BoxShadow(color: contentTheme.primary.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))] : [],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              color: isSelected ? contentTheme.primary : Colors.grey,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Wrap empêche l'overflow si le titre + badge sont trop larges
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      MyText.titleMedium(plan['title'], fontWeight: 700),
                      if (plan['savings'] != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Colors.green, Colors.lightGreen]),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: MyText.bodySmall(
                            plan['savings'], 
                            color: Colors.white, 
                            fontWeight: 800, 
                            fontSize: 10,
                          ),
                        ),
                    ],
                  ),
                  MyText.bodySmall(plan['subtitle'], fontSize: 12),
                ],
              ),
            ),
            const SizedBox(width: 8),
            MyText.bodyMedium(
              plan['price'],
              fontWeight: 800,
              color: isSelected ? contentTheme.primary : contentTheme.black,
            ),
          ],
        ),
      ),
    );
  }

  void _processPayment() {
    final plan = plans[selectedPlan];

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: contentTheme.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 24),
              MyText.titleMedium("Moyen de paiement", fontWeight: 800, fontSize: 20),
              MyText.bodySmall("Plan : ${plan['title']} (${plan['price']})"),
              const SizedBox(height: 24),

              _buildPaymentOption(
                title: "Mobile Money",
                icon: Icons.phone_android_rounded,
                color: Colors.orange,
                subtitle: "Orange, Moov, MTN, Wave",
                onTap: () => _showInputFields("MOBILE"),
              ),
              const SizedBox(height: 12),
              _buildPaymentOption(
                title: "Carte Bancaire",
                icon: Icons.credit_card_rounded,
                color: Colors.blue,
                subtitle: "Visa, Mastercard",
                onTap: () => _showInputFields("CARD"),
              ),
              const SizedBox(height: 12),
              _buildPaymentOption(
                title: "PayPal",
                icon: Icons.account_balance_wallet_rounded,
                color: Colors.indigo,
                subtitle: "Paiement international",
                onTap: () => _confirmTransaction("PayPal"),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildPaymentOption({required String title, required String subtitle, required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: contentTheme.kE6E6E6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText.bodyMedium(title, fontWeight: 700),
                  MyText.bodySmall(subtitle, fontSize: 12),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  void _showInputFields(String type) {
    Get.back();
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: contentTheme.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MyText.titleMedium(
              type == "MOBILE" ? "Numéro Mobile Money" : "Infos Carte Bancaire",
              fontWeight: 800, fontSize: 18,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: type == "MOBILE" ? phoneController : cardController,
              keyboardType: type == "MOBILE" ? TextInputType.phone : TextInputType.number,
              style: const TextStyle(fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: type == "MOBILE" ? "Ex: +226 00 00 00 00" : "4400 0000 0000 ",
                prefixIcon: Icon(type == "MOBILE" ? Icons.phone_iphone : Icons.credit_card),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: contentTheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () => _confirmTransaction(type == "MOBILE" ? "Mobile Money" : "Carte"),
                child: MyText.bodyMedium("Confirmer & Payer", color: Colors.white, fontWeight: 700),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _confirmTransaction(String method) {
    if (Get.isBottomSheetOpen!) Get.back();
    
    String detail = "";
    if (method == "Mobile Money") detail = "au ${phoneController.text}";
    else if (method == "Carte") detail = "avec votre carte";
    else detail = "via PayPal";

    Get.snackbar(
      "Traitement",
      "Demande de paiement envoyée $detail.",
      snackPosition: SnackPosition.TOP,
      backgroundColor: contentTheme.primary,
      colorText: Colors.white,
      icon: const Icon(Icons.sync, color: Colors.white),
      duration: const Duration(seconds: 4),
    );
  }
}