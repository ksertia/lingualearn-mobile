import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:fasolingo/controller/layouts/auth_layout_controller.dart';
import 'package:fasolingo/helpers/theme/admin_theme.dart';
import 'package:fasolingo/helpers/my_widgets/my_container.dart';
import 'package:fasolingo/helpers/my_widgets/my_flex.dart';
import 'package:fasolingo/helpers/my_widgets/my_flex_item.dart';
import 'package:fasolingo/helpers/my_widgets/my_responsive.dart';
import 'package:fasolingo/helpers/my_widgets/my_spacing.dart';

class AuthLayout extends StatelessWidget {
  final Widget? child;

  final AuthLayoutController controller = AuthLayoutController();

  AuthLayout({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return MyResponsive(builder: (BuildContext context, _, screenMT) {
      return GetBuilder(
          init: controller,
          builder: (controller) {
            return screenMT.isMobile
                ? mobileScreen(context)
                : largeScreen(context);
          });
    });
  }

  Widget mobileScreen(BuildContext context) {
    return Scaffold(
      key: controller.scaffoldKey,
      // backgroundColor: Colors.white,
      body: Container(
        padding: MySpacing.top(MySpacing.safeAreaTop(context) + 20),
        height: MediaQuery.of(context).size.height,
        // color: theme.cardTheme.color,
        child: SingleChildScrollView(
          key: controller.scrollKey,
          child: child,
        ),
      ),
    );
  }

  Widget largeScreen(BuildContext context) {
    return Scaffold(
        key: controller.scaffoldKey,
        backgroundColor: Colors.blue,
        body: Stack(
          children: [
            Container(
              margin: MySpacing.top(100),
              width: MediaQuery.of(context).size.width,
              child: MyFlex(
                wrapAlignment: WrapAlignment.center,
                wrapCrossAlignment: WrapCrossAlignment.start,
                runAlignment: WrapAlignment.center,
                spacing: 0,
                runSpacing: 0,
                children: [
                  MyFlexItem(
                    sizes: "xxl-8 lg-8 md-9 sm-10",
                    // sizes: "xxl-3 lg-4 md-6 sm-8",
                    child: MyContainer(
                      paddingAll: 0,
                      color: AdminTheme.theme.contentTheme.background
                          .withAlpha(230),
                      child: child ?? Container(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
