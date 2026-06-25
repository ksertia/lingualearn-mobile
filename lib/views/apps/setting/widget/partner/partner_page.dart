import 'package:tibi/helpers/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const Color _kOrange     = Color(0xFFF27F22);


class PartnerPage extends StatelessWidget {
  const PartnerPage({super.key});

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
                  _buildCodePendingCard(context),
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
        'Partenariat',
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
                    'Devenez\nPartenaire TiBi',
                    style: TextStyle(
                      color: Colors.white, fontSize: 26,
                      fontWeight: FontWeight.w800, height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Partagez votre code et gagnez\nune commission sur chaque abonnement.',
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
        _buildChip(context, icon: Icons.percent_rounded,    label: 'Commission',  sub: 'par paiement', color: Colors.black,            bg: Colors.grey.shade200),
        const SizedBox(width: 12),
        _buildChip(context, icon: Icons.people_alt_rounded,  label: 'Parrainages', sub: 'illimites',    color:  Colors.black, bg:  Colors.grey.shade200),
        const SizedBox(width: 12),
        _buildChip(context, icon: Icons.bolt_rounded,        label: 'Activation',  sub: 'instantanee',  color: Colors.black, bg: Colors.grey.shade200),
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

  // ── Code pending card ──────────────────────────────────────────────────────

  Widget _buildCodePendingCard(BuildContext context) {
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
                      Text('Votre code partenaire',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary(context))),
                      Text('Unique et lie a votre compte',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary(context))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 22),
              decoration: BoxDecoration(
                color: AppColors.bgPartner(context),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
              ),
              child: Column(
                children: [
                  Icon(Icons.lock_outline_rounded, color: Colors.grey.shade400, size: 30),
                  const SizedBox(height: 8),
                  Text('Code non encore genere',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Divider(height: 1, color: Color(0xFFF3F4F6)),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: () => Get.toNamed('/partenaire/dashboard'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kOrange, foregroundColor: const Color(0xFF1A1A1A),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text('Generer mon code',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold,color: Colors.white.withValues(alpha: 0.95))),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Comment ça marche ──────────────────────────────────────────────────────

  Widget _buildHowItWorks(BuildContext context) {
    final steps = [
      (num: '01', icon: Icons.auto_awesome_rounded, iconColor:  Colors.black, iconBg: Colors.grey.shade200, title: 'Generez votre code',    desc: 'Obtenez votre code unique personnel en un seul clic.'),
      (num: '02', icon: Icons.share_rounded,         iconColor: Colors.black, iconBg: Colors.grey.shade200, title: 'Partagez-le',            desc: 'Diffusez-le a vos proches, amis ou sur vos reseaux sociaux.'),
      (num: '03', icon: Icons.percent_rounded,       iconColor: Colors.black,            iconBg: Colors.grey.shade200, title: 'Gagnez des commissions', desc: 'Recevez une commission sur chaque abonnement souscrit avec votre code.'),
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
