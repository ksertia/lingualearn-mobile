import 'package:tibi/controller/apps/partner/partner_controller.dart';
import 'package:tibi/helpers/theme/app_colors.dart';
import 'package:tibi/models/partner/referral_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const Color _kOrange = Color(0xFFF27F22);

class PartnerWithdrawPage extends StatefulWidget {
  const PartnerWithdrawPage({super.key});

  @override
  State<PartnerWithdrawPage> createState() => _PartnerWithdrawPageState();
}

class _PartnerWithdrawPageState extends State<PartnerWithdrawPage> {
  late BuildContext _ctx;
  final PartnerController controller = Get.put(PartnerController());

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
          'Mes points',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary(context)),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.referralData.value == null) {
          return const Center(child: CircularProgressIndicator(color: _kOrange));
        }

        final data = controller.referralData.value;
        if (data == null) {
          return _buildError(controller.loadErrorMsg.value);
        }

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildPointsCard(data),
            const SizedBox(height: 24),
            _buildBreakdown(data),
            const SizedBox(height: 24),
            _buildComingSoonNote(),
            const SizedBox(height: 20),
            _buildConvertButton(),
          ],
        );
      }),
    );
  }

  Widget _buildError(String? message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, color: AppColors.textSecondary(_ctx), size: 42),
            const SizedBox(height: 16),
            Text(
              message ?? 'Impossible de charger vos points.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary(_ctx)),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: controller.fetchMyReferral,
              style: ElevatedButton.styleFrom(
                backgroundColor: _kOrange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Réessayer', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Total des points ─────────────────────────────────────────────────────────

  Widget _buildPointsCard(ReferralData data) {
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
                const Text(
                  'Points gagnés',
                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  '${data.totalCoinsEarned} pts',
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
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
              'Cumulés',
              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // ── Détail des points ───────────────────────────────────────────────────────

  Widget _buildBreakdown(ReferralData data) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card(_ctx),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(_ctx)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Détail',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary(_ctx))),
          const SizedBox(height: 14),
          _row('Points XP gagnés', '${data.totalXpEarned}'),
          const SizedBox(height: 10),
          _row('Filleuls récompensés', '${data.totalRewarded}'),
          const SizedBox(height: 10),
          _row('Filleuls inscrits', '${data.totalFilleuls}'),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary(_ctx))),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary(_ctx))),
      ],
    );
  }

  // ── Note "bientôt disponible" ───────────────────────────────────────────────

  Widget _buildComingSoonNote() {
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
              'La conversion de vos points en argent sera bientôt disponible. Vous serez notifié dès l\'ouverture de cette fonctionnalité.',
              style: TextStyle(fontSize: 12, color: Color(0xFF92400E), height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  // ── Bouton conversion (désactivé) ───────────────────────────────────────────

  Widget _buildConvertButton() {
    return SizedBox(
      width: double.infinity, height: 56,
      child: ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.cardAlt(_ctx),
          disabledBackgroundColor: AppColors.cardAlt(_ctx),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline_rounded, size: 18, color: AppColors.textSecondary(_ctx)),
            const SizedBox(width: 10),
            Text('Convertir mes points — bientôt disponible',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textSecondary(_ctx))),
          ],
        ),
      ),
    );
  }
}
