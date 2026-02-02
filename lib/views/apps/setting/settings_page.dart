import 'dart:io';
import 'package:fasolingo/controller/apps/settings/settings_controller.dart';
import 'package:fasolingo/helpers/constant/images.dart';
import 'package:fasolingo/helpers/extensions/string.dart';
import 'package:fasolingo/helpers/my_widgets/my_text.dart';
import 'package:fasolingo/helpers/services/navigation_service.dart';
import 'package:fasolingo/helpers/storage/local_storage.dart';
import 'package:fasolingo/helpers/theme/app_notifier.dart';
import 'package:fasolingo/helpers/utils/ui_mixins.dart';
import 'package:fasolingo/views/apps/setting/widget/logout_bottom_sheet.dart';
import 'package:fasolingo/views/ui/apploader.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Consumer<AppNotifier>(
        builder: (_, value, child) => Scaffold(
          body: Obx(() {
            if (controller.isLoading.value) {
              return const AppLoader();
            }

            return Column(
              children: [
                Platform.isIOS ? 70.verticalSpace : 60.verticalSpace,
                
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: _buildProfileSection(),
                ),

                SizedBox(height: 25.h),
                Divider(
                  color: contentTheme.kE6E6E6,
                  thickness: 1.0,
                ).paddingSymmetric(horizontal: 20.w),

                // --- LISTE DES PARAMÈTRES ---
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    children: [
                      15.verticalSpace,
                      _buildLanguageSetting(),
                      _buildDarkModeSetting(),
                      
                      15.verticalSpace,
                      Divider(color: contentTheme.kE6E6E6, thickness: 1.0),
                      
                      _buildSettingsItem(
                        icon: Images.logout,
                        title: 'logout',
                        onTap: () => _handleLogout(context),
                      ),

                      15.verticalSpace,
                      Divider(color: contentTheme.kE6E6E6, thickness: 1.0),
                      
                      SizedBox(height: 30.h),
                      Center(
                        child: MyText.bodySmall(
                          "Version 1.0.0",
                          color: contentTheme.black.withOpacity(0.3),
                        ),
                      ),
                      SizedBox(height: 80.h),
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    final user = controller.user.value;

    return Row(
      children: [
        CircleAvatar(
          radius: 35.sp,
          backgroundColor: contentTheme.primary.withOpacity(0.1),
          backgroundImage: AssetImage(Images.avatars[2]),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyText.titleMedium(
                user != null ? "${user.firstName} ${user.lastName}" : "Utilisateur",
                fontWeight: 700,
                fontSize: 18.sp,
                color: contentTheme.black,
              ),
              SizedBox(height: 2.h),
              MyText.bodyMedium(
                user?.email ?? "Email non disponible",
                fontWeight: 400,
                fontSize: 14.sp,
                color: contentTheme.black.withOpacity(0.6),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsItem({
    required String icon,
    required String title,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 15.h),
        child: Row(
          children: [
            Image.asset(icon, width: 28.w, height: 28.h, color: contentTheme.black),
            16.horizontalSpace,
            Expanded(
              child: MyText.titleMedium(
                title,
                fontWeight: 600,
                fontSize: 16.sp,
                color: contentTheme.black,
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 18.sp, color: contentTheme.black.withOpacity(0.4)),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSetting() {
    return InkWell(
      onTap: () => Get.toNamed('/selectLanguageScreen'), 
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 15.h),
        child: Row(
          children: [
            Image.asset(Images.language, width: 28.w, height: 28.h, color: contentTheme.black),
            16.horizontalSpace,
            Expanded(
              child: MyText.titleMedium(
                'language',
                fontWeight: 600,
                fontSize: 16.sp,
                color: contentTheme.black,
              ),
            ),
            MyText.bodyMedium(
              _getCurrentLanguageName(),
              color: contentTheme.primary,
              fontWeight: 500,
            ),
            8.horizontalSpace,
            Icon(Icons.arrow_forward_ios, size: 18.sp, color: contentTheme.black.withOpacity(0.4)),
          ],
        ),
      ),
    );
  }

  Widget _buildDarkModeSetting() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 15.h),
      child: Row(
        children: [
          Image.asset(Images.lightDarkMode, width: 28.w, height: 28.h, color: contentTheme.black),
          16.horizontalSpace,
          Expanded(
            child: MyText.titleMedium(
              'dark_mode',
              fontWeight: 600,
              fontSize: 16.sp,
              color: contentTheme.black,
            ),
          ),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (_) => LogoutDeleteBottomSheet(
        title: 'logout',
        subTitle: 'are_you_sure_you_want_to_logout',
      ),
    );

    if (confirmed == true) {
      await controller.onLogout();
    }
  }

String _getCurrentLanguageName() {
  int index = controller.selectedLanguageIndex.value;
  
  if (index == 0) return "french";
  if (index == 1) return "english";
  if (index == 2) return "moore";
  if (index == 3) return "dioula";
  
  return "french"; 
}
}