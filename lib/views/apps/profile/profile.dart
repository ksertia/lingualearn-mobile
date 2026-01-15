import 'package:fasolingo/controller/apps/profile/profile_controller.dart';
import 'package:fasolingo/helpers/constant/images.dart';
import 'package:fasolingo/helpers/extensions/string.dart';
import 'package:fasolingo/helpers/my_widgets/my_container.dart';
import 'package:fasolingo/helpers/my_widgets/my_responsive.dart';
import 'package:fasolingo/helpers/my_widgets/my_spacing.dart';
import 'package:fasolingo/helpers/my_widgets/my_text.dart';
import 'package:fasolingo/helpers/my_widgets/my_text_style.dart';
import 'package:fasolingo/helpers/storage/local_storage.dart';
import 'package:fasolingo/helpers/theme/admin_theme.dart';
import 'package:fasolingo/helpers/theme/app_notifier.dart';
import 'package:fasolingo/helpers/utils/ui_mixins.dart';
import 'package:fasolingo/widgets/image_show.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/instance_manager.dart';
import 'package:get/route_manager.dart';
import 'package:get/state_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin, UIMixin {
  final controller = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: MyResponsive(
          builder: (BuildContext context, _, screenMT) => screenMT.isMobile
              ? Consumer<AppNotifier>(
                  builder: (_, value, child) => Scaffold(
                    // backgroundColor: contentTheme.kProfileBackground,
                    appBar: AppBar(
                      backgroundColor: LocalStorage.getTheme() == "Dark"
                          ? null
                          : Colors.white,
                      surfaceTintColor: LocalStorage.getTheme() == "Dark"
                          ? null
                          : Colors.white,
                      elevation: 0,
                      title: Padding(
                        padding: MySpacing.symmetric(horizontal: 15.w),
                        child: MyText.bodyLarge(
                          "user_profile".tr(),
                          fontSize: 20.sp,
                          fontWeight: 600,
                          color: AdminTheme.theme.contentTheme.k0A0A0A,
                        ),
                      ),
                      automaticallyImplyLeading: false,
                      leadingWidth: 50.w,
                      titleSpacing: 10,
                      toolbarHeight: 60,
                    ), // endDra
                    body: GetBuilder<ProfileController>(
                      init: controller,
                      builder: (_) {
                        return Padding(
                          padding: MySpacing.symmetric(horizontal: 20.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              10.verticalSpace,
                              controller.isLoading
                                  ? Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        MyContainer.rounded(
                                            height: 60,
                                            width: 60,
                                            paddingAll: 0,
                                            child: Obx(() => controller
                                                    .profileImageID
                                                    .value
                                                    .isNotEmpty
                                                ? GetNetworkImage(
                                                    imageID: controller
                                                        .profileImageID.value,
                                                    fit: BoxFit.fill,
                                                  )
                                                : (controller
                                                        .selectedAvatafasolingoagePath
                                                        .value
                                                        .isNotEmpty)
                                                    ? Image.asset(
                                                        controller
                                                            .selectedAvatafasolingoagePath
                                                            .value,
                                                      )
                                                    : Image.asset(
                                                        Images.avatars[1],
                                                        fit: BoxFit.cover,
                                                      ))),
                                        MySpacing.width(15.w),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              MyText.bodyMedium(
                                                  "${LocalStorage.getUserName()}",
                                                  style: MyTextStyle.bodySmall(
                                                    fontWeight: 400,
                                                    fontSize: 20.sp,
                                                    color: contentTheme.k060606,
                                                  )),
                                              MyText.bodyMedium("",
                                                  style: MyTextStyle.bodySmall(
                                                    fontWeight: 400,
                                                    fontSize: 16.sp,
                                                    color: contentTheme.k6D6D6D,
                                                  )),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                              20.verticalSpace,
                              Container(
                                decoration: BoxDecoration(
                                    color: LocalStorage.getTheme() == "Dark"
                                        ? contentTheme.kDark333333
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                          offset: Offset(0, 4),
                                          spreadRadius: -2,
                                          blurRadius: 8,
                                          color: contentTheme.black
                                              .withOpacity(0.10))
                                    ]),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 15.w, vertical: 10),
                                child: Column(
                                  children: [
                                    Divider(
                                      thickness: 1,
                                      height: 15,
                                      color: contentTheme.kB0B0B0,
                                    ),

                                    Divider(
                                      thickness: 1,
                                      height: 15,
                                      color: contentTheme.kB0B0B0,
                                    ),

                                    // Divider(
                                    //   thickness: 1,
                                    //   height: 15,
                                    //   color: contentTheme.kB0B0B0,
                                    // ),
                                    // CustomListTile(
                                    //   leading: Images.priceList,
                                    //   title: "subscription".tr(),
                                    //   subtitle: "Primary",
                                    //   trailing: Icon(Icons.keyboard_arrow_right,
                                    //       color: contentTheme.black),
                                    //   onTap: () {
                                    //     Get.offNamed("/subscription");
                                    //   },
                                    // ),
                                    Divider(
                                      thickness: 1,
                                      height: 18,
                                      color: contentTheme.kB0B0B0,
                                    ),

                                    Divider(
                                      thickness: 1,
                                      height: 15,
                                      color: contentTheme.kB0B0B0,
                                    ),

                                    Divider(
                                      thickness: 1,
                                      height: 15,
                                      color: contentTheme.kB0B0B0,
                                    ),
                                    10.verticalSpace,

                                    Divider(
                                      thickness: 1,
                                      height: 15,
                                      color: contentTheme.kB0B0B0,
                                    ),
                                    10.verticalSpace,
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    floatingActionButton: InkWell(
                      onTap: () {
                        Get.toNamed('/create_pool');
                      },
                      child: CircleAvatar(
                        backgroundColor: contentTheme.bottomBarColor,
                        radius: 30,
                        child: Icon(Icons.add,
                            color: contentTheme.background, size: 25),
                      ),
                    ),
                    floatingActionButtonLocation:
                        FloatingActionButtonLocation.centerDocked,
                  ),
                )
              : Scaffold(
                  // backgroundColor: AdminTheme.theme.contentTheme.kEFEFEF,
                  appBar: AppBar(
                    elevation: 3,
                    titleSpacing: 0,
                    backgroundColor: contentTheme.white,
                    surfaceTintColor: contentTheme.white,
                    shadowColor: contentTheme.background,
                    leading: SizedBox(),
                    centerTitle: false,
                    leadingWidth: 20,
                    toolbarHeight: 70,
                    actions: [
                      IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.close,
                              color: contentTheme.k00374A, size: 20))
                    ],
                    title: MyText.titleLarge(
                      "user_profile".tr(),
                      style: GoogleFonts.lato(
                          fontWeight: FontWeight.w400,
                          fontSize: 18,
                          color: contentTheme.k00374A),
                    ),
                  ), // endDra
                  body: GetBuilder<ProfileController>(
                    init: controller,
                    builder: (_) {
                      return Padding(
                        padding:
                            MySpacing.symmetric(horizontal: 20.w, vertical: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                MyContainer.rounded(
                                  height: 74,
                                  width: 74.w,
                                  paddingAll: 0,
                                  child: Image.asset(
                                    Images.avatars[1],
                                    height: 74,
                                    width: 74.w,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                MySpacing.width(20.w),
                                Expanded(
                                  child: MyText.bodyMedium(
                                      "${LocalStorage.getUserName()}",
                                      style: MyTextStyle.bodyMedium(
                                        fontWeight: 400,
                                        fontSize: 20,
                                        color: contentTheme.k060606,
                                      )),
                                ),
                              ],
                            ),
                            MySpacing.height(10),
                          ],
                        ),
                      );
                    },
                  ),
                )),
    );
  }
}
