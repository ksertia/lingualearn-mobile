import 'package:fasolingo/helpers/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

const Color _green = Color(0xFF16A34A);
const String _staticCode = 'TIBI-X7K2M';

// ── Modèle retrait ────────────────────────────────────────────────────────────

class _WithdrawItem {
  final String date;
  final String amount;
  final String status;
  final bool isPaid;
  const _WithdrawItem({
    required this.date,
    required this.amount,
    required this.status,
    required this.isPaid,
  });
}

const _withdrawals = [
  _WithdrawItem(date: '15 Mai 2025',  amount: '5 000 FCFA', status: 'Paye',       isPaid: true),
  _WithdrawItem(date: '02 Avr 2025',  amount: '3 500 FCFA', status: 'Paye',       isPaid: true),
  _WithdrawItem(date: '18 Mars 2025', amount: '8 000 FCFA', status: 'Paye',       isPaid: true),
  _WithdrawItem(date: '28 Mai 2025',  amount: '7 000 FCFA', status: 'En attente', isPaid: false),
];

// ─────────────────────────────────────────────────────────────────────────────

class PartnerDashboardPage extends StatefulWidget {
  const PartnerDashboardPage({super.key});

  @override
  State<PartnerDashboardPage> createState() => _PartnerDashboardPageState();
}

class _PartnerDashboardPageState extends State<PartnerDashboardPage> {
  late BuildContext _ctx;

  @override
  Widget build(BuildContext context) {
    _ctx = context;
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
                  _buildKpiCards(),
                  const SizedBox(height: 24),
                  _buildCodeCard(),
                  const SizedBox(height: 24),
                  _buildMonthlyStats(),
                  const SizedBox(height: 24),
                  _buildWithdrawalHistory(),
                  const SizedBox(height: 16),
                  _buildWithdrawButton(),
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
      expandedHeight: 180,
      pinned: true,
      backgroundColor: _green,
      surfaceTintColor: _green,
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
        'Espace Partenaire',
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
                  colors: [Color(0xFF14532D), _green],
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
                          'Espace Partenaire',
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

  Widget _buildKpiCards() {
    return Column(
      children: [
        Row(
          children: [
            _kpiCard(
              label: 'Inscrits via code',
              value: '12',
              icon: Icons.people_alt_rounded,
              iconColor: const Color(0xFF7C3AED),
              iconBg: const Color(0xFFEDE9FF),
              trend: '+3 ce mois',
              trendUp: true,
            ),
            const SizedBox(width: 14),
            _kpiCard(
              label: 'Revenus generes',
              value: '24 500',
              unit: 'FCFA',
              icon: Icons.account_balance_wallet_rounded,
              iconColor: _green,
              iconBg: const Color(0xFFDCFCE7),
              trend: '+8 000 ce mois',
              trendUp: true,
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            _kpiCard(
              label: 'Solde disponible',
              value: '8 000',
              unit: 'FCFA',
              icon: Icons.savings_rounded,
              iconColor: const Color(0xFFD97706),
              iconBg: const Color(0xFFFEF3C7),
              trend: 'Retrait possible',
              trendUp: true,
              trendColor: const Color(0xFFD97706),
            ),
            const SizedBox(width: 14),
            _kpiCard(
              label: 'Retraits effectues',
              value: '16 500',
              unit: 'FCFA',
              icon: Icons.move_to_inbox_rounded,
              iconColor: const Color(0xFF0EA5E9),
              iconBg: const Color(0xFFE0F2FE),
              trend: '3 retraits',
              trendUp: null,
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
    required String trend,
    required bool? trendUp,
    Color? trendColor,
  }) {
    final Color tc = trendColor ??
        (trendUp == true
            ? _green
            : trendUp == false
                ? Colors.redAccent
                : const Color(0xFF9CA3AF));

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card(_ctx),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
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
                      style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Row(
              children: [
                if (trendUp != null)
                  Icon(
                    trendUp ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                    color: tc, size: 12,
                  ),
                if (trendUp != null) const SizedBox(width: 2),
                Flexible(
                  child: Text(trend,
                      style: TextStyle(fontSize: 10, color: tc, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Code card ──────────────────────────────────────────────────────────────

  Widget _buildCodeCard() {
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
                  decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(11)),
                  child: const Icon(Icons.qr_code_rounded, color: _green, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Votre code partenaire',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary(_ctx))),
                      Text('Unique et lie a votre compte',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary(_ctx))),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(20)),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, color: _green, size: 7),
                      SizedBox(width: 5),
                      Text('Actif', style: TextStyle(color: _green, fontSize: 11, fontWeight: FontWeight.w700)),
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
                  colors: [Color(0xFFF0FDF4), Color(0xFFDCFCE7)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _green.withValues(alpha: 0.30), width: 1.5),
              ),
              child: const Center(
                child: Text(
                  _staticCode,
                  style: TextStyle(
                    fontSize: 26, fontWeight: FontWeight.w800,
                    color: Color(0xFF14532D), letterSpacing: 3,
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
                    color: _green, bg: const Color(0xFFDCFCE7),
                    onTap: () {
                      Clipboard.setData(const ClipboardData(text: _staticCode));
                      Get.snackbar(
                        'Copie !', 'Code copie dans le presse-papiers.',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: _green, colorText: Colors.white,
                        margin: const EdgeInsets.all(16), borderRadius: 14,
                        duration: const Duration(seconds: 2),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _actionBtn(
                    icon: Icons.share_rounded, label: 'Partager',
                    color: const Color(0xFF0EA5E9), bg: const Color(0xFFE0F2FE),
                    onTap: () {},
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

  // ── Statistiques mensuelles ────────────────────────────────────────────────

  Widget _buildMonthlyStats() {
    final months = [
      ('Jan', 0.2), ('Fev', 0.4), ('Mar', 0.75),
      ('Avr', 0.55), ('Mai', 1.0), ('Jun', 0.3),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card(_ctx),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 14, offset: const Offset(0, 5)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDE9FF),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(Icons.bar_chart_rounded, color: Color(0xFF7C3AED), size: 20),
                ),
                const SizedBox(width: 12),
                Text('Statistiques mensuelles',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary(_ctx))),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 100,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: months.map((m) {
                  final isLast = m == months.last;
                  final isMax = m.$2 == 1.0;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: isLast ? 0 : 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            height: 78 * m.$2,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isMax
                                    ? [_green, const Color(0xFF4ADE80)]
                                    : [const Color(0xFFBBF7D0), const Color(0xFF86EFAC)],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            m.$1,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isMax ? FontWeight.w700 : FontWeight.w500,
                              color: isMax ? _green : const Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Historique des retraits ────────────────────────────────────────────────

  Widget _buildWithdrawalHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Historique des retraits',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary(_ctx))),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 14, offset: const Offset(0, 5)),
            ],
          ),
          child: Column(
            children: _withdrawals.asMap().entries.map((e) {
              final i = e.key;
              final item = e.value;
              final Color iconColor = item.isPaid ? _green : const Color(0xFFD97706);
              final Color iconBg = item.isPaid ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7);
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
                            item.isPaid ? Icons.check_circle_outline_rounded : Icons.schedule_rounded,
                            color: iconColor, size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Retrait partenaire',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary(_ctx))),
                              Text(item.date,
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(item.amount,
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: iconColor)),
                            const SizedBox(height: 3),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(20)),
                              child: Text(item.status,
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: iconColor)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (i < _withdrawals.length - 1)
                    const Padding(
                      padding: EdgeInsets.only(left: 68),
                      child: Divider(height: 1, color: Color(0xFFF3F4F6)),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ── Bouton retrait ─────────────────────────────────────────────────────────

  Widget _buildWithdrawButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF14532D), _green],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: _green.withValues(alpha: 0.35), blurRadius: 14, offset: const Offset(0, 6)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.toNamed('/partenaire/retrait'),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.20),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.savings_rounded, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Demander un retrait',
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
