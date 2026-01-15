import 'dart:io';
import 'package:fasolingo/helpers/extensions/string.dart';
import 'package:fasolingo/helpers/my_widgets/my_spacing.dart';
import 'package:fasolingo/helpers/my_widgets/my_text.dart';
import 'package:fasolingo/helpers/utils/ui_mixins.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_utils/src/extensions/widget_extensions.dart';
import 'package:lucide_icons/lucide_icons.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen>
    with SingleTickerProviderStateMixin, UIMixin {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
          body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Platform.isIOS ? 70.verticalSpace : 40.verticalSpace,
          Row(
            children: [
              InkWell(
                onTap: () {
                  Get.offNamed("/settingScreen");
                },
                child: Icon(
                  LucideIcons.arrowLeft,
                  size: 24.sp,
                ),
              ),
              MySpacing.width(15),
              MyText.titleMedium(
                "privacy_policy".tr(),
                fontWeight: 600,
                fontSize: 24.sp,
                color: contentTheme.black,
              )
            ],
          ),
          40.verticalSpace,
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText.titleMedium(
                    "alioth_mobility_respects_your_privacy_and_is_committed".tr(),
                    fontWeight: 400,
                    fontSize: 16.sp,
                    color: contentTheme.black,
                  ),
                  20.verticalSpace,
                  MyText.titleMedium(
                    "information_we_collect".tr(),
                    fontWeight: 700,
                    fontSize: 20.sp,
                    color: contentTheme.black,
                  ),
                  8.verticalSpace,
                  _buildBulletPoint(
                      'personal_info_name_phone_number_email_country'.tr()),
                  _buildBulletPoint('device_info_mobile_model_version'.tr()),
                  _buildBulletPoint(
                      'usage_data_charging_sessions_station_searches'.tr()),
                  _buildBulletPoint(
                      'payment_data_mobile_money_numbers_and_transaction_logs'
                          .tr()),
                  20.verticalSpace,
                  MyText.titleMedium(
                    "how_we_use_your_information".tr(),
                    fontWeight: 700,
                    fontSize: 20.sp,
                    color: contentTheme.black,
                  ),
                  8.verticalSpace,
                  _buildBulletPoint('to_create_and_manage_your_account'.tr()),
                  _buildBulletPoint(
                      'to_process_charging_sessions_and_payments'.tr()),
                  _buildBulletPoint(
                      'to_provide_customer_support_and_notify'.tr()),
                  _buildBulletPoint(
                      'to_improve_app_functionality_and_user_experience'.tr()),
                  20.verticalSpace,
                  MyText.titleMedium(
                    "sharing_and_security".tr(),
                    fontWeight: 700,
                    fontSize: 20.sp,
                    color: contentTheme.black,
                  ),
                  8.verticalSpace,
                  _buildBulletPoint('we_do_not_sell_your_data'.tr()),
                  _buildBulletPoint(
                      'data_may_be_shared_with_partners_like_mobile_money'.tr()),
                  _buildBulletPoint(
                      'all_data_is_encrypted_and_stored_securely'.tr()),
                  20.verticalSpace,
                  MyText.titleMedium(
                    "your_rights".tr(),
                    fontWeight: 700,
                    fontSize: 20.sp,
                    color: contentTheme.black,
                  ),
                  8.verticalSpace,
                  _buildBulletPoint(
                      'you_can_access_update_or_delete_your_data_at'.tr()),
                  _buildBulletPoint(
                      'you_can_opt_out_of_optional_communications_in_settings'
                          .tr()),
                  20.verticalSpace,
                  MyText.titleMedium(
                    "contact".tr(),
                    fontWeight: 700,
                    fontSize: 20.sp,
                    color: contentTheme.black,
                  ),
                  8.verticalSpace,
                  _buildBulletPoint(
                      'for_any_questions_or_requests_about_your_data'.tr()),
                  4.verticalSpace,
                  Row(
                    children: [
                      20.horizontalSpace,
                      const Icon(Icons.email_outlined,
                          size: 16, color: Colors.grey),
                      8.horizontalSpace,
                      MyText.titleMedium(
                        "contact@aliothmobility.com",
                        fontWeight: 400,
                        fontSize: 16.sp,
                        color: contentTheme.black,
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h), // Add some bottom padding if needed
                ],
              ),
            ),
          ),
        ],
      ).paddingSymmetric(horizontal: 20.w)),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText.titleMedium(
            '  •  ',
            fontWeight: 700,
            fontSize: 16.sp,
            color: contentTheme.black,
          ),
          Expanded(
            child: MyText.titleMedium(
              text,
              fontWeight: 400,
              fontSize: 16.sp,
              color: contentTheme.black,
            ),
          ),
        ],
      ),
    );
  }
}
