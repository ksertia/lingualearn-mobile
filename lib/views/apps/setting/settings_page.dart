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
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:get/get_utils/src/extensions/widget_extensions.dart';
import 'package:provider/provider.dart';

class SettingScreen extends StatefulWidget {
  SettingScreen({super.key});

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
          body: GetBuilder<SettingsController>(
            builder: (_) {
              return Obx(() => controller.isLoading.value
                  ? AppLoader()
                  : Column(
                      children: [
                        Platform.isIOS ? 70.verticalSpace : 60.verticalSpace,
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: InkWell(child: _buildProfileSection()),
                        ),
                        SizedBox(height: 20.h),
                        Divider(
                          color: contentTheme.kE6E6E6,
                          thickness: 1.0,
                        ).paddingSymmetric(horizontal: 20.w),
                        Expanded(
                          child: ListView(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            children: [
                              10.verticalSpace,
                              // Divider(
                              //   color: contentTheme.kE6E6E6,
                              //   thickness: 1.0,
                              // ),
                              10.verticalSpace,
                              _buildLanguageSetting(),
                              _buildDarkModeSetting(),
                              10.verticalSpace,
                              Divider(
                                color: contentTheme.kE6E6E6,
                                thickness: 1.0,
                              ),
                              _buildSettingsItem(
                                icon: Images.logout,
                                title: 'logout'.tr(),
                                onTap: () async {
                                  final confirmed =
                                      await showModalBottomSheet<bool>(
                                    context: context,
                                    isScrollControlled: true,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(20.r)),
                                    ),
                                    builder: (_) => LogoutDeleteBottomSheet(
                                      title: 'logout'.tr(),
                                      subTitle:
                                          'are_you_sure_you_want_to_logout'
                                              .tr(),
                                    ),
                                  );

                                  if (confirmed == true) {
                                    controller.isLoading(true);
                                    await controller.onLogout();
                                  }
                                },
                              ),

                              10.verticalSpace,
                              Divider(
                                color: contentTheme.kE6E6E6,
                                thickness: 1.0,
                              ),
                              SizedBox(height: 80.h),
                            ],
                          ),
                        ),
                      ],
                    ));
            },
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Row(
      children: [
        CircleAvatar(
          radius: 35.sp,
          backgroundImage: AssetImage(Images.avatars[2]),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyText.titleMedium(
                LocalStorage.getUserName() ?? "",
                fontWeight: 600,
                fontSize: 16.sp,
                color: contentTheme.black,
              ),
              MyText.titleMedium(
                LocalStorage.getEmail() ?? "",
                fontWeight: 400,
                fontSize: 16.sp,
                color: contentTheme.black,
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
    double? iconWidth, // Optional width
    double? iconHeight,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Image.asset(
              icon,
              fit: BoxFit.fill,
              width: iconWidth ?? 32.w,
              height: iconHeight ?? 32.h,
              color: contentTheme.black,
            ),
            16.horizontalSpace,
            Expanded(
              child: MyText.titleMedium(
                title,
                fontWeight: 600,
                fontSize: 16.sp,
                color: contentTheme.black,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 24.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSetting() {
    return InkWell(
      onTap: () {
        // if (LocalStorage.getLanguage() == "en") {
        //   controller.selectLanguage(0);
        // } else {
        //   controller.selectLanguage(2);
        // }
        Get.offNamed('/selectLanguageScreen');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Image.asset(
              Images.language,
              fit: BoxFit.fill,
              width: 32.w,
              height: 32.h,
              color: contentTheme.black,
            ),
            16.horizontalSpace,
            Expanded(
              child: MyText.titleMedium(
                'language'.tr(),
                fontWeight: 600,
                fontSize: 16.sp,
                color: contentTheme.black,
              ),
            ),
            Text(LocalStorage.getLanguage() == "en"
                ? "english".tr()
                : LocalStorage.getLanguage() == "fr"
                    ? "french".tr()
                    : LocalStorage.getLanguage() == "mos"
                        ? "moore".tr()
                        : "dioula".tr()),
            Icon(
              Icons.arrow_forward_ios,
              size: 24.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDarkModeSetting() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Image.asset(
            Images.lightDarkMode,
            fit: BoxFit.fill,
            width: 32.w,
            height: 32.h,
            color: contentTheme.black,
          ),
          16.horizontalSpace,
          Expanded(
            child: MyText.titleMedium(
              'dark_mode'.tr(),
              fontWeight: 600,
              fontSize: 16.sp,
              color: contentTheme.black,
            ),
          ),
          SizedBox(
            width: 44.w,
            height: 24,
            child: Consumer<AppNotifier>(
              builder: (_, value, child) => Transform.scale(
                scale: 0.6,
                child: CupertinoSwitch(
                    onChanged: (value) async {
                      if (value) {
                        LocalStorage.setTheme("Dark");
                        Provider.of<AppNotifier>(
                                NavigationService.globalContext!,
                                listen: false)
                            .changeTheme();
                      } else {
                        LocalStorage.setTheme("Light");
                        Provider.of<AppNotifier>(
                                NavigationService.globalContext!,
                                listen: false)
                            .changeTheme();
                      }
                    },
                    value: LocalStorage.getTheme() == "Dark" ? true : false,
                    activeColor: contentTheme.primary,
                    thumbColor: contentTheme.white,
                    trackColor: contentTheme.kAFAFAF),
              ),
            ),
          ),
          // Obx(
          //   () => SizedBox(
          //     height: 24.h,
          //     child: CupertinoSwitch(
          //       onChanged: (value) async {},
          //       value: controller.isDarkMode.value,
          //       activeColor: contentTheme.onPrimary, // Use your primary color
          //       thumbColor: contentTheme
          //           .white, // Use a color that contrasts with primary
          //       trackColor:
          //           contentTheme.kCECECE, // Use a subtle background color
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
