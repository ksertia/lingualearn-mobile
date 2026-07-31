import 'package:tibi/controller/apps/partner/partner_controller.dart';
import 'package:tibi/helpers/theme/app_colors.dart';
import 'package:tibi/models/partner/referral_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const Color _kOrange     = Color(0xFFF27F22);

class PartnerPage extends StatefulWidget {
  const PartnerPage({super.key});

  @override
  State<PartnerPage> createState() => _PartnerPageState();
}

class _PartnerPageState extends State<PartnerPage> {
  final PartnerController controller = Get.put(PartnerController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPartner(context),
      body: CustomScrollView(
        slivers: [
          _buildSliverHeader(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsChipsRow(context),
                  const SizedBox(height: 24),
                  Obx(() => _buildCodeCard(context)),
                  const SizedBox(height: 24),
                  _buildHowItWorks(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Sliver header ──────────────────────────────────────────────────────────

  Widget _buildSliverHeader() {
    return SliverAppBar(
      expandedHeight: 240,
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
          child: const Icon(Icons.arrow_back_ios_rounded,
              color: Colors.white, size: 18),
        ),
      ),
      title: const Text(
        'Parrainage',
        style: TextStyle(
            color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700),
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
              right: 40, top: 60,
              child: Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            Positioned(
              left: 20, right: 20, bottom: 28,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.handshake_rounded,
                        color: Colors.white, size: 26),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Devenez\nParrain TiBi',
                    style: TextStyle(
                      color: Colors.white, fontSize: 26,
                      fontWeight: FontWeight.w800, height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Partagez votre code et gagnez des points\npour chaque filleul qui rejoint TiBi.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.80),
                      fontSize: 13, height: 1.5,
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

  // ── Chips ──────────────────────────────────────────────────────────────────

  Widget _buildStatsChipsRow(BuildContext context) {
    return Row(
      children: [
        _buildChip(context, icon: Icons.savings_rounded,     label: 'Points',      sub: 'par filleul',  color: AppColors.textPrimary(context),            bg: AppColors.cardAlt(context)),
        const SizedBox(width: 12),
        _buildChip(context, icon: Icons.people_alt_rounded,  label: 'Parrainages', sub: 'illimites',    color:  AppColors.textPrimary(context), bg:  AppColors.cardAlt(context)),
        const SizedBox(width: 12),
        _buildChip(context, icon: Icons.bolt_rounded,        label: 'Activation',  sub: 'instantanee',  color: AppColors.textPrimary(context), bg: AppColors.cardAlt(context)),
      ],
    );
  }

  Widget _buildChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String sub,
    required Color color,
    required Color bg,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.card(context),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow(context),
              blurRadius: 10, offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary(context)),
                textAlign: TextAlign.center),
            Text(sub,
                style: TextStyle(fontSize: 10, color: AppColors.textSecondary(context), fontWeight: FontWeight.w500),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  // ── Code card ───────────────────────────────────────────────────────────────

  Widget _buildCodeCard(BuildContext context) {
    final bool isLoading = controller.isLoading.value;
    final ReferralData? data = controller.referralData.value;
    final String? error = controller.loadErrorMsg.value;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow(context),
            blurRadius: 14, offset: const Offset(0, 5),
          ),
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
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF9E0),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(Icons.qr_code_rounded, color: _kOrange, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Votre code de parrainage',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary(context))),
                      Text('Unique et lié à votre compte',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary(context))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (data != null)
            _buildCodeReady(context, data)
          else if (isLoading)
            _buildCodeLoading(context)
          else
            _buildCodeError(context, error),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCodeReady(BuildContext context, ReferralData data) {
    return Column(
      children: [
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
                  context,
                  icon: Icons.copy_rounded, label: 'Copier',
                  onTap: controller.copyReferralCode,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _actionBtn(
                  context,
                  icon: Icons.share_rounded, label: 'Partager',
                  onTap: controller.shareReferralCode,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Divider(height: 1, color: AppColors.divider(context)),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: SizedBox(
            width: double.infinity, height: 52,
            child: ElevatedButton(
              onPressed: () => Get.toNamed('/partenaire/dashboard'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _kOrange, foregroundColor: const Color(0xFF1A1A1A),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text('Voir mon tableau de bord',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white.withValues(alpha: 0.95))),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCodeLoading(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 22),
        decoration: BoxDecoration(
          color: AppColors.bgPartner(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border(context), width: 1.5),
        ),
        child: const Center(
          child: SizedBox(
            width: 26, height: 26,
            child: CircularProgressIndicator(strokeWidth: 2.5, color: _kOrange),
          ),
        ),
      ),
    );
  }

  Widget _buildCodeError(BuildContext context, String? message) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.bgPartner(context),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border(context), width: 1.5),
            ),
            child: Column(
              children: [
                Icon(Icons.error_outline_rounded, color: AppColors.textSecondary(context), size: 30),
                const SizedBox(height: 8),
                Text(
                  message ?? 'Impossible de charger votre code de parrainage',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary(context), fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SizedBox(
            width: double.infinity, height: 48,
            child: OutlinedButton(
              onPressed: controller.fetchMyReferral,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: _kOrange),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Réessayer', style: TextStyle(color: _kOrange, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _actionBtn(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        decoration: BoxDecoration(color: AppColors.cardAlt(context), borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.textPrimary(context), size: 18),
            const SizedBox(width: 7),
            Text(label, style: TextStyle(color: AppColors.textPrimary(context), fontSize: 13, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  // ── Comment ça marche ──────────────────────────────────────────────────────

  Widget _buildHowItWorks(BuildContext context) {
    final steps = [
      (num: '01', icon: Icons.auto_awesome_rounded, iconColor:  AppColors.textPrimary(context), iconBg: AppColors.cardAlt(context), title: 'Recuperez votre code',    desc: 'Votre code unique et personnel est genere automatiquement pour vous.'),
      (num: '02', icon: Icons.share_rounded,         iconColor: AppColors.textPrimary(context), iconBg: AppColors.cardAlt(context), title: 'Partagez-le',            desc: 'Diffusez-le a vos proches, amis ou sur vos reseaux sociaux.'),
      (num: '03', icon: Icons.savings_rounded,       iconColor: AppColors.textPrimary(context),            iconBg: AppColors.cardAlt(context), title: 'Gagnez des points', desc: 'Recevez des points pour chaque filleul qui rejoint TiBi avec votre code.'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Comment ca marche ?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary(context))),
        const SizedBox(height: 14),
        ...steps.asMap().entries.map((e) {
          final i = e.key;
          final s = e.value;
          return Padding(
            padding: EdgeInsets.only(bottom: i < steps.length - 1 ? 12 : 0),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.card(context),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: AppColors.shadow(context), blurRadius: 10, offset: const Offset(0, 3)),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 46, height: 46,
                          decoration: BoxDecoration(color: s.iconBg, borderRadius: BorderRadius.circular(14)),
                          child: Icon(s.icon, color: s.iconColor, size: 22),
                        ),
                        Positioned(
                          top: -6, right: -6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(6)),
                            child: Text(s.num,
                                style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.title,
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary(context))),
                          const SizedBox(height: 3),
                          Text(s.desc,
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary(context), height: 1.45)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
