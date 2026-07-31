import 'package:intl/intl.dart';
import 'package:tibi/controller/apps/partner/partner_controller.dart';
import 'package:tibi/helpers/theme/app_colors.dart';
import 'package:tibi/models/partner/referral_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const Color _kGreen      = Color(0xFF188329);
const Color _kOrange     = Color(0xFFF27F22);

class PartnerDashboardPage extends StatefulWidget {
  const PartnerDashboardPage({super.key});

  @override
  State<PartnerDashboardPage> createState() => _PartnerDashboardPageState();
}

class _PartnerDashboardPageState extends State<PartnerDashboardPage> {
  late BuildContext _ctx;
  final PartnerController controller = Get.put(PartnerController());

  @override
  Widget build(BuildContext context) {
    _ctx = context;
    return Scaffold(
      backgroundColor: AppColors.bgPartner(context),
      body: Obx(() {
        if (controller.isLoading.value && controller.referralData.value == null) {
          return _buildLoading();
        }

        final data = controller.referralData.value;
        if (data == null) {
          return _buildError(controller.loadErrorMsg.value);
        }

        return RefreshIndicator(
          onRefresh: controller.fetchMyReferral,
          child: CustomScrollView(
            slivers: [
              _buildSliverHeader(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildKpiCards(data),
                      const SizedBox(height: 24),
                      _buildCodeCard(data),
                      const SizedBox(height: 24),
                      _buildFilleulsList(data),
                      const SizedBox(height: 16),
                      _buildPointsButton(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // ── Loading / erreur ────────────────────────────────────────────────────────

  Widget _buildLoading() {
    return Container(
      color: AppColors.bgPartner(context),
      child: const Center(child: CircularProgressIndicator(color: _kOrange)),
    );
  }

  Widget _buildError(String? message) {
    return Container(
      color: AppColors.bgPartner(context),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded,
                  color: AppColors.textSecondary(context), size: 42),
              const SizedBox(height: 16),
              Text(
                message ?? 'Impossible de charger vos données de parrainage.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary(context)),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: controller.fetchMyReferral,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kOrange,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Réessayer',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Sliver header ──────────────────────────────────────────────────────────

  Widget _buildSliverHeader() {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: _kOrange,
      surfaceTintColor: _kOrange,
      leading: GestureDetector(
        onTap: () => Get.back(),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.20),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 18),
        ),
      ),
      title: const Text(
        'Espace Parrainage',
        style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700),
      ),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_kOrange, _kOrange],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Positioned(
              right: -40, top: -30,
              child: Container(
                width: 180, height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            Positioned(
              left: 20, right: 20, bottom: 24,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Tableau de bord',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.75),
                            fontSize: 13, fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Espace Parrainage',
                          style: TextStyle(
                            color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, color: Color(0xFF4ADE80), size: 8),
                        SizedBox(width: 6),
                        Text('Actif',
                            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
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

  // ── KPI cards ──────────────────────────────────────────────────────────────

  Widget _buildKpiCards(ReferralData data) {
    return Column(
      children: [
        Row(
          children: [
            _kpiCard(
              label: 'Filleuls inscrits',
              value: '${data.totalFilleuls}',
              icon: Icons.people_alt_rounded,
              iconColor: AppColors.textPrimary(_ctx),
              iconBg: AppColors.cardAlt(_ctx),
            ),
            const SizedBox(width: 14),
            _kpiCard(
              label: 'Filleuls récompensés',
              value: '${data.totalRewarded}',
              icon: Icons.emoji_events_rounded,
              iconColor: _kGreen,
              iconBg: const Color(0xFFDCFCE7),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            _kpiCard(
              label: 'Points XP gagnés',
              value: '${data.totalXpEarned}',
              icon: Icons.bolt_rounded,
              iconColor: AppColors.textPrimary(_ctx),
              iconBg: AppColors.cardAlt(_ctx),
            ),
            const SizedBox(width: 14),
            _kpiCard(
              label: 'Points gagnés',
              value: '${data.totalCoinsEarned}',
              icon: Icons.savings_rounded,
              iconColor: const Color(0xFFD97706),
              iconBg: const Color(0xFFFEF3C7),
            ),
          ],
        ),
      ],
    );
  }

  Widget _kpiCard({
    required String label,
    required String value,
    String? unit,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card(_ctx),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow(_ctx),
              blurRadius: 12, offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(height: 12),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary(_ctx),
                    ),
                  ),
                  if (unit != null)
                    TextSpan(
                      text: ' $unit',
                      style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary(_ctx),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary(_ctx), fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  // ── Code card ──────────────────────────────────────────────────────────────

  Widget _buildCodeCard(ReferralData data) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card(_ctx),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: AppColors.shadow(_ctx), blurRadius: 14, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              children: [
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(color: const Color(0xFFFFF9E0), borderRadius: BorderRadius.circular(11)),
                  child: const Icon(Icons.qr_code_rounded, color: _kOrange, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Votre code de parrainage',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary(_ctx))),
                      Text('Unique et lié à votre compte',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary(_ctx))),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFFFF9E0), borderRadius: BorderRadius.circular(20)),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, color: _kOrange, size: 7),
                      SizedBox(width: 5),
                      Text('Actif', style: TextStyle(color: _kOrange, fontSize: 11, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFFBEB), Color(0xFFFFF9E0)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _kOrange.withValues(alpha: 0.30), width: 1.5),
              ),
              child: Center(
                child: Text(
                  data.referralCode,
                  style: const TextStyle(
                    fontSize: 26, fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A1A), letterSpacing: 3,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: _actionBtn(
                    icon: Icons.copy_rounded, label: 'Copier',
                    color:  AppColors.textPrimary(_ctx), bg:  AppColors.cardAlt(_ctx),
                    onTap: controller.copyReferralCode,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _actionBtn(
                    icon: Icons.share_rounded, label: 'Partager',
                    color:  AppColors.textPrimary(_ctx), bg:  AppColors.cardAlt(_ctx),
                    onTap: controller.shareReferralCode,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ── Liste des filleuls ──────────────────────────────────────────────────────

  Widget _buildFilleulsList(ReferralData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Vos filleuls',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary(_ctx))),
        const SizedBox(height: 14),
        if (data.filleuls.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.card(_ctx),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: AppColors.shadow(_ctx), blurRadius: 14, offset: const Offset(0, 5)),
              ],
            ),
            child: Column(
              children: [
                Icon(Icons.person_add_alt_1_rounded, color: AppColors.textSecondary(_ctx), size: 32),
                const SizedBox(height: 10),
                Text('Aucun filleul pour l\'instant',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary(_ctx))),
                const SizedBox(height: 4),
                Text('Partagez votre code pour commencer à gagner des points.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary(_ctx))),
              ],
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: AppColors.card(_ctx),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: AppColors.shadow(_ctx), blurRadius: 14, offset: const Offset(0, 5)),
              ],
            ),
            child: Column(
              children: data.filleuls.asMap().entries.map((e) {
                final i = e.key;
                final f = e.value;
                final Color iconColor = f.isRewarded ? _kGreen : const Color(0xFFD97706);
                final Color iconBg = f.isRewarded ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7);
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
                            child: Icon(
                              f.isRewarded ? Icons.check_circle_outline_rounded : Icons.schedule_rounded,
                              color: iconColor, size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(f.displayName,
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary(_ctx))),
                                if (f.joinedAt != null)
                                  Text(DateFormat('dd MMM yyyy', 'fr_FR').format(f.joinedAt!.toLocal()),
                                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary(_ctx))),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(20)),
                            child: Text(f.isRewarded ? 'Récompensé' : 'En attente',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: iconColor)),
                          ),
                        ],
                      ),
                    ),
                    if (i < data.filleuls.length - 1)
                      Padding(
                        padding: const EdgeInsets.only(left: 68),
                        child: Divider(height: 1, color: AppColors.divider(_ctx)),
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  // ── Bouton points ────────────────────────────────────────────────────────────

  Widget _buildPointsButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_kOrange, _kOrange],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: _kOrange.withValues(alpha: 0.35), blurRadius: 14, offset: const Offset(0, 6)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.toNamed('/partenaire/retrait'),
          borderRadius: BorderRadius.circular(16),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.savings_rounded, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Text(
                  'Voir mes points',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Helper ─────────────────────────────────────────────────────────────────

  Widget _actionBtn({
    required IconData icon,
    required String label,
    required Color color,
    required Color bg,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 7),
            Text(label, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
