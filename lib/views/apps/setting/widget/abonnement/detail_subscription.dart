import 'package:tibi/controller/apps/settings/subscription_details_controller.dart';
import 'package:tibi/helpers/theme/app_colors.dart';
import 'package:tibi/models/souscription/subscription_status_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

const Color _kGreen      = Color(0xFF188329);
const Color _kRed    = Color(0xFFEF4444);
const Color _kPurple = Color(0xFF7C3AED);
const Color _kBlue   = Color(0xFF0EA5E9);
const Color _kOrange     = Color(0xFFF27F22);


class SubscriptionDetailsPage extends StatefulWidget {
  const SubscriptionDetailsPage({super.key});

  @override
  State<SubscriptionDetailsPage> createState() => _SubscriptionDetailsPageState();
}

class _SubscriptionDetailsPageState extends State<SubscriptionDetailsPage> {
  late BuildContext _ctx;

  @override
  Widget build(BuildContext context) {
    _ctx = context;
    final ctrl   = Get.put(SubscriptionDetailsController());
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.bgAlt(context),
      body: Column(
        children: [
          _buildHeader(topPad),
          Expanded(
            child: Obx(() {
              if (ctrl.isLoading.value) return _loading();
              if (ctrl.hasError.value || ctrl.status.value == null) {
                return _error(ctrl);
              }
              return _buildBody(context, ctrl.status.value!, ctrl);
            }),
          ),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(double topPad) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, topPad + 16, 20, 22),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_kOrange, _kOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: Get.back,
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
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'Mon Abonnement',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
            ),
            child: const Icon(Icons.workspace_premium_rounded,
                color: Colors.white, size: 22),
          ),
        ],
      ),
    );
  }

  // ── States ────────────────────────────────────────────────────────────────

  Widget _loading() {
    return const Center(
      child: CircularProgressIndicator(color: _kOrange, strokeWidth: 2.5),
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
                  color: _kOrange.withValues(alpha: 0.10), shape: BoxShape.circle),
              child: const Icon(Icons.wifi_off_rounded, color: _kOrange, size: 42),
            ),
            const SizedBox(height: 16),
            Text('Impossible de charger',
                style: TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary(_ctx))),
            const SizedBox(height: 8),
            Text('Vérifiez votre connexion et réessayez.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary(_ctx))),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: ctrl.refresh,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [_kOrange, _kOrange]),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                        color: _kOrange.withValues(alpha: 0.32),
                        blurRadius: 12,
                        offset: const Offset(0, 5))
                  ],
                ),
                child: const Text('Réessayer',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Body ──────────────────────────────────────────────────────────────────

  Widget _buildBody(BuildContext context, SubscriptionStatusModel data,
      SubscriptionDetailsController ctrl) {
    return RefreshIndicator(
      onRefresh: ctrl.refresh,
      color: _kOrange,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroCard(data),
            const SizedBox(height: 24),
            if (data.subscription != null) ...[
              _sectionHeader('Facturation', _kOrange, Icons.receipt_long_rounded),
              const SizedBox(height: 12),
              _buildBillingCard(data.subscription!),
              const SizedBox(height: 24),
              _sectionHeader('Détails du plan', _kPurple, Icons.workspace_premium_rounded),
              const SizedBox(height: 12),
              _buildPlanCard(data.subscription!),
              if ((data.subscription!.plan?.description ?? '').isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildDescriptionCard(data.subscription!.plan!.description),
              ],
              if (!data.isActive || data.subscription!.cancelAtPeriodEnd) ...[
                const SizedBox(height: 16),
                _buildCanceledBanner(data.subscription!),
              ],
              if (!data.subscription!.cancelAtPeriodEnd) ...[
                const SizedBox(height: 24),
                _sectionHeader('Zone de résiliation', _kRed, Icons.warning_amber_rounded),
                const SizedBox(height: 12),
                _buildDangerZoneCard(context, data.subscription!),
              ],
            ] else ...[
              _buildNoSubscriptionCard(),
            ],
          ],
        ),
      ),
    );
  }

  // ── Section Header ────────────────────────────────────────────────────────

  Widget _sectionHeader(String title, Color color, IconData icon) {
    return Row(
      children: [
        Container(
          width: 3, height: 16,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 8),
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(
          title.toUpperCase(),
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: 0.9),
        ),
      ],
    );
  }

  // ── Hero Card ─────────────────────────────────────────────────────────────

  Widget _buildHeroCard(SubscriptionStatusModel data) {
    final sub      = data.subscription;
    final planName = sub?.plan?.planName ?? 'Premium';
    final isActive = data.isActive;
    final expiresAt = data.expiresAt ?? sub?.currentPeriodEnd;
    final daysLeft = expiresAt?.toLocal().difference(DateTime.now()).inDays.clamp(0, 9999);
    final cycle = sub?.billingCycle.toLowerCase() == 'yearly'
        ? 'Annuel'
        : sub?.billingCycle.toLowerCase() == 'monthly'
            ? 'Mensuel'
            : null;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_kOrange, _kOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
              color: _kOrange.withValues(alpha: 0.32),
              blurRadius: 24,
              offset: const Offset(0, 10)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            // Blobs décoratifs
            Positioned(
              right: -20, top: -20,
              child: Container(
                  width: 110, height: 110,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.06))),
            ),
            Positioned(
              right: 50, bottom: -15,
              child: Container(
                  width: 65, height: 65,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _kOrange.withValues(alpha: 0.15))),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: isActive
                              ? Colors.white.withValues(alpha: 0.22)
                              : Colors.black.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: isActive
                                  ? Colors.white.withValues(alpha: 0.30)
                                  : Colors.transparent),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7, height: 7,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? const Color(0xFF4ADE80)
                                    : const Color(0xFFFC8181),
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
                      const Spacer(),
                      if (cycle != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: _kOrange,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(cycle,
                              style: const TextStyle(
                                  color: Color(0xFF1A1A1A),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Plan name
                  Row(
                    children: [
                      const Icon(Icons.workspace_premium_rounded,
                          color: Colors.white, size: 28),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          planName,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  // Expiry box
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.20)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.event_available_rounded,
                            color: Colors.white70, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            expiresAt != null
                                ? 'Expire le ${_formatDate(expiresAt)}'
                                : 'Date d\'expiration inconnue',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        if (daysLeft != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: daysLeft <= 7
                                  ? const Color(0xFFFC8181)
                                  : _kOrange,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$daysLeft j',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: daysLeft <= 7
                                      ? Colors.white
                                      : const Color(0xFF1A1A1A)),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Billing Card ──────────────────────────────────────────────────────────

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

    return _card([
      _row(Icons.repeat_rounded, const Color(0xFFEDE9FF), _kPurple,
          'Cycle de facturation', cycle),
      _divider(),
      _row(Icons.payments_rounded, const Color(0xFFFFF3E0), _kOrange,
          'Montant', '${_formatPrice(price)} $currency'),
      _divider(),
      _row(Icons.calendar_today_rounded, const Color(0xFFE0F2FE), _kBlue,
          'Début de période', _formatDate(sub.currentPeriodStart)),
      _divider(),
      _row(Icons.event_rounded, const Color(0xFFDCFCE7), _kGreen,
          'Fin de période', _formatDate(sub.currentPeriodEnd)),
    ]);
  }

  // ── Plan Card ─────────────────────────────────────────────────────────────

  Widget _buildPlanCard(SubscriptionModel sub) {
    final plan = sub.plan;
    if (plan == null) return const SizedBox.shrink();

    return _card([
      _row(Icons.badge_rounded, const Color(0xFFFFF3E0), _kOrange,
          'Nom du plan', plan.planName),
      _divider(),
      _row(Icons.people_rounded, const Color(0xFFEDE9FF), _kPurple,
          'Sous-comptes inclus',
          '${plan.maxSubAccounts} compte${plan.maxSubAccounts > 1 ? 's' : ''}'),
      _divider(),
      _row(Icons.attach_money_rounded, const Color(0xFFDCFCE7), _kGreen,
          'Prix mensuel', '${_formatPrice(plan.priceMonthly)} ${plan.currency}'),
      _divider(),
      _row(Icons.calendar_month_rounded, const Color(0xFFE0F2FE), _kBlue,
          'Prix annuel', '${_formatPrice(plan.priceYearly)} ${plan.currency}'),
      if ((plan.reducePrice ?? '').isNotEmpty &&
          (plan.percentage ?? '').isNotEmpty) ...[
        _divider(),
        _row(Icons.local_offer_rounded, const Color(0xFFFEF9C3), _kOrange,
            'Prix réduit',
            '${_formatPrice(plan.reducePrice!)} ${plan.currency}  (−${plan.percentage}%)'),
      ],
    ]);
  }

  // ── Description Card ──────────────────────────────────────────────────────

  Widget _buildDescriptionCard(String description) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kPurple.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kPurple.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: _kPurple.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(Icons.info_outline_rounded,
                color: _kPurple, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              description,
              style: TextStyle(
                  fontSize: 13, color: AppColors.textSecondary(_ctx), height: 1.55),
            ),
          ),
        ],
      ),
    );
  }

  // ── Canceled Banner ───────────────────────────────────────────────────────

  Widget _buildCanceledBanner(SubscriptionModel sub) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kRed.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kRed.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _kRed.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.warning_amber_rounded,
                color: _kRed, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              sub.cancelAtPeriodEnd
                  ? 'Résiliation programmée à la fin de la période en cours.'
                  : 'Abonnement inactif ou expiré.',
              style: const TextStyle(
                  fontSize: 13,
                  color: _kRed,
                  fontWeight: FontWeight.w600,
                  height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  // ── Danger Zone Card ──────────────────────────────────────────────────────

  Widget _buildDangerZoneCard(BuildContext context, SubscriptionModel sub) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card(_ctx),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kRed.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
              color: _kRed.withValues(alpha: 0.06),
              blurRadius: 14,
              offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Résilier l\'abonnement',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary(_ctx)),
          ),
          const SizedBox(height: 6),
          Text(
            'Vous conserverez l\'accès Premium jusqu\'à la fin de votre période en cours.',
            style: TextStyle(
                fontSize: 12, color: AppColors.textSecondary(_ctx), height: 1.5),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => _showCancelDialog(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: _kRed.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: _kRed.withValues(alpha: 0.25)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cancel_outlined, color: _kRed, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Résilier l\'abonnement',
                    style: TextStyle(
                        color: _kRed,
                        fontWeight: FontWeight.w700,
                        fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── No Subscription Card ──────────────────────────────────────────────────

  Widget _buildNoSubscriptionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.card(_ctx),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: AppColors.shadow(_ctx),
              blurRadius: 16,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [_kOrange, _kOrange]),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: _kOrange.withValues(alpha: 0.28),
                    blurRadius: 16,
                    offset: const Offset(0, 6))
              ],
            ),
            child: const Icon(Icons.workspace_premium_rounded,
                color: Colors.white, size: 42),
          ),
          const SizedBox(height: 18),
          Text(
            'Aucun abonnement actif',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary(_ctx)),
          ),
          const SizedBox(height: 8),
          Text(
            'Souscrivez à un plan pour accéder à toutes les fonctionnalités.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 13, color: AppColors.textSecondary(_ctx), height: 1.5),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => Get.toNamed('/subscription_plans'),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [_kOrange, _kOrange]),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                      color: _kOrange.withValues(alpha: 0.30),
                      blurRadius: 12,
                      offset: const Offset(0, 5))
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.rocket_launch_rounded,
                      color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text('Voir les forfaits',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _card(List<Widget> children) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.card(_ctx),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: AppColors.shadow(_ctx),
              blurRadius: 14,
              offset: const Offset(0, 5)),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _row(IconData icon, Color iconBg, Color iconColor,
      String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
                color: iconBg, borderRadius: BorderRadius.circular(11)),
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
                        color: AppColors.textSecondary(_ctx),
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(value,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(_ctx))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Divider(
        height: 1, thickness: 1, color: AppColors.divider(_ctx), indent: 16);
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
      backgroundColor: AppColors.card(_ctx),
      title: 'Résilier ?',
      titleStyle: TextStyle(
          fontWeight: FontWeight.w800, color: AppColors.textPrimary(_ctx)),
      middleText:
          "Voulez-vous vraiment résilier ? Vous conserverez l'accès Premium jusqu'à la fin de la période en cours.",
      middleTextStyle:
          TextStyle(fontSize: 13, color: AppColors.textSecondary(_ctx), height: 1.5),
      textConfirm: 'Confirmer',
      textCancel: 'Annuler',
      confirmTextColor: Colors.white,
      buttonColor: _kRed,
      cancelTextColor: AppColors.textPrimary(_ctx),
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
