import 'dart:async';

import 'package:fasolingo/helpers/constant/images.dart';
import 'package:fasolingo/helpers/extensions/string.dart';
import 'package:fasolingo/helpers/my_widgets/my_spacing.dart';
import 'package:fasolingo/helpers/my_widgets/my_text.dart';
import 'package:fasolingo/helpers/utils/ui_mixins.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_core/get_core.dart';
import 'package:get/get_navigation/get_navigation.dart';

class SuccessPage extends StatefulWidget {
  SuccessPage({super.key});

  @override
  State<SuccessPage> createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage>with SingleTickerProviderStateMixin, UIMixin  {
  Timer? _timer;

  autoLogin() {
    _timer = Timer.periodic(
      Duration(seconds: 1),
      (timer) {
        _timer?.cancel();
        Get.offAllNamed("/auth/login");
      },
    );
  }

  @override
  void initState() {
    autoLogin();
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: MySpacing.fullWidth(context),
          margin: EdgeInsets.symmetric(horizontal: 20.w),
          height: MySpacing.fullHeight(context) * 0.40,
          decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                    offset: Offset(0, 0),
                    spreadRadius: 0,
                    blurRadius: 10,
                    color: Color(0xff69442C1A).withAlpha(10))
              ],
              color: contentTheme.kF6F6F6,
              border: Border.all(
                  color:
                  contentTheme.kE6E6E6), //
              borderRadius: BorderRadius.circular(20),
             ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(Images.success, width: 160, height: 160),
              50.verticalSpace,
              MyText.titleLarge(
                "signup_successfult".tr(),
                fontWeight: 700,
                fontSize: 24.sp,
                color: contentTheme.black,
              ),
              20.verticalSpace,
              MyText.titleLarge(
                "please_wait".tr(),
                fontWeight: 400,
                fontSize: 16.sp,
                color: contentTheme.black,
              )
            ],
          ),
        ),
      ),
    );
  }
}
