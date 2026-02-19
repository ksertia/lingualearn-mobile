import 'package:fasolingo/controller/apps/settings/settings_controller.dart';
import 'package:fasolingo/helpers/constant/images.dart';
import 'package:fasolingo/helpers/my_widgets/my_text.dart';
import 'package:fasolingo/helpers/storage/local_storage.dart';
import 'package:fasolingo/helpers/theme/app_notifier.dart';
import 'package:fasolingo/helpers/utils/ui_mixins.dart';
import 'package:fasolingo/views/apps/setting/widget/logout_bottom_sheet.dart';
import 'package:fasolingo/views/ui/apploader.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen>
    with SingleTickerProviderStateMixin, UIMixin {
  final controller = Get.put(SettingsController());
  String firstName = LocalStorage.getUserName() ?? "Champion";

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Consumer<AppNotifier>(
        builder: (_, value, child) => Scaffold(
          backgroundColor: contentTheme.background,
          body: Obx(() {
            if (controller.isLoading.value && controller.user.value == null) {
              return const AppLoader();
            }

            final bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;

            return Stack(
              children: [
                Column(
                  children: [
                    SizedBox(height: isIOS ? 70 : 60),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildProfileSection(),
                    ),
                    const SizedBox(height: 25),
                    Divider(color: contentTheme.kE6E6E6, thickness: 1.0)
                        .paddingSymmetric(horizontal: 20),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        children: [
                          const SizedBox(height: 15),

                          _buildPremiumCard(),

                          const SizedBox(height: 20),

                          _buildLanguageSetting(),
                          _buildDarkModeSetting(),

                          // --- GÉRER ABONNEMENT ---
                          _buildSettingsItem(
                            iconWidget: Icon(Icons.credit_card_rounded,
                                color: contentTheme.black, size: 24),
                            title: 'Gérer mon abonnement',
                            onTap: () {
                              Get.toNamed('/subscription_details');
                            },
                          ),

                          const SizedBox(height: 15),
                          Divider(color: contentTheme.kE6E6E6, thickness: 1.0),

                          // --- RÉINITIALISER ---
                          _buildSettingsItem(
                            iconWidget: Icon(Icons.restart_alt_rounded,
                                color: Colors.redAccent, size: 24),
                            title: 'Réinitialiser ma progression',
                            onTap: () => _handleResetAccount(context),
                          ),

                          // --- DÉCONNEXION ---
                          _buildSettingsItem(
                            icon: Images.logout,
                            title: 'Déconnexion',
                            onTap: controller.isLoading.value
                                ? null
                                : () => _handleLogout(context),
                          ),

                          const SizedBox(height: 15),
                          Divider(color: contentTheme.kE6E6E6, thickness: 1.0),

                          const SizedBox(height: 30),
                          Center(
                            child: MyText.bodySmall(
                              "Version 1.0.0",
                              color: contentTheme.black.withOpacity(0.3),
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
                      color: Colors.black.withOpacity(0.35),
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

  // --- LOGIQUE DE RÉINITIALISATION ---
  Future<void> _handleResetAccount(BuildContext context) async {
    Get.defaultDialog(
      title: "Réinitialiser ?",
      middleText:
          "Es-tu sûr de vouloir effacer ta progression pour choisir une autre langue ?",
      textConfirm: "Réinitialiser",
      textCancel: "Annuler",
      confirmTextColor: Colors.white,
      buttonColor: Colors.redAccent,
      onConfirm: () {
        Get.back();
        Get.snackbar(
          "Succès",
          "Progression réinitialisée (Simulation UI)",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orangeAccent.withOpacity(0.8),
        );
      },
    );
  }

  // --- WIDGETS ---

  Widget _buildProfileSection() {
    final user = controller.user.value;
    return Row(
      children: [
        CircleAvatar(
          radius: 35,
          backgroundColor: contentTheme.primary.withOpacity(0.1),
          backgroundImage: AssetImage(Images.avatars[2]),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyText.titleMedium(firstName,
                  fontWeight: 700, fontSize: 18, color: contentTheme.black),
              const SizedBox(height: 2),
              MyText.bodyMedium(user?.email ?? "Email non disponible",
                  fontWeight: 400,
                  fontSize: 14,
                  color: contentTheme.black.withOpacity(0.6))
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumCard() {
    return InkWell(
      onTap: () => Get.toNamed('/subscription_plans'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              contentTheme.primary,
              contentTheme.primary.withOpacity(0.8)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: contentTheme.primary.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
              child:
                  const Icon(Icons.star_rounded, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText.titleSmall("Passez au Premium",
                      color: Colors.white, fontWeight: 700),
                  MyText.bodySmall("Accès illimité à tous les parcours.",
                      color: Colors.white.withOpacity(0.9)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
          ],
        ),
      ),
    );
  }

  // --- LA FONCTION CORRIGÉE ICI ---
  Widget _buildSettingsItem(
      {String? icon,
      Widget? iconWidget, // Nouveau paramètre ajouté
      required String title,
      required VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Row(
          children: [
            // On vérifie si on utilise une image asset ou un widget d'icône
            if (icon != null)
              Image.asset(icon,
                  width: 28, height: 28, color: contentTheme.black)
            else if (iconWidget != null)
              SizedBox(width: 28, height: 28, child: iconWidget)
            else
              const SizedBox(width: 28, height: 28), // Fallback vide

            const SizedBox(width: 16),
            Expanded(
                child: MyText.titleMedium(title,
                    fontWeight: 600,
                    fontSize: 16,
                    color: title.contains('Réinitialiser')
                        ? Colors.redAccent
                        : contentTheme.black)),
            Icon(Icons.arrow_forward_ios,
                size: 18, color: contentTheme.black.withOpacity(0.4)),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSetting() {
    return InkWell(
      onTap: () => Get.toNamed('/selectLanguageScreen'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Row(
          children: [
            Image.asset(Images.language,
                width: 28, height: 28, color: contentTheme.black),
            const SizedBox(width: 16),
            Expanded(
                child: MyText.titleMedium('Langue',
                    fontWeight: 600, fontSize: 16, color: contentTheme.black)),
            MyText.bodyMedium(_getCurrentLanguageName(),
                color: contentTheme.primary, fontWeight: 500),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios,
                size: 18, color: contentTheme.black.withOpacity(0.4)),
          ],
        ),
      ),
    );
  }

  Widget _buildDarkModeSetting() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        children: [
          Image.asset(Images.lightDarkMode,
              width: 28, height: 28, color: contentTheme.black),
          const SizedBox(width: 16),
          Expanded(
              child: MyText.titleMedium('Mode Sombre',
                  fontWeight: 600, fontSize: 16, color: contentTheme.black)),
          Transform.scale(
            scale: 0.8,
            child: CupertinoSwitch(
              value: LocalStorage.getTheme() == "Dark",
              activeColor: contentTheme.primary,
              onChanged: (bool val) {
                LocalStorage.setTheme(val ? "Dark" : "Light");
                Provider.of<AppNotifier>(context, listen: false).changeTheme();
              },
            ),
          ),
        ],
      ),
    );
  }

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
    int index = controller.selectedLanguageIndex.value;
    switch (index) {
      case 0:
        return "Français";
      case 1:
        return "Anglais";
      case 2:
        return "Mooré";
      case 3:
        return "Dioula";
      default:
        return "Français";
    }
  }
}
