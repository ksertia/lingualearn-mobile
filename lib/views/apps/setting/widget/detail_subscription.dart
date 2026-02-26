import 'package:fasolingo/helpers/my_widgets/my_text.dart';
import 'package:fasolingo/helpers/utils/ui_mixins.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SubscriptionDetailsPage extends StatefulWidget {
  const SubscriptionDetailsPage({super.key});

  @override
  State<SubscriptionDetailsPage> createState() => _SubscriptionDetailsPageState();
}

class _SubscriptionDetailsPageState extends State<SubscriptionDetailsPage> with UIMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: contentTheme.background,
      appBar: AppBar(
        title: MyText.titleMedium("Mon Abonnement", fontWeight: 700),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: contentTheme.black, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- CARTE DE STATUT ACTUEL ---
            _buildStatusCard(),

            const SizedBox(height: 32),

            MyText.titleMedium("Détails de facturation", fontWeight: 700),
            const SizedBox(height: 16),

            // --- OPTIONS DE GESTION ---
            _buildInfoTile(
              icon: Icons.calendar_today_rounded,
              label: "Date de souscription",
              value: "12 Janvier 2026",
            ),
            _buildInfoTile(
              icon: Icons.account_balance_wallet_rounded,
              label: "Mode de paiement",
              value: "Orange Money (****78)",
            ),
            _buildInfoTile(
              icon: Icons.history_rounded,
              label: "Historique des paiements",
              value: "Voir les factures",
              onTap: () {
                // Logique pour voir les PDF ou l'historique
              },
            ),

            const SizedBox(height: 40),

            // --- ZONE DE DANGER (RÉSILIATION) ---
            const Divider(),
            const SizedBox(height: 20),
            
            InkWell(
              onTap: () => _showCancelDialog(),
              child: Row(
                children: [
                  const Icon(Icons.cancel_outlined, color: Colors.redAccent, size: 24),
                  const SizedBox(width: 12),
                  MyText.bodyMedium(
                    "Résilier l'abonnement",
                    color: Colors.redAccent,
                    fontWeight: 600,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            MyText.bodySmall(
              "Vous perdrez l'accès aux fonctionnalités Premium à la fin de votre période de facturation actuelle.",
              color: contentTheme.black.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: contentTheme.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: contentTheme.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: MyText.bodySmall("ACTIF", color: Colors.white, fontWeight: 800),
              ),
              const Icon(Icons.stars_rounded, color: Colors.white, size: 30),
            ],
          ),
          const SizedBox(height: 20),
          MyText.titleLarge("Premium Annuel", color: Colors.white, fontWeight: 700),
          const SizedBox(height: 4),
          MyText.bodyMedium(
            "Prochain renouvellement : 12 Janv. 2027",
            color: Colors.white.withOpacity(0.8),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: contentTheme.kE6E6E6.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: contentTheme.black),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText.bodySmall(label, color: contentTheme.black.withOpacity(0.5)),
                  MyText.bodyMedium(value, fontWeight: 600),
                ],
              ),
            ),
            if (onTap != null)
              Icon(Icons.arrow_forward_ios, size: 14, color: contentTheme.black.withOpacity(0.3)),
          ],
        ),
      ),
    );
  }

  void _showCancelDialog() {
    Get.defaultDialog(
      title: "Résilier ?",
      middleText: "Voulez-vous vraiment désactiver le renouvellement automatique ? Vous resterez Premium jusqu'au 12/01/2027.",
      textConfirm: "Confirmer",
      textCancel: "Garder mon accès",
      confirmTextColor: Colors.white,
      buttonColor: Colors.redAccent,
      onConfirm: () {
        Get.back();
        Get.snackbar("Information", "Demande de résiliation prise en compte.");
      },
    );
  }
}