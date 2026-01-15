import 'dart:io';
import 'package:fasolingo/controller/apps/settings/settings_controller.dart';
import 'package:fasolingo/helpers/extensions/string.dart';
import 'package:fasolingo/helpers/localizations/language.dart';
import 'package:fasolingo/helpers/my_widgets/my_spacing.dart';
import 'package:fasolingo/helpers/my_widgets/my_text.dart';
import 'package:fasolingo/helpers/storage/local_storage.dart';
import 'package:fasolingo/helpers/theme/admin_theme.dart';
import 'package:fasolingo/helpers/theme/app_notifier.dart';
import 'package:fasolingo/helpers/utils/ui_mixins.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_utils/src/extensions/widget_extensions.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

class ChangeLanguageScreen extends StatefulWidget {
  const ChangeLanguageScreen({super.key});

  @override
  State<ChangeLanguageScreen> createState() => _ChangeLanguageScreenState();
}

class _ChangeLanguageScreenState extends State<ChangeLanguageScreen>
    with SingleTickerProviderStateMixin, UIMixin {
  final controller = Get.put(SettingsController());
  final String returnRoute = Get.parameters['returnRoute']!;
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Consumer<AppNotifier>(
        builder: (_, appNotifier, child) => Scaffold(
          body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Platform.isIOS ? 70.verticalSpace : 60.verticalSpace,
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      Get.offNamed(returnRoute);
                    },
                    child: Icon(
                      LucideIcons.arrowLeft,
                      size: 24.sp,
                    ),
                  ),
                  MySpacing.width(15),
                  MyText.titleMedium(
                    "language".tr(),
                    fontWeight: 600,
                    fontSize: 24.sp,
                    color: contentTheme.black,
                  )
                ],
              ),
              60.verticalSpace,
              Expanded(
                child: Obx(
                      () => ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 15.w),
                    shrinkWrap: true,
                    itemCount: controller.languageList.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () async {
                          await controller.selectLanguage(index);
                          LocalStorage.setLanguage(Language.languages[index]);
                          appNotifier.changeLanguage(Language.languages[index]); // Pass the Locale

                        },
                        child: Row(
                          children: [
                            MyText.titleMedium(
                              controller.languageList[index], // This is already .tr() in controller
                              fontSize: 20.sp,
                              fontWeight: 500,
                              color: AdminTheme.theme.contentTheme.black,
                            ),
                            const Spacer(),
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: Obx(
                                    () => Radio<int>( // Type is int (the index)
                                  value: index, // The current item's index
                                  activeColor: contentTheme.primary,
                                  groupValue: controller.selectedLanguageIndex.value, // The selected index
                                  fillColor:
                                  MaterialStateProperty.resolveWith<Color>(
                                        (Set<MaterialState> states) {
                                      if (states.contains(MaterialState.selected)) {
                                        return contentTheme.black; // Color for the selected dot
                                      }
                                      return contentTheme.kCECECE;
                                    },
                                  ),
                                  onChanged: (int? value) async {
                                    if (value != null) {
                                      controller.selectLanguage(index);
                                      LocalStorage.setLanguage(Language.languages[index]);
                                      appNotifier.changeLanguage(Language.languages[value]); // Pass the Locale
                                    }
                                  },
                                ),
                              ),
                            )
                          ],
                        ),
                      ).paddingOnly(bottom: 15);
                    },
                    separatorBuilder: (context, index) => 3.verticalSpace,
                  ),
                ),
              )
            ],
          ).paddingSymmetric(horizontal: 20.w),
        ),
      ),
    );
  }
}