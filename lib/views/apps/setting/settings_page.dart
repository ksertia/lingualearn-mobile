import 'package:fasolingo/controller/apps/settings/settings_controller.dart';
import 'package:fasolingo/helpers/constant/images.dart';
import 'package:fasolingo/helpers/storage/local_storage.dart';
import 'package:fasolingo/helpers/theme/app_notifier.dart';
import 'package:fasolingo/helpers/utils/ui_mixins.dart';
import 'package:fasolingo/views/apps/setting/widget/contact_support.dart';
import 'package:fasolingo/views/apps/setting/widget/help.dart';
import 'package:fasolingo/views/apps/setting/widget/logout_bottom_sheet.dart';
import 'package:fasolingo/views/apps/setting/widget/subsciption_plan.dart';
import 'package:fasolingo/views/ui/apploader.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

const Color _sOrange  = Color(0xFFFF7043);
const Color _sOrange2 = Color(0xFFFFB74D);

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen>
    with SingleTickerProviderStateMixin, UIMixin {
  final controller = Get.put(SettingsController());

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Consumer<AppNotifier>(
        builder: (_, value, child) => Scaffold(
          //backgroundColor: contentTheme.background,
          body: Obx(() {
            if (controller.isLoading.value && controller.user.value == null) {
              return const AppLoader();
            }

            final user = controller.user.value;
            final bool isSub = user?.accountType == 'sub_account_learner';
            final bool isDark = LocalStorage.getTheme() == 'Dark';
            final Color cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
            final Color textPrimary = isDark ? Colors.white : const Color(0xFF1A1A1A);
            final Color textSecondary = isDark ? Colors.white60 : const Color(0xFF888888);
            final Color dividerColor = isDark ? Colors.white12 : const Color(0xFFEEEEEE);

            return Stack(
              children: [
                ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    // ── Header gradient ─────────────────────────────────
                    _buildHeader(user, cardBg, textPrimary, textSecondary),

                    const SizedBox(height: 8),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          // ── Premium banner (non-sub) ─────────────────
                          if (!isSub) ...[
                            _buildPremiumBanner(),
                            const SizedBox(height: 20),
                          ],

                          // ── Préférences ──────────────────────────────
                          _buildSectionTitle('Preferences'),
                          const SizedBox(height: 10),
                          _buildCard(cardBg, dividerColor, [
                            _buildLanguageItem(textPrimary, textSecondary),
                            _buildDivider(dividerColor),
                            _buildDarkModeItem(textPrimary),
                          ]),

                          const SizedBox(height: 20),

                          // ── Compte (non-sub) ─────────────────────────
                          if (!isSub) ...[
                            _buildSectionTitle('Compte'),
                            const SizedBox(height: 10),
                            _buildCard(cardBg, dividerColor, [
                              _buildItem(
                                icon: Icons.people_rounded,
                                iconBg: const Color(0xFFEDE9FF),
                                iconColor: const Color(0xFF7C3AED),
                                title: 'Rattacher un compte',
                                textColor: textPrimary,
                                onTap: () => Get.toNamed('/souscomptes'),
                              ),
                              _buildDivider(dividerColor),
                              _buildItem(
                                icon: Icons.bar_chart_rounded,
                                iconBg: const Color(0xFFE0F2FE),
                                iconColor: const Color(0xFF0EA5E9),
                                title: 'Parcours du compte rattache',
                                textColor: textPrimary,
                                onTap: () => Get.toNamed('/children_progress'),
                              ),
                              _buildDivider(dividerColor),
                              _buildItem(
                                icon: Icons.credit_card_rounded,
                                iconBg: const Color(0xFFFFF3E0),
                                iconColor: _sOrange,
                                title: 'Gerer mon abonnement',
                                textColor: textPrimary,
                                onTap: () => Get.toNamed('/subscription_details'),
                              ),
                            ]),
                            const SizedBox(height: 20),
                          ],

                          // ── Securite ─────────────────────────────────
                          _buildSectionTitle('Securite'),
                          const SizedBox(height: 10),
                          _buildCard(cardBg, dividerColor, [
                            _buildItem(
                              icon: Icons.lock_rounded,
                              iconBg: const Color(0xFFFFE4E4),
                              iconColor: const Color(0xFFEF4444),
                              title: 'Changer le mot de passe',
                              textColor: textPrimary,
                              onTap: () => Get.toNamed('/change_password'),
                            ),
                          ]),

                          const SizedBox(height: 20),

                          // ── Support ──────────────────────────────────
                          _buildSectionTitle('Support'),
                          const SizedBox(height: 10),
                          _buildCard(cardBg, dividerColor, [
                            _buildItem(
                              icon: Icons.help_outline_rounded,
                              iconBg: const Color(0xFFEDE9FF),
                              iconColor: const Color(0xFF7C3AED),
                              title: "Centre d'aide",
                              textColor: textPrimary,
                              onTap: () => Get.to(() => const HelpPage()),
                            ),
                            _buildDivider(dividerColor),
                            _buildItem(
                              icon: Icons.chat_bubble_outline_rounded,
                              iconBg: const Color(0xFFE0F2FE),
                              iconColor: const Color(0xFF0EA5E9),
                              title: 'Contacter le support',
                              textColor: textPrimary,
                              onTap: () =>
                                  Get.to(() => const ContactSupportPage()),
                            ),
                            _buildDivider(dividerColor),
                            _buildItem(
                              icon: Icons.star_outline_rounded,
                              iconBg: const Color(0xFFFFF9E6),
                              iconColor: const Color(0xFFF59E0B),
                              title: "Noter l'application",
                              textColor: textPrimary,
                              onTap: () => Get.snackbar(
                                'Merci !',
                                'Votre avis nous aide a nous ameliorer.',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.black87,
                                colorText: Colors.white,
                                margin: const EdgeInsets.all(16),
                                borderRadius: 14,
                              ),
                            ),
                          ]),

                          const SizedBox(height: 20),

                          // ── Deconnexion ──────────────────────────────
                          _buildCard(cardBg, dividerColor, [
                            _buildItem(
                              icon: Icons.logout_rounded,
                              iconBg: const Color(0xFFFFE4E4),
                              iconColor: const Color(0xFFEF4444),
                              title: 'Deconnexion',
                              textColor: const Color(0xFFEF4444),
                              showArrow: false,
                              onTap: controller.isLoading.value
                                  ? null
                                  : () => _handleLogout(context),
                            ),
                          ]),

                          const SizedBox(height: 24),

                          Center(
                            child: Text(
                              'TiBi v1.0.0',
                              style: TextStyle(
                                fontSize: 12,
                                color: textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ],
                ),

                if (controller.isLoading.value)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.35),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────

  Widget _buildHeader(dynamic user, Color cardBg, Color textPrimary, Color textSecondary) {
    final bool isSubAccount = user?.accountType == 'sub_account_learner';

    String name;
    if (user == null) {
      name = LocalStorage.getUserName() ?? 'Apprenant';
    } else if (!isSubAccount) {
      // Compte principal : prénom + nom
      // Priorité : données fraîches du profil → nom sauvegardé à la connexion → username
      final profileName = '${user.firstName} ${user.lastName}'.trim();
      final savedName = LocalStorage.getUserName();
      final hasFreshName = profileName.isNotEmpty && profileName != (user.username ?? '');
      final hasSavedName = savedName != null && savedName.isNotEmpty && savedName != 'Apprenant';

      if (hasFreshName) {
        name = profileName;
      } else if (hasSavedName) {
        name = savedName;
      } else {
        name = user.username ?? 'Apprenant';
      }
    } else {
      // Sous-compte : username
      name = user.username ?? LocalStorage.getUserName() ?? 'Apprenant';
    }

    final String subtitle = user?.email ?? user?.phone ?? '';

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_sOrange, _sOrange2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 20,
        20,
        28,
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 2.5),
            ),
            child: CircleAvatar(
              radius: 34,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              backgroundImage: AssetImage(Images.avatars[2]),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Get.toNamed('/edit_profile'),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.edit_rounded, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  // ── Premium banner ───────────────────────────────────────────────────────────

  Widget _buildPremiumBanner() {
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const SubscriptionPlansPage(isBottomSheet: true),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7C3AED), Color(0xFF5B21B6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.30),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.20),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.star_rounded, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Passez au Premium',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Acces illimite a tous les parcours.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 14),
          ],
        ),
      ),
    );
  }

  // ── Section helpers ──────────────────────────────────────────────────────────

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: _sOrange,
        fontSize: 13,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildCard(Color bg, Color divider, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider(Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 58),
      child: Divider(height: 1, color: color),
    );
  }

  Widget _buildItem({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required Color textColor,
    required VoidCallback? onTap,
    bool showArrow = true,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (showArrow)
              Icon(Icons.chevron_right_rounded,
                  color: textColor.withValues(alpha: 0.35), size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageItem(Color textColor, Color subtitleColor) {
    return InkWell(
      onTap: () => Get.toNamed('/selectLanguageScreen'),
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2FE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.translate_rounded,
                  color: Color(0xFF0EA5E9), size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                'Langue',
                style: TextStyle(
                  color: textColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              _getCurrentLanguageName(),
              style: TextStyle(
                color: subtitleColor,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded,
                color: textColor.withValues(alpha: 0.35), size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildDarkModeItem(Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B).withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.dark_mode_rounded,
                color: Color(0xFF334155), size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Mode sombre',
              style: TextStyle(
                color: textColor,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Transform.scale(
            scale: 0.85,
            child: CupertinoSwitch(
              value: LocalStorage.getTheme() == 'Dark',
              activeTrackColor: _sOrange,
              onChanged: (val) {
                LocalStorage.setTheme(val ? 'Dark' : 'Light');
                Provider.of<AppNotifier>(context, listen: false).changeTheme();
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Logout ───────────────────────────────────────────────────────────────────

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LogoutDeleteBottomSheet(
        title: 'Deconnexion',
        subTitle: 'Etes-vous sur de vouloir vous deconnecter ?',
      ),
    );
    if (confirmed == true) await controller.onLogout();
  }

  String _getCurrentLanguageName() {
    switch (controller.selectedLanguageIndex.value) {
      case 0: return 'Francais';
      case 1: return 'Anglais';
      case 2: return 'Moore';
      case 3: return 'Dioula';
      default: return 'Francais';
    }
  }
}
