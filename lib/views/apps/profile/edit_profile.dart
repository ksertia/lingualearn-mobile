import 'dart:io';
import 'package:fasolingo/controller/apps/profile/profile_controller.dart';
import 'package:fasolingo/helpers/constant/app_constant.dart';
import 'package:fasolingo/helpers/extensions/string.dart';
import 'package:fasolingo/helpers/theme/admin_theme.dart';
import 'package:fasolingo/helpers/utils/ui_mixins.dart';
import 'package:fasolingo/helpers/utils/utils.dart';
import 'package:fasolingo/helpers/my_widgets/my_container.dart';
import 'package:fasolingo/helpers/my_widgets/my_responsive.dart';
import 'package:fasolingo/helpers/my_widgets/my_spacing.dart';
import 'package:fasolingo/helpers/my_widgets/my_text.dart';
import 'package:fasolingo/helpers/my_widgets/my_text_style.dart';
import 'package:fasolingo/helpers/constant/images.dart';
import 'package:fasolingo/views/apps/profile/select_avatar.dart';
import 'package:fasolingo/widgets/custom_textfield.dart';
import 'package:fasolingo/widgets/image_show.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/route_manager.dart';
import 'package:get/state_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../ui/apploader.dart';

class ProfileDetails extends StatefulWidget {
  const ProfileDetails({super.key});

  @override
  ProfileDetailsState createState() => ProfileDetailsState();
}

class ProfileDetailsState extends State<ProfileDetails>
    with SingleTickerProviderStateMixin, UIMixin {
  late ProfileController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ProfileController());
    controller.getData();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        Get.offNamed(
          "/profile",
        );
      },
      child: MyResponsive(
          builder: (BuildContext context, _, screenMT) => screenMT.isMobile
              ? Scaffold(
                  resizeToAvoidBottomInset: false,

                  appBar: AppBar(
                    backgroundColor:
                        AdminTheme.theme.contentTheme.kPoolBackground,
                    surfaceTintColor:
                        AdminTheme.theme.contentTheme.kPoolBackground,
                    elevation: 0,
                    title: MyText.titleMedium(
                      "profile_details".tr(),
                      fontSize: 20.sp,
                      fontWeight: 600,
                      color: AdminTheme.theme.contentTheme.black,
                    ),
                    leading: InkWell(
                      onTap: () {
                        Get.offNamed(
                          "/profile",
                        );
                      },
                      child: Padding(
                        padding: MySpacing.only(left: 20.w),
                        child: Icon(
                          Icons.arrow_back,
                          size: 24.sp,
                          color: contentTheme.black,
                        ),
                      ),
                    ),
                    leadingWidth: 50.w,
                    titleSpacing: 16,
                    toolbarHeight: 70,
                  ), // endDra
                  body: GetBuilder<ProfileController>(
                    init: controller,
                    builder: (_) {
                      return Padding(
                        padding: MySpacing.symmetric(horizontal: 20.w),
                        child: controller.isLoading
                            ? SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.73,
                                child: AppLoader())
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      MyContainer.rounded(
                                          height: 74,
                                          width: 74.w,
                                          paddingAll: 0,
                                          child: Obx(() => (controller
                                                  .profileFiles.isNotEmpty)
                                              ? Image.file(File(controller
                                                      .profileFiles
                                                      .first
                                                      .path ??
                                                  ""))
                                              : controller.profileImageID.value
                                                      .isNotEmpty
                                                  ? GetNetworkImage(
                                                      imageID: controller
                                                          .profileImageID.value,
                                                      height: 74,
                                                      width: 74.w,
                                                    )
                                                  : (controller
                                                          .selectedAvatafasolingoagePath
                                                          .value
                                                          .isNotEmpty)
                                                      ? Image.asset(
                                                          controller
                                                              .selectedAvatafasolingoagePath
                                                              .value,
                                                          height: 74,
                                                          width: 74.w,
                                                        )
                                                      : Image.asset(
                                                          Images.avatars[1],
                                                          height: 74,
                                                          width: 74.w,
                                                          fit: BoxFit.cover,
                                                        ))),
                                      MySpacing.width(11.w),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              showModalBottomSheet(
                                                  shape: RoundedRectangleBorder(
                                                    // <-- SEE HERE
                                                    borderRadius:
                                                        BorderRadius.vertical(
                                                      top:
                                                          Radius.circular(46.r),
                                                    ),
                                                  ),
                                                  context: context,
                                                  isScrollControlled: true,
                                                  builder: (context) {
                                                    return Padding(
                                                      padding: MySpacing.only(
                                                          bottom: MediaQuery.of(
                                                                  context)
                                                              .viewInsets
                                                              .bottom),
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.vertical(
                                                                top: Radius
                                                                    .circular(
                                                                        46.r)),
                                                        child: MyContainer(
                                                          // height: double.infinity/2,
                                                          paddingAll: 0,
                                                          padding:
                                                              MySpacing.only(
                                                                  left: 24.w,
                                                                  right: 24.w,
                                                                  top: 16.0,
                                                                  bottom: 16),
                                                          color: contentTheme
                                                              .white,
                                                          width: Get.width,
                                                          // height:Get.height,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              MySpacing.height(
                                                                  24),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  MyText.titleSmall(
                                                                      "profile_photo"
                                                                          .tr(),
                                                                      style: GoogleFonts
                                                                          .poppins(
                                                                        fontSize:
                                                                            18.sp,
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                        color: contentTheme
                                                                            .k1E1E1E,
                                                                      )),
                                                                ],
                                                              ),
                                                              MySpacing.height(
                                                                  16),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  InkWell(
                                                                    onTap:
                                                                        () async {
                                                                      Get.back();
                                                                      List<PlatformFile>?
                                                                          file =
                                                                          await controller
                                                                              .pickFile();
                                                                      if (file !=
                                                                          null) {
                                                                        controller.profileFiles =
                                                                            file;
                                                                        controller
                                                                            .update();
                                                                      }
                                                                    },
                                                                    child:
                                                                        Column(
                                                                      children: [
                                                                        MyContainer
                                                                            .roundBordered(
                                                                          color:
                                                                              contentTheme.white,
                                                                          height:
                                                                              66,
                                                                          width:
                                                                              66.w,
                                                                          paddingAll:
                                                                              0,
                                                                          borderRadiusAll:
                                                                              1.r,
                                                                          padding:
                                                                              MySpacing.all(
                                                                            20.w,
                                                                          ),
                                                                          borderColor:
                                                                              contentTheme.kE6E6E6,
                                                                        ),
                                                                        MySpacing.height(
                                                                            10),
                                                                        MyText.titleSmall(
                                                                            "gallery"
                                                                                .tr(),
                                                                            style:
                                                                                GoogleFonts.poppins(
                                                                              fontSize: 12.sp,
                                                                              fontWeight: FontWeight.w500,
                                                                              color: contentTheme.k0090C0,
                                                                            )),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  InkWell(
                                                                    onTap: () {
                                                                      // showDialog(
                                                                      //     context:
                                                                      //         context,
                                                                      //     builder: (context) =>
                                                                      //         AlertDialog(
                                                                      //           content: SelectAvatar(controller: controller),
                                                                      //         ));
                                                                      Get.off(() =>
                                                                          SelectAvatar(
                                                                              controller: controller));
                                                                    },
                                                                    child:
                                                                        Column(
                                                                      children: [
                                                                        MyContainer
                                                                            .roundBordered(
                                                                          color:
                                                                              contentTheme.white,
                                                                          height:
                                                                              66,
                                                                          width:
                                                                              66.w,
                                                                          paddingAll:
                                                                              0,
                                                                          borderRadiusAll:
                                                                              1.r,
                                                                          padding:
                                                                              MySpacing.all(
                                                                            20.w,
                                                                          ),
                                                                          borderColor:
                                                                              contentTheme.kE6E6E6,
                                                                        ),
                                                                        MySpacing.height(
                                                                            10),
                                                                        MyText.titleSmall(
                                                                            "avatar"
                                                                                .tr(),
                                                                            style:
                                                                                GoogleFonts.poppins(
                                                                              fontSize: 12.sp,
                                                                              fontWeight: FontWeight.w500,
                                                                              color: contentTheme.k0090C0,
                                                                            )),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  InkWell(
                                                                    onTap: () {
                                                                      Get.back();
                                                                      showModalBottomSheet(
                                                                          shape:
                                                                              RoundedRectangleBorder(
                                                                            // <-- SEE HERE
                                                                            borderRadius:
                                                                                BorderRadius.vertical(
                                                                              top: Radius.circular(46.r),
                                                                            ),
                                                                          ),
                                                                          context:
                                                                              context,
                                                                          isScrollControlled:
                                                                              true,
                                                                          builder:
                                                                              (context) {
                                                                            return Padding(
                                                                              padding: MySpacing.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                                                                              child: ClipRRect(
                                                                                borderRadius: BorderRadius.vertical(top: Radius.circular(46.r)),
                                                                                child: MyContainer(
                                                                                  // height: double.infinity/2,
                                                                                  padding: MySpacing.only(left: 24.w, right: 24.w, top: 16.0, bottom: 16),
                                                                                  paddingAll: 0,
                                                                                  color: contentTheme.white,
                                                                                  width: Get.width,
                                                                                  // height:Get.height,
                                                                                  child: Column(
                                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                                    mainAxisSize: MainAxisSize.min,
                                                                                    children: [
                                                                                      MySpacing.height(24),
                                                                                      Row(
                                                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                        children: [
                                                                                          MyText.titleSmall("choose_color".tr(),
                                                                                              style: GoogleFonts.poppins(
                                                                                                fontSize: 18.sp,
                                                                                                fontWeight: FontWeight.w600,
                                                                                                color: contentTheme.k1E1E1E,
                                                                                              )),
                                                                                        ],
                                                                                      ),
                                                                                      MySpacing.height(28),
                                                                                      MySpacing.height(46),
                                                                                      InkWell(
                                                                                        onTap: () {
                                                                                          Get.back();
                                                                                        },
                                                                                        child: MyContainer.bordered(
                                                                                          width: double.infinity,
                                                                                          borderRadiusAll: 8.r,
                                                                                          height: 52,
                                                                                          color: contentTheme.white,
                                                                                          borderColor: contentTheme.k0090C0,
                                                                                          child: Center(
                                                                                            child: MyText.titleSmall(
                                                                                              "close".tr(),
                                                                                              style: GoogleFonts.lato(
                                                                                                fontSize: 16.sp,
                                                                                                fontWeight: FontWeight.w500,
                                                                                                color: contentTheme.k0090C0,
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            );
                                                                          });
                                                                    },
                                                                    child:
                                                                        Column(
                                                                      children: [
                                                                        MyContainer
                                                                            .roundBordered(
                                                                          color:
                                                                              contentTheme.white,
                                                                          height:
                                                                              66,
                                                                          width:
                                                                              66.w,
                                                                          paddingAll:
                                                                              0,
                                                                          borderRadiusAll:
                                                                              1.r,
                                                                          padding:
                                                                              MySpacing.all(
                                                                            20.w,
                                                                          ),
                                                                          borderColor:
                                                                              contentTheme.kE6E6E6,
                                                                        ),
                                                                        MySpacing.height(
                                                                            10),
                                                                        MyText.titleSmall(
                                                                            "color"
                                                                                .tr(),
                                                                            style:
                                                                                GoogleFonts.poppins(
                                                                              fontSize: 12.sp,
                                                                              fontWeight: FontWeight.w500,
                                                                              color: contentTheme.k0090C0,
                                                                            )),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              MySpacing.height(
                                                                  24),
                                                              InkWell(
                                                                onTap: () {
                                                                  Get.back();
                                                                },
                                                                child: MyContainer
                                                                    .bordered(
                                                                  width: double
                                                                      .infinity,
                                                                  borderRadiusAll:
                                                                      8.r,
                                                                  height: 52,
                                                                  color:
                                                                      contentTheme
                                                                          .white,
                                                                  borderColor:
                                                                      contentTheme
                                                                          .k0090C0,
                                                                  child: Center(
                                                                    child: MyText
                                                                        .titleSmall(
                                                                      "close"
                                                                          .tr(),
                                                                      style: GoogleFonts
                                                                          .lato(
                                                                        fontSize:
                                                                            16.sp,
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                        color: contentTheme
                                                                            .k0090C0,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  });
                                            },
                                            child: Row(
                                              children: [
                                                MyText.bodyMedium("edit".tr(),
                                                    style:
                                                        MyTextStyle.bodySmall(
                                                      fontWeight: 400,
                                                      fontSize: 14.sp,
                                                      color:
                                                          contentTheme.k8A8A8A,
                                                    )),
                                                MySpacing.width(5.w),
                                              ],
                                            ),
                                          ),
                                          5.verticalSpace,
                                          Row(
                                            children: [
                                              Obx(() => Checkbox(
                                                    onChanged: (value) {
                                                      controller.isProfilePublic
                                                              .value =
                                                          !controller
                                                              .isProfilePublic
                                                              .value;
                                                    },
                                                    value: controller
                                                        .isProfilePublic.value,
                                                    checkColor:
                                                        contentTheme.background,
                                                    activeColor:
                                                        contentTheme.primary,
                                                    side: BorderSide(
                                                        color: contentTheme
                                                            .k8A8A8A),
                                                    fillColor:
                                                        WidgetStateProperty
                                                            .resolveWith<
                                                                Color>((Set<
                                                                    WidgetState>
                                                                states) {
                                                      if (states.contains(
                                                          WidgetState
                                                              .disabled)) {
                                                        return contentTheme
                                                            .background;
                                                      } else if (states
                                                          .contains(WidgetState
                                                              .selected)) {
                                                        return contentTheme
                                                            .primary;
                                                      }
                                                      return contentTheme
                                                          .background;
                                                    }),
                                                    focusColor:
                                                        contentTheme.background,
                                                    materialTapTargetSize:
                                                        MaterialTapTargetSize
                                                            .shrinkWrap,
                                                    visualDensity:
                                                        getCompactDensity,
                                                  )),
                                              MySpacing.width(5),
                                              MyText.bodyMedium(
                                                "make_profile_public".tr(),
                                                fontSize: 14.sp,
                                                fontWeight: 400,
                                                color: contentTheme.k060606,
                                              ),
                                            ],
                                          ),
                                          2.verticalSpace,
                                          MyText.bodyMedium(
                                              "clicking_here_public".tr(),
                                              style: MyTextStyle.bodySmall(
                                                fontWeight: 400,
                                                fontSize: 12.sp,
                                                color: contentTheme.k8A8A8A,
                                              )),
                                        ],
                                      ),
                                      MySpacing.height(20),
                                    ],
                                  ),
                                  MySpacing.height(20),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            MyText.bodyMedium(
                                              "country".tr(),
                                              fontWeight: 400,
                                              fontSize: kIsWeb ? 15 : 15.sp,
                                              color: AdminTheme
                                                  .theme.contentTheme.black,
                                            ),
                                            MySpacing.height(8),
                                            DropdownButtonFormField(
                                              value: controller.selectedCountry
                                                      .value.isNotEmpty
                                                  ? controller
                                                      .selectedCountry.value
                                                  : null,
                                              dropdownColor: Colors.transparent,
                                              validator: (value) {
                                                if (value == null) {
                                                  return "please_select_country"
                                                      .tr();
                                                }
                                                return null;
                                              },
                                              menuMaxHeight:
                                                  MySpacing.fullHeight(
                                                          context) *
                                                      0.30,
                                              items: (controller
                                                          .enumerationsModel()
                                                          .data
                                                          ?.enumerations
                                                          ?.country ??
                                                      [])
                                                  .map((country) =>
                                                      DropdownMenuItem(
                                                          value: country.uuid ??
                                                              "",
                                                          onTap: () {
                                                            controller
                                                                .selectedCountryModel(
                                                                    country);
                                                          },
                                                          child: Row(
                                                            children: [
                                                              GetNetworkImage(
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  imageID: country
                                                                          .additionalInfos
                                                                          ?.flag ??
                                                                      "",
                                                                  width: 25,
                                                                  height: 20),
                                                              10.horizontalSpace,
                                                              Expanded(
                                                                child: MyText
                                                                    .labelMedium(
                                                                  country.additionalInfos
                                                                          ?.alpha3Code ??
                                                                      "",
                                                                  color:
                                                                      contentTheme
                                                                          .black,
                                                                  fontSize:
                                                                      14.sp,
                                                                ),
                                                              ),
                                                              MyText
                                                                  .labelMedium(
                                                                "+${country.additionalInfos?.callingCodes?.first ?? ""}",
                                                                fontSize: 14.sp,
                                                                color:
                                                                    contentTheme
                                                                        .black,
                                                                fontWeight: 400,
                                                              ),
                                                            ],
                                                          )))
                                                  .toList(),
                                              icon: Icon(
                                                LucideIcons.chevronDown,
                                                size: 20,
                                                color: contentTheme.black,
                                              ),
                                              isExpanded: true,
                                              decoration: Utils
                                                  .dropdownDecoration
                                                  .copyWith(
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                  color: contentTheme.primary,
                                                )),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                  color: contentTheme.primary,
                                                )),
                                                border: OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                  color: contentTheme.primary,
                                                )),
                                                filled: true,
                                                fillColor: contentTheme.kF6F6F6,
                                                contentPadding: EdgeInsets.only(
                                                    bottom: kIsWeb ? 15 : 15.h,
                                                    top: kIsWeb ? 15 : 15.h,
                                                    left: 15.w,
                                                    right: 10.w),
                                              ),
                                              onChanged: null,
                                            ),
                                          ],
                                        ),
                                      ),
                                      MySpacing.width(15.w),
                                      Expanded(
                                        child: TextInputFields(
                                          filled: true,
                                          readOnly: true,
                                          borderColor: contentTheme.primary,
                                          fillColor: contentTheme.white,
                                          contentPadding: EdgeInsets.only(
                                              bottom: kIsWeb ? 15 : 15.h,
                                              top: kIsWeb ? 15 : 15.h,
                                              left: 15.w,
                                              right: 10.w),
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                            LengthLimitingTextInputFormatter(
                                                12),
                                          ],
                                          keyboardType: TextInputType.phone,
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return "please_enter_phone_number"
                                                  .tr();
                                            } else if (value.length < 6) {
                                              return "please_enter_valid_phone_number"
                                                  .tr();
                                            }
                                            return null;
                                          },
                                          controller: controller.phoneNumber,
                                          name: "phone_number".tr(),
                                          hintText: "enter_number".tr(),
                                        ),
                                      )
                                    ],
                                  ),

                                  // TextInputFields(
                                  //   filled: true,
                                  //   name: "Country",
                                  //   hintText: "Please select a country",
                                  //   fillColor: contentTheme.white,
                                  //   validator: (value) {
                                  //     if (value!.isEmpty) {
                                  //       return "Please select a country";
                                  //     }
                                  //     return null;
                                  //   },
                                  //   controller: controller.countryCode,
                                  //   onTap: () {
                                  //     showCountryPicker(
                                  //       context: context,
                                  //       showPhoneCode: true,
                                  //       // optional. Shows phone code before the country name.
                                  //       onSelect: (Country data) {
                                  //         setState(() {
                                  //           // controller.countryCode=data.displayName as TextEditingController;
                                  //         });
                                  //       },
                                  //     );
                                  //   },
                                  // ),
                                  // MySpacing.height(15),
                                  // TextInputFields(
                                  //   inputFormatters: [
                                  //     FilteringTextInputFormatter
                                  //         .digitsOnly,
                                  //     LengthLimitingTextInputFormatter(12),
                                  //   ],
                                  //   keyboardType: TextInputType.phone,
                                  //   validator: (value) {
                                  //     if (value!.isEmpty) {
                                  //       return "Please enter phone number";
                                  //     }
                                  //     return null;
                                  //   },
                                  //   controller: controller.phoneNumber,
                                  //   filled: true,
                                  //   borderColor: contentTheme.primary,
                                  //   fillColor: contentTheme.white,
                                  //   name: "Phone Number",
                                  //   hintText: "Please enter phone number",
                                  // ),
                                  MySpacing.height(15),
                                  Row(
                                    children: [
                                      Expanded(
                                          child: TextInputFields(
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                              RegExp("[a-zA-Z]")),
                                        ],
                                        filled: true,
                                        name: "first_name".tr(),
                                        fillColor: contentTheme.white,
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return "please_enter_name".tr();
                                          }
                                          return null;
                                        },
                                        controller: controller.firstName,
                                        borderColor: contentTheme.primary,
                                        hintText: "enter_f_name".tr(),
                                      )),
                                      MySpacing.width(20.w),
                                      Expanded(
                                          child: TextInputFields(
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                              RegExp("[a-zA-Z]")),
                                        ],
                                        filled: true,
                                        borderColor: contentTheme.primary,
                                        fillColor: contentTheme.white,
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return "please_enter_name".tr();
                                          }
                                          return null;
                                        },
                                        controller: controller.lastName,
                                        onChanged: (val) {
                                          setState(() {
                                            controller.lastName.text = val;
                                          });
                                        },
                                        name: "last_name".tr(),
                                        hintText: "Please enter number",
                                      )),
                                    ],
                                  ),
                                  // MySpacing.height(15),
                                  // MyText.bodyMedium("Gender",
                                  //     style: MyTextStyle.bodySmall(
                                  //       fontWeight: 400,
                                  //       fontSize: 14.sp,
                                  //       color: contentTheme.k060606,
                                  //     )),
                                  // MySpacing.height(10),
                                  // DropdownButtonFormField(
                                  //   value: controller
                                  //           .selectedGender.value.isNotEmpty
                                  //       ? controller.selectedGender.value
                                  //       : null,
                                  //   dropdownColor: contentTheme.background,
                                  //   iconEnabledColor: contentTheme.k060606,
                                  //   iconDisabledColor: contentTheme.k060606,
                                  //   menuMaxHeight: 200,
                                  //   validator: (value) {
                                  //     if (value == null) {
                                  //       return "Please select gender";
                                  //     }
                                  //     return null;
                                  //   },
                                  //   items: (controller
                                  //               .enumerationsModel
                                  //               ?.data
                                  //               ?.enumerations
                                  //               ?.gender ??
                                  //           [])
                                  //       .map((gender) => DropdownMenuItem(
                                  //           value: gender.value,
                                  //           child: MyText.labelMedium(
                                  //               gender.label ?? "",
                                  //               fontSize: 16.sp,
                                  //               fontWeight: 400,
                                  //               color:
                                  //                   contentTheme.k00243F)))
                                  //       .toList(),
                                  //   icon: const Icon(
                                  //     LucideIcons.chevronDown,
                                  //     size: 20,
                                  //   ),
                                  //   decoration: Utils.dropdownDecoration
                                  //       .copyWith(
                                  //           filled: true,
                                  //           fillColor: contentTheme.white,
                                  //           border: OutlineInputBorder(
                                  //               borderSide: BorderSide(
                                  //             color: contentTheme.primary,
                                  //           )),
                                  //           focusedBorder:
                                  //               OutlineInputBorder(
                                  //                   borderSide: BorderSide(
                                  //             color: contentTheme.primary,
                                  //           )),
                                  //           enabledBorder:
                                  //               OutlineInputBorder(
                                  //                   borderSide: BorderSide(
                                  //             color: contentTheme.primary,
                                  //           ))),
                                  //   onChanged: (value) {
                                  //     controller.selectedGender(value);
                                  //   },
                                  // ),
                                  // MySpacing.height(15),
                                  // TextInputFields(
                                  //   borderColor: contentTheme.primary,
                                  //   filled: true,
                                  //   readOnly: true,
                                  //   fillColor: contentTheme.white,
                                  //   name: "Email",
                                  //   validator: (value) {
                                  //     if (value!.isEmpty) {
                                  //       return "Please enter email";
                                  //     }
                                  //     return null;
                                  //   },
                                  //   controller: controller.email,
                                  //   hintText: "Please enter number",
                                  // ),
                                  // MySpacing.height(15),
                                  // TextInputFields(
                                  //   filled: true,
                                  //   maxLine: 4,
                                  //   fillColor: contentTheme.white,
                                  //   borderColor: contentTheme.primary,
                                  //   name: "Address",
                                  //   validator: (value) {
                                  //     if (value!.isEmpty) {
                                  //       return "Please enter address";
                                  //     }
                                  //     return null;
                                  //   },
                                  //   controller: controller.address,
                                  //   hintText: "Please enter address",
                                  // ),
                                  MySpacing.height(15),
                                  TextInputFields(
                                    filled: true,
                                    borderColor: contentTheme.primary,
                                    fillColor: contentTheme.white,
                                    readOnly: true,
                                    name: "date_of_birth".tr(),
                                    controller:
                                        controller.dateOfBirth.text.isNotEmpty
                                            ? controller.dateOfBirth
                                            : null,
                                    suffixIconConstraints: BoxConstraints(
                                        maxHeight: 16, maxWidth: 35.w),
                                    suffixWidget: Padding(
                                      padding: MySpacing.only(right: 20.w),
                                      child: InkWell(
                                        onTap: () async {
                                          DateTime? selectedDate =
                                              await showDatePicker(
                                                  context: context,
                                                  firstDate: DateTime(1900),
                                                  lastDate: DateTime.now());
                                          if (selectedDate != null) {
                                            controller.dateOfBirth.text =
                                                DateFormat(AppConstant.yyyyMMdd)
                                                    .format(
                                                        selectedDate.toLocal());
                                          }
                                        },
                                      ),
                                    ),
                                    hintText:
                                        "please_select_date_of_birth".tr(),
                                  ),
                                  // MySpacing.height(15),
                                  // MyText.bodyMedium("Identity Proof",
                                  //     style: MyTextStyle.bodySmall(
                                  //       fontWeight: 400,
                                  //       fontSize: 14.sp,
                                  //       color: contentTheme.k060606,
                                  //     )),
                                  // MySpacing.height(10),
                                  // DropdownButtonFormField(
                                  //   validator: (value) {
                                  //     if (value == null) {
                                  //       return "Please select identify proof";
                                  //     }
                                  //     return null;
                                  //   },
                                  //   value: controller.selectedIdentityProof
                                  //           .value.isNotEmpty
                                  //       ? controller
                                  //           .selectedIdentityProof.value
                                  //       : null,
                                  //   dropdownColor: AdminTheme
                                  //       .theme.contentTheme.background,
                                  //   menuMaxHeight:
                                  //       MySpacing.fullHeight(context) *
                                  //           0.80,
                                  //   items: (controller
                                  //               .enumerationsModel
                                  //               ?.data
                                  //               ?.enumerations
                                  //               ?.identityProofKind ??
                                  //           [])
                                  //       .map((idProof) => DropdownMenuItem(
                                  //             value: idProof.value,
                                  //             child: MyText.labelMedium(
                                  //               idProof.label ?? "",
                                  //               fontSize: 16.sp,
                                  //               color: contentTheme.k00243F,
                                  //               fontWeight: 400,
                                  //             ),
                                  //           ))
                                  //       .toList(),
                                  //   icon: const Icon(
                                  //     LucideIcons.chevronDown,
                                  //     size: 20,
                                  //   ),
                                  //   isExpanded: true,
                                  //   decoration: Utils.dropdownDecoration
                                  //       .copyWith(
                                  //           filled: true,
                                  //           fillColor: contentTheme.white,
                                  //           border: OutlineInputBorder(
                                  //               borderSide: BorderSide(
                                  //             color: contentTheme.primary,
                                  //           )),
                                  //           focusedBorder:
                                  //               OutlineInputBorder(
                                  //                   borderSide: BorderSide(
                                  //             color: contentTheme.primary,
                                  //           )),
                                  //           enabledBorder:
                                  //               OutlineInputBorder(
                                  //                   borderSide: BorderSide(
                                  //             color: contentTheme.primary,
                                  //           ))),
                                  //   onChanged: (value) {
                                  //     controller
                                  //         .selectedIdentityProof(value);
                                  //   },
                                  // ),
                                  // MySpacing.height(15),
                                  // TextInputFields(
                                  //   filled: true,
                                  //   name: "Identity Number",
                                  //   borderColor: contentTheme.primary,
                                  //   fillColor: contentTheme.white,
                                  //   validator: (value) {
                                  //     if (value!.isEmpty) {
                                  //       return "Please enter identity number";
                                  //     }
                                  //     return null;
                                  //   },
                                  //   controller: controller.identityNumber,
                                  //   hintText:
                                  //       "Please enter identity number",
                                  // ),
                                  Spacer(),
                                  (controller.files?.isNotEmpty ?? false)
                                      ? MyContainer.bordered(
                                          borderColor: contentTheme.white,
                                          width: MySpacing.fullWidth(context),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          color: contentTheme.white,
                                          height: 84,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  (controller.files
                                                              ?.isNotEmpty ??
                                                          false)
                                                      ? MyContainer.rounded(
                                                          width: 46.w,
                                                          height: 48,
                                                          borderRadiusAll: 4.r,
                                                          paddingAll: 0,
                                                          shape: BoxShape
                                                              .rectangle,
                                                          child: Image.file(
                                                              File(controller
                                                                      .files
                                                                      ?.first
                                                                      .path ??
                                                                  ""),
                                                              fit: BoxFit.cover,
                                                              width: 46.w,
                                                              height: 48),
                                                        )
                                                      : SizedBox(),
                                                  MySpacing.width(10.w),
                                                  (controller.files
                                                              ?.isNotEmpty ??
                                                          false)
                                                      ? SizedBox(
                                                          width: MySpacing
                                                                  .fullWidth(
                                                                      context) /
                                                              1.8,
                                                          child: MyText
                                                              .labelMedium(
                                                            controller
                                                                    .files
                                                                    ?.first
                                                                    .name ??
                                                                "",
                                                            fontSize: 16.sp,
                                                            color: contentTheme
                                                                .k00243F,
                                                            fontWeight: 400,
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .clip,
                                                            softWrap: false,
                                                          ),
                                                        )
                                                      : SizedBox(
                                                          width: MySpacing
                                                                  .fullWidth(
                                                                      context) /
                                                              1.8,
                                                          child: MyText
                                                              .labelMedium(
                                                            controller
                                                                .attachedFileName
                                                                .value,
                                                            fontSize: 16.sp,
                                                            color: contentTheme
                                                                .k00243F,
                                                            fontWeight: 400,
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .clip,
                                                            softWrap: false,
                                                          ),
                                                        ),
                                                ],
                                              ),
                                              Spacer(),
                                              (controller.files?.isNotEmpty ??
                                                      false)
                                                  ? InkWell(
                                                      onTap: () async {
                                                        controller.files =
                                                            await controller
                                                                .pickFile();
                                                        controller.update();
                                                        Get.back();
                                                      },
                                                      child: CircleAvatar(
                                                        radius: 18,
                                                        backgroundColor:
                                                            AdminTheme
                                                                .theme
                                                                .contentTheme
                                                                .kF0F0F0,
                                                      ),
                                                    )
                                                  : InkWell(
                                                      onTap: () async {
                                                        controller.files =
                                                            await controller
                                                                .pickFile();
                                                        controller.update();
                                                        Get.back();
                                                      },
                                                      child: CircleAvatar(
                                                        radius: 18,
                                                        backgroundColor:
                                                            AdminTheme
                                                                .theme
                                                                .contentTheme
                                                                .kF0F0F0,
                                                      ),
                                                    ),
                                            ],
                                          ),
                                        )
                                      : MySpacing.empty(),
                                  MySpacing.height(15),
                                  controller.isProfileLoading
                                      ? AppLoader()
                                      : InkWell(
                                          onTap: () async {
                                            bool isUpdateProfile = await controller.onUpdateProfile(
                                                profilePhoto: controller
                                                        .profileFiles.isNotEmpty
                                                    ? controller
                                                        .profileFiles.first
                                                    : null,
                                                avatarPreference: controller
                                                    .selectedAvatafasolingoagePath
                                                    .value,
                                                countryId: controller
                                                    .selectedCountry.value,
                                                discoverable: controller
                                                    .isProfilePublic.value,
                                                phone:
                                                    controller.phoneNumber.text,
                                                firstName:
                                                    controller.firstName.text,
                                                lastName:
                                                    controller.lastName.text,
                                                countryID: controller
                                                    .selectedCountry.value,
                                                dateOfBirth: DateFormat(AppConstant.yyyyMMddTHHmm)
                                                    .format(DateTime.parse(controller.dateOfBirth.text)),
                                                email: controller.email.text,
                                                address: controller.address.text,
                                                idProofType: controller.selectedIdentityProof.value,
                                                idProofNumber: controller.identityNumber.text,
                                                gender: controller.selectedGender.value);
                                            if (isUpdateProfile) {
                                              WidgetsBinding.instance
                                                  .addPostFrameCallback((_) =>
                                                      showModalBottomSheet(
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            // <-- SEE HERE
                                                            borderRadius:
                                                                BorderRadius
                                                                    .vertical(
                                                              top: Radius
                                                                  .circular(
                                                                      46.r),
                                                            ),
                                                          ),
                                                          context: context,
                                                          isScrollControlled:
                                                              true,
                                                          builder: (context) {
                                                            return Padding(
                                                              padding: MySpacing.only(
                                                                  bottom: MediaQuery.of(
                                                                          context)
                                                                      .viewInsets
                                                                      .bottom),
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .vertical(
                                                                            top:
                                                                                Radius.circular(46.r)),
                                                                child:
                                                                    MyContainer(
                                                                  // height: double.infinity/2,
                                                                  paddingAll: 0,
                                                                  padding: MySpacing.only(
                                                                      left:
                                                                          24.w,
                                                                      right:
                                                                          24.w,
                                                                      top: 16.0,
                                                                      bottom:
                                                                          16),
                                                                  color:
                                                                      contentTheme
                                                                          .white,
                                                                  width:
                                                                      Get.width,
                                                                  // height:Get.height,
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    children: [
                                                                      MySpacing
                                                                          .height(
                                                                              149),
                                                                      MySpacing
                                                                          .height(
                                                                              12),
                                                                      MyText.titleSmall(
                                                                          "profile_updated_successfully"
                                                                              .tr(),
                                                                          style:
                                                                              GoogleFonts.lato(
                                                                            fontSize:
                                                                                18.sp,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            color:
                                                                                contentTheme.k5A5A5A,
                                                                          )),
                                                                      MySpacing
                                                                          .height(
                                                                              159),
                                                                      InkWell(
                                                                        onTap:
                                                                            () {
                                                                          Get.back();
                                                                        },
                                                                        child: MyContainer
                                                                            .bordered(
                                                                          width:
                                                                              double.infinity,
                                                                          borderRadiusAll:
                                                                              8.r,
                                                                          height:
                                                                              52,
                                                                          color:
                                                                              contentTheme.white,
                                                                          borderColor:
                                                                              contentTheme.k0090C0,
                                                                          child:
                                                                              Center(
                                                                            child:
                                                                                MyText.titleSmall(
                                                                              "close".tr(),
                                                                              style: GoogleFonts.lato(
                                                                                fontSize: 16.sp,
                                                                                fontWeight: FontWeight.w500,
                                                                                color: contentTheme.k0090C0,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          }));
                                            }
                                          },
                                          child: MyContainer.bordered(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 12),
                                            width: double.infinity,
                                            borderRadiusAll: 8.r,
                                            color: Colors.transparent,
                                            borderColor: contentTheme.k0090C0,
                                            child: Center(
                                              child: MyText.labelLarge(
                                                // LocaleKeys.Update.tr(),
                                                "update".tr(),
                                                fontSize: 16.sp,
                                                fontWeight: 600,
                                                color: contentTheme.k0090C0,
                                              ),
                                            ),
                                          ),
                                        ),
                                  MySpacing.height(15),
                                  InkWell(
                                    onTap: () {
                                      showModalBottomSheet(
                                          shape: RoundedRectangleBorder(
                                            // <-- SEE HERE
                                            borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(46.r),
                                            ),
                                          ),
                                          context: context,
                                          isScrollControlled: true,
                                          builder: (context) {
                                            return Padding(
                                              padding: MySpacing.only(
                                                  bottom: MediaQuery.of(context)
                                                      .viewInsets
                                                      .bottom),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.vertical(
                                                        top: Radius.circular(
                                                            46.r)),
                                                child: MyContainer(
                                                  // height: double.infinity/2,
                                                  paddingAll: 0,
                                                  padding: MySpacing.only(
                                                      left: 24.w,
                                                      right: 24.w,
                                                      top: 16.0,
                                                      bottom: 16),
                                                  color:
                                                      contentTheme.kDarkColor,
                                                  width: Get.width,
                                                  // height:Get.height,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      MySpacing.height(12),
                                                      MyText.titleSmall(
                                                        textAlign:
                                                            TextAlign.center,
                                                        "are_you_sure_delete_account"
                                                            .tr(),
                                                        style: GoogleFonts.lato(
                                                          fontSize: 18.sp,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: contentTheme
                                                              .k5A5A5A,
                                                        ),
                                                      ),
                                                      MySpacing.height(159),
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child: InkWell(
                                                              onTap: () {
                                                                Get.back();
                                                              },
                                                              child: MyContainer
                                                                  .bordered(
                                                                borderRadiusAll:
                                                                    8.r,
                                                                height: 52,
                                                                color: Colors
                                                                    .transparent,
                                                                borderColor:
                                                                    contentTheme
                                                                        .k0090C0,
                                                                child: Center(
                                                                  child: MyText.titleSmall(
                                                                      "no".tr(),
                                                                      style: GoogleFonts
                                                                          .lato(
                                                                        fontSize:
                                                                            16.sp,
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                        color: contentTheme
                                                                            .k0090C0,
                                                                      )),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          MySpacing.width(16.w),
                                                          Expanded(
                                                            child: InkWell(
                                                              onTap: () async {
                                                                await controller
                                                                    .onDeleteAccount();
                                                              },
                                                              child: MyContainer
                                                                  .bordered(
                                                                bordered: false,
                                                                borderRadiusAll:
                                                                    8.r,
                                                                height: 52,
                                                                color:
                                                                    contentTheme
                                                                        .k0090C0,
                                                                child: Center(
                                                                  child: MyText.titleSmall(
                                                                      "yes"
                                                                          .tr(),
                                                                      style: GoogleFonts
                                                                          .lato(
                                                                        fontSize:
                                                                            16.sp,
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                        color: contentTheme
                                                                            .white,
                                                                      )),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          });
                                    },
                                    child: MyContainer.bordered(
                                      width: double.infinity,
                                      borderRadiusAll: 8.r,
                                      bordered: false,
                                      padding:
                                          EdgeInsets.symmetric(vertical: 12),
                                      color: contentTheme.kD4372C,
                                      child: Center(
                                        child: MyText.titleSmall(
                                          "delete_account".tr(),
                                          fontSize: 16.sp,
                                          fontWeight: 600,
                                          color: contentTheme.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  MySpacing.height(25),
                                ],
                              ),
                      );
                    },
                  ),
                )
              : Container()),
    );
  }
}
