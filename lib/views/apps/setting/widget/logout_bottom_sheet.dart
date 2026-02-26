import 'package:fasolingo/helpers/extensions/string.dart';
import 'package:fasolingo/helpers/my_widgets/my_button.dart';
import 'package:fasolingo/helpers/my_widgets/my_spacing.dart';
import 'package:fasolingo/helpers/utils/ui_mixins.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../helpers/my_widgets/my_text.dart';

class LogoutDeleteBottomSheet extends StatelessWidget with UIMixin {
  final String title;
  final String subTitle;

   LogoutDeleteBottomSheet({
    Key? key,
    required this.title,
    required this.subTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: contentTheme.bottomBarColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          16.verticalSpace,
          MyText.titleMedium(
            title,
            fontWeight: 700,
            fontSize: 16,
            color: contentTheme.black,
            textAlign: TextAlign.center,
          ),
          8.verticalSpace,
          MyText.titleMedium(
            subTitle,
            fontWeight: 400,
            fontSize: 14,
            color: contentTheme.black,
            textAlign: TextAlign.center,
          ),
          24.verticalSpace,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: MyButton.outlined(
                  block: true,
                  backgroundColor: contentTheme.onPrimary,
                  borderColor: contentTheme.onPrimary,
                  onPressed: () => Navigator.of(context).pop(false),
                  elevation: 1,
                  borderRadiusAll: 20,
                  padding: MySpacing.xy(20, 13),
                  child: MyText.bodyLarge(
                    'no'.tr(),
                    fontWeight: 700,
                    fontSize: 14,
                    color: contentTheme.onPrimary,
                  ),
                ),
              ),
              16.horizontalSpace,
              Expanded(
                child: MyButton.rounded(
                  onPressed: () => Navigator.of(context).pop(true),
                  block: true,
                  elevation: 2,
                  borderRadiusAll: 20,
                  padding: MySpacing.xy(20, 20),
                  backgroundColor: contentTheme.primary,
                  child: MyText.bodyLarge(
                    'yes'.tr(),
                    fontWeight: 700,
                    fontSize: 14,
                    color: contentTheme.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      )
    );
  }
}
