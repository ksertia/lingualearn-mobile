import 'package:tibi/controller/apps/settings/settings_controller.dart';
import 'package:tibi/helpers/constant/images.dart';
import 'package:tibi/helpers/storage/local_storage.dart';
import 'package:tibi/helpers/theme/app_colors.dart';
import 'package:tibi/helpers/theme/app_notifier.dart';
import 'package:tibi/helpers/utils/ui_mixins.dart';
import 'package:tibi/views/apps/setting/widget/contact_support.dart';
import 'package:tibi/views/apps/setting/widget/help.dart';
import 'package:tibi/views/apps/setting/widget/logout_bottom_sheet.dart';
import 'package:tibi/views/apps/setting/widget/abonnement/subsciption_plan.dart';
import 'package:tibi/views/ui/apploader.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

const Color _kGreen      = Color(0xFF188329);
const Color _kOrange     = Color(0xFFF27F22);


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
          body: Obx(() {
            if (controller.isLoading.value && controller.user.value == null) {
              return const AppLoader();
            }

            final user = controller.user.value;
            final bool isSub = user?.accountType == 'sub_account_learner';
            final bool isDark = AppColors.isDark(context);
            final Color bg = AppColors.bg(context);
            final Color cardBg = AppColors.card(context);
            final Color textPrimary = AppColors.textPrimary(context);
            final Color textSecondary = AppColors.textSecondary(context);
            final Color dividerColor = AppColors.divider(context);

            return Stack(
              children: [
                Container(color: bg),
                ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildHeader(user, isSub),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),

                          // ── Premium banner ─────────────────────────────
                          if (!isSub) ...[
                            _buildPremiumBanner(),
                            const SizedBox(height: 24),
                          ],

                          // ── Préférences ────────────────────────────────
                          _buildSectionTitle('Préférences', isDark),
                          const SizedBox(height: 10),
                          _buildCard(cardBg, [
                            _buildLanguageItem(
                                textPrimary, textSecondary, dividerColor),
                            _buildDarkModeItem(textPrimary),
                          ]),

                          const SizedBox(height: 24),

                          // ── Compte ─────────────────────────────────────
                          if (!isSub) ...[
                            _buildSectionTitle('Compte', isDark),
                            const SizedBox(height: 10),
                            _buildCard(cardBg, [
                              _buildItem(
                                icon: Icons.people_rounded,
                                iconBg: const Color(0xFFEDE9FF),
                                iconColor: const Color(0xFF7C3AED),
                                title: 'Rattacher un compte',
                                textColor: textPrimary,
                                dividerColor: dividerColor,
                                showDivider: true,
                                onTap: () => Get.toNamed('/souscomptes'),
                              ),
                              _buildItem(
                                icon: Icons.credit_card_rounded,
                                iconBg: const Color(0xFFFFF3E0),
                                iconColor: _kOrange,
                                title: 'Gérer mon abonnement',
                                textColor: textPrimary,
                                dividerColor: dividerColor,
                                showDivider: true,
                                onTap: () =>
                                    Get.toNamed('/subscription_details'),
                              ),
                              _buildItem(
                                icon: Icons.handshake_rounded,
                                iconBg: const Color(0xFFDCFCE7),
                                iconColor: _kGreen,
                                title: 'Devenir partenaire',
                                textColor: textPrimary,
                                dividerColor: dividerColor,
                                showDivider: false,
                                onTap: () => Get.toNamed('/partenaire'),
                              ),
                            ]),
                            const SizedBox(height: 24),
                          ],

                          // ── Sécurité ───────────────────────────────────
                          _buildSectionTitle('Sécurité', isDark),
                          const SizedBox(height: 10),
                          _buildCard(cardBg, [
                            _buildItem(
                              icon: Icons.lock_rounded,
                              iconBg: const Color(0xFFFFE4E4),
                              iconColor: const Color(0xFFEF4444),
                              title: 'Changer le mot de passe',
                              textColor: textPrimary,
                              dividerColor: dividerColor,
                              showDivider: false,
                              onTap: () => Get.toNamed('/change_password'),
                            ),
                          ]),

                          const SizedBox(height: 24),

                          // ── Support ────────────────────────────────────
                          _buildSectionTitle('Support', isDark),
                          const SizedBox(height: 10),
                          _buildCard(cardBg, [
                            _buildItem(
                              icon: Icons.help_outline_rounded,
                              iconBg: const Color(0xFFEDE9FF),
                              iconColor: const Color(0xFF7C3AED),
                              title: "Centre d'aide",
                              textColor: textPrimary,
                              dividerColor: dividerColor,
                              showDivider: true,
                              onTap: () => Get.to(() => const HelpPage()),
                            ),
                            _buildItem(
                              icon: Icons.chat_bubble_outline_rounded,
                              iconBg: const Color(0xFFE0F2FE),
                              iconColor: const Color(0xFF0EA5E9),
                              title: 'Contacter le support',
                              textColor: textPrimary,
                              dividerColor: dividerColor,
                              showDivider: true,
                              onTap: () =>
                                  Get.to(() => const ContactSupportPage()),
                            ),
                            
                          ]),

                          const SizedBox(height: 24),

                          // ── Déconnexion ────────────────────────────────
                          _buildLogoutButton(),

                          const SizedBox(height: 20),
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

                // Loading overlay
                if (controller.isLoading.value)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.35),
                      child: const Center(
                          child: CircularProgressIndicator(color: _kOrange)),
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

  Widget _buildHeader(dynamic user, bool isSub) {
    String name;
    if (user == null) {
      name = LocalStorage.getUserName() ?? 'Apprenant';
    } else if (!isSub) {
      final profileName =
          '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim();
      final savedName = LocalStorage.getUserName();
      final hasFreshName =
          profileName.isNotEmpty && profileName != (user.username ?? '');
      final hasSavedName = savedName != null &&
          savedName.isNotEmpty &&
          savedName != 'Apprenant';
      if (hasFreshName) {
        name = profileName;
      } else if (hasSavedName) {
        name = savedName;
      } else {
        name = user.username ?? 'Apprenant';
      }
    } else {
      name = user.username ?? LocalStorage.getUserName() ?? 'Apprenant';
    }

    final String subtitle = user?.email ?? user?.phone ?? '';
    final String accountLabel = isSub ? 'Sous-compte' : 'Apprenant';

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_kOrange, _kOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 20,
        20,
        24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar with online dot
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.50),
                          width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.22),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 38,
                      backgroundColor:
                          Colors.white.withValues(alpha: 0.20),
                      backgroundImage: AssetImage(Images.avatars[2]),
                    ),
                  ),
                  Positioned(
                    bottom: 3,
                    right: 3,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: Colors.white, width: 2.5),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              // Name + email + badge
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSub
                                ? Icons.person_outline_rounded
                                : Icons.school_rounded,
                            color: Colors.white,
                            size: 11,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            accountLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
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
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

        ],
      ),
    );
  }

  // ── Premium banner ─────────────────────────────────────────────────────────

  Widget _buildPremiumBanner() {
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const SubscriptionPlansPage(isBottomSheet: true),
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF27F22), Color(0xFFD95E00)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF27F22).withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.workspace_premium_rounded,
                  color: Colors.white, size: 22),
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
                        fontSize: 15),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Accès illimité à tous les parcours.',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.20),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.30), width: 1),
              ),
              child: const Text(
                'Voir',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Section title ──────────────────────────────────────────────────────────

  Widget _buildSectionTitle(String title, bool isDark) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_kOrange, _kOrange],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: isDark ? Colors.white70 : const Color(0xFF1A1A1A),
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  // ── Card container ─────────────────────────────────────────────────────────

  Widget _buildCard(Color bg, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  // ── Generic item ───────────────────────────────────────────────────────────

  Widget _buildItem({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    String? subtitle,
    required Color textColor,
    required Color dividerColor,
    required bool showDivider,
    required VoidCallback? onTap,
    bool showArrow = true,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                              color: textColor.withValues(alpha: 0.50),
                              fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                ),
                if (showArrow)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: iconColor.withValues(alpha: 0.70),
                      size: 18,
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.only(left: 70),
            child: Divider(height: 1, color: dividerColor),
          ),
      ],
    );
  }

  // ── Language item ──────────────────────────────────────────────────────────

  Widget _buildLanguageItem(
      Color textColor, Color subtitleColor, Color dividerColor) {
    return Column(
      children: [
        InkWell(
          onTap: () => Get.toNamed('/selectLanguageScreen'),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2FE),
                    borderRadius: BorderRadius.circular(12),
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
                        fontWeight: FontWeight.w600),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _kOrange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getCurrentLanguageName(),
                    style: const TextStyle(
                        color: _kOrange,
                        fontSize: 12,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0EA5E9).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.chevron_right_rounded,
                      color: Color(0xFF0EA5E9), size: 18),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 70),
          child: Divider(height: 1, color: dividerColor),
        ),
      ],
    );
  }

  // ── Dark mode item ─────────────────────────────────────────────────────────

  Widget _buildDarkModeItem(Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B).withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
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
                  fontWeight: FontWeight.w600),
            ),
          ),
          Transform.scale(
            scale: 0.85,
            child: CupertinoSwitch(
              value: LocalStorage.getTheme() == 'Dark',
              activeTrackColor: _kOrange,
              onChanged: (val) {
                LocalStorage.setTheme(val ? 'Dark' : 'Light');
                Provider.of<AppNotifier>(context, listen: false)
                    .changeTheme();
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Logout button (standalone) ─────────────────────────────────────────────

  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: controller.isLoading.value
          ? null
          : () => _handleLogout(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: const Color(0xFFFFE4E4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: const Color(0xFFEF4444).withValues(alpha: 0.20),
              width: 1.5),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 20),
            SizedBox(width: 10),
            Text(
              'Se déconnecter',
              style: TextStyle(
                color: Color(0xFFEF4444),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Logout handler ─────────────────────────────────────────────────────────

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LogoutDeleteBottomSheet(
        title: 'Déconnexion',
        subTitle: 'Êtes-vous sûr de vouloir vous déconnecter ?',
      ),
    );
    if (confirmed == true) await controller.onLogout();
  }

  String _getCurrentLanguageName() {
    switch (controller.selectedLanguageIndex.value) {
      case 0: return 'Français';
      case 1: return 'Anglais';
      case 2: return 'Mooré';
      case 3: return 'Dioula';
      default: return 'Français';
    }
  }
}
