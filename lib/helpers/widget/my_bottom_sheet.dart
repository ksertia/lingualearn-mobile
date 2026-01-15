import 'package:fasolingo/helpers/constant/images.dart';
import 'package:fasolingo/helpers/my_widgets/my_button.dart';
import 'package:fasolingo/helpers/my_widgets/my_spacing.dart';
import 'package:fasolingo/helpers/theme/admin_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:google_fonts/google_fonts.dart';

class MyBottomSheet {
  /// Creates a bottom bar widget typically used for success messages or confirmations.
  ///
  /// It displays a success icon, a title, and a 'Close' button.
  ///
  /// [title]: The main text message to display in the bottom bar.
  /// [onPressed]: The callback function to execute when the 'Close' button is pressed.
  static Widget successPoolBottomBar(String title, Function()? onPressed) {
    return Container(
      width: Get.width,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      color: AdminTheme.theme.contentTheme.kDarkColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Divider icon at the top
          Image.asset(Images.bottomBarDividerIcon,
              width: 80, color: Colors.grey),
          // Spacer for vertical separation
          MySpacing.height(20), // Added a specific height for better spacing

          // Success icon and title
          Column(
            children: [
              Image.asset(Images.successIcon,
                  width: 50, height: 50, fit: BoxFit.fill),
              MySpacing.height(10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                    fontSize: 18.sp,
                    color: AdminTheme.theme.contentTheme.k545454,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
          // Spacer before the button
          MySpacing.height(20), // Added a specific height for better spacing

          // Close button
          MyButton.outlined(
            block: true,
            borderColor: AdminTheme.theme.contentTheme.primary,
            onPressed: onPressed,
            padding: MySpacing.xy(20, 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 5,
            child: Text(
              'Close',
              style: GoogleFonts.lato(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AdminTheme.theme.contentTheme.primary,
              ),
            ),
          )
        ],
      ),
    );
  }
}