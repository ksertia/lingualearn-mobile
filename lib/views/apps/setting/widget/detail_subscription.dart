import 'package:fasolingo/controller/apps/settings/subscription_details_controller.dart';
import 'package:fasolingo/models/souscription/subscription_status_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

const Color _dOrange  = Color(0xFFFF7043);
const Color _dOrange2 = Color(0xFFFFB74D);
const Color _dGreen   = Color(0xFF10B981);
const Color _dRed     = Color(0xFFEF4444);

class SubscriptionDetailsPage extends StatelessWidget {
  const SubscriptionDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(SubscriptionDetailsController());

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FF),
      appBar: _appBar(),
      body: Obx(() {
        if (ctrl.isLoading.value) return _loading();
        if (ctrl.hasError.value || ctrl.status.value == null) {
          return _error(ctrl);
        }
        return _buildBody(context, ctrl.status.value!, ctrl);
      }),
    );
  }

  PreferredSizeWidget _appBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_dOrange, _dOrange2],
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
          onTap: Get.back,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white, size: 17),
          ),
        ),
      ),
      title: const Text(
        'Mon Abonnement',
        style: TextStyle(
            color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17),
      ),
      centerTitle: true,
    );
  }

  Widget _loading() {
    return const Center(
      child: CircularProgressIndicator(color: _dOrange, strokeWidth: 2.5),
    );
  }

  Widget _error(SubscriptionDetailsController ctrl) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: _dOrange.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.wifi_off_rounded,
                  color: _dOrange, size: 42),
            ),
            const SizedBox(height: 16),
            const Text(
              'Impossible de charger',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A1A)),
            ),
            const SizedBox(height: 8),
            Text(
              'Vérifiez votre connexion et réessayez.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: ctrl.refresh,
              style: ElevatedButton.styleFrom(
                backgroundColor: _dOrange,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 13),
              ),
              child: const Text('Réessayer',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, SubscriptionStatusModel data,
      SubscriptionDetailsController ctrl) {
    return RefreshIndicator(
      onRefresh: ctrl.refresh,
      color: _dOrange,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(data),
            const SizedBox(height: 20),
            if (data.subscription != null) ...[
              _buildSectionTitle('Facturation'),
              const SizedBox(height: 12),
              _buildBillingCard(data.subscription!),
              const SizedBox(height: 20),
              _buildSectionTitle('Détails du plan'),
              const SizedBox(height: 12),
              _buildPlanCard(data.subscription!),
              if (!data.isActive || data.subscription!.cancelAtPeriodEnd) ...[
                const SizedBox(height: 20),
                _buildCanceledBanner(data.subscription!),
              ],
              const SizedBox(height: 32),
              _buildCancelButton(context, data.subscription!),
            ] else ...[
              _buildNoSubscriptionCard(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: Color(0xFF1A1A1A)),
    );
  }

  Widget _buildStatusCard(SubscriptionStatusModel data) {
    final sub = data.subscription;
    final planName = sub?.plan?.planName ?? 'Premium';
    final isActive = data.isActive;
    final expiresAt = data.expiresAt ?? sub?.currentPeriodEnd;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_dOrange, _dOrange2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: _dOrange.withValues(alpha: 0.35),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.white.withValues(alpha: 0.25)
                      : Colors.black.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color:
                            isActive ? Colors.greenAccent : Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isActive ? 'ACTIF' : 'INACTIF',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                          letterSpacing: 0.8),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.workspace_premium_rounded,
                  color: Colors.white, size: 32),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            planName,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          if (expiresAt != null)
            Text(
              'Expire le ${_formatDate(expiresAt)}',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.80),
                  fontSize: 13),
            ),
        ],
      ),
    );
  }

  Widget _buildBillingCard(SubscriptionModel sub) {
    final cycle = sub.billingCycle.toLowerCase() == 'monthly'
        ? 'Mensuel'
        : sub.billingCycle.toLowerCase() == 'yearly'
            ? 'Annuel'
            : sub.billingCycle;
    final price = sub.billingCycle.toLowerCase() == 'yearly'
        ? sub.plan?.priceYearly ?? '—'
        : sub.plan?.priceMonthly ?? '—';
    final currency = sub.plan?.currency ?? 'XOF';

    return _buildCard([
      _buildRow(
        icon: Icons.repeat_rounded,
        iconBg: const Color(0xFFEDE9FF),
        iconColor: const Color(0xFF7C3AED),
        label: 'Cycle de facturation',
        value: cycle,
      ),
      _buildDivider(),
      _buildRow(
        icon: Icons.payments_rounded,
        iconBg: const Color(0xFFFFF3E0),
        iconColor: _dOrange,
        label: 'Montant',
        value: '${_formatPrice(price)} $currency',
      ),
      _buildDivider(),
      _buildRow(
        icon: Icons.calendar_today_rounded,
        iconBg: const Color(0xFFE0F2FE),
        iconColor: const Color(0xFF0EA5E9),
        label: 'Début de période',
        value: _formatDate(sub.currentPeriodStart),
      ),
      _buildDivider(),
      _buildRow(
        icon: Icons.event_rounded,
        iconBg: const Color(0xFFDCFCE7),
        iconColor: _dGreen,
        label: 'Fin de période',
        value: _formatDate(sub.currentPeriodEnd),
      ),
    ]);
  }

  Widget _buildPlanCard(SubscriptionModel sub) {
    final plan = sub.plan;
    if (plan == null) return const SizedBox.shrink();

    return _buildCard([
      _buildRow(
        icon: Icons.badge_rounded,
        iconBg: const Color(0xFFFFF3E0),
        iconColor: _dOrange,
        label: 'Nom du plan',
        value: plan.planName,
      ),
      _buildDivider(),
      _buildRow(
        icon: Icons.people_rounded,
        iconBg: const Color(0xFFEDE9FF),
        iconColor: const Color(0xFF7C3AED),
        label: 'Sous-comptes inclus',
        value: '${plan.maxSubAccounts} compte(s)',
      ),
      _buildDivider(),
      _buildRow(
        icon: Icons.attach_money_rounded,
        iconBg: const Color(0xFFDCFCE7),
        iconColor: _dGreen,
        label: 'Prix mensuel',
        value: '${_formatPrice(plan.priceMonthly)} ${plan.currency}',
      ),
      _buildDivider(),
      _buildRow(
        icon: Icons.calendar_month_rounded,
        iconBg: const Color(0xFFE0F2FE),
        iconColor: const Color(0xFF0EA5E9),
        label: 'Prix annuel',
        value: '${_formatPrice(plan.priceYearly)} ${plan.currency}',
      ),
    ]);
  }

  Widget _buildCanceledBanner(SubscriptionModel sub) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _dRed.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _dRed.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _dRed.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.info_outline_rounded,
                color: _dRed, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              sub.cancelAtPeriodEnd
                  ? 'Résiliation programmée à la fin de la période.'
                  : 'Abonnement inactif ou expiré.',
              style: const TextStyle(
                  fontSize: 13,
                  color: _dRed,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoSubscriptionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _dOrange.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.workspace_premium_rounded,
                color: _dOrange, size: 42),
          ),
          const SizedBox(height: 16),
          const Text(
            'Aucun abonnement actif',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A1A)),
          ),
          const SizedBox(height: 8),
          Text(
            'Souscrivez à un plan pour accéder à toutes les fonctionnalités.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => Get.toNamed('/subscription_plans'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _dOrange,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Voir les forfaits',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelButton(
      BuildContext context, SubscriptionModel sub) {
    if (sub.cancelAtPeriodEnd) return const SizedBox.shrink();
    return Column(
      children: [
        const Divider(color: Color(0xFFEEEEEE)),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => _showCancelDialog(context),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: _dRed.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.cancel_outlined,
                    color: _dRed, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                "Résilier l'abonnement",
                style: TextStyle(
                    color: _dRed,
                    fontWeight: FontWeight.w600,
                    fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "Vous conserverez l'accès Premium jusqu'à la fin de votre période en cours.",
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
      ],
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _buildCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 14,
              offset: const Offset(0, 5)),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
        height: 1, thickness: 1, color: Color(0xFFF0F0F0), indent: 16);
  }

  String _formatDate(DateTime dt) {
    return DateFormat('dd MMMM yyyy', 'fr_FR').format(dt.toLocal());
  }

  String _formatPrice(String raw) {
    final n = int.tryParse(raw);
    if (n == null) return raw;
    return NumberFormat('#,##0', 'fr_FR').format(n).replaceAll(',', ' ');
  }

  void _showCancelDialog(BuildContext context) {
    Get.defaultDialog(
      title: 'Résilier ?',
      titleStyle: const TextStyle(
          fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A)),
      middleText:
          "Voulez-vous vraiment résilier ? Vous conserverez l'accès Premium jusqu'à la fin de la période en cours.",
      middleTextStyle:
          TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.5),
      textConfirm: 'Confirmer',
      textCancel: 'Annuler',
      confirmTextColor: Colors.white,
      buttonColor: _dRed,
      cancelTextColor: const Color(0xFF1A1A1A),
      onConfirm: () {
        Get.back();
        Get.snackbar(
          'Résiliation demandée',
          "Votre abonnement sera actif jusqu'à la fin de la période.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black87,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 16,
        );
      },
    );
  }
}
