import 'package:fasolingo/helpers/extensions/string.dart';
import 'package:fasolingo/helpers/theme/admin_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../helpers/my_widgets/my_text.dart';



class ImageSourceBottomSheet {
  static void show(BuildContext context,
      {required VoidCallback onGalleryTap, required VoidCallback onCameraTap}) {
    try {
      showModalBottomSheet(
        backgroundColor: AdminTheme.theme.contentTheme.bottomBarColor,
        context: context,
        builder: (BuildContext bc) {
          try {
            return SafeArea(
              child: Wrap(
                children: <Widget>[
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      onGalleryTap();
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 16.h, horizontal: 16.w),
                      child: Row(
                        children: [
                          Icon(
                            Icons.photo_library,
                            size: 18.sp,
                            color: AdminTheme.theme.contentTheme.black,
                          ),
                          16.horizontalSpace,
                          Expanded(
                            child: MyText.titleLarge(
                              'gallery'.tr(),
                              textAlign: TextAlign.start,
                              fontWeight: 600,
                              fontSize: 18.sp,
                              color: AdminTheme.theme.contentTheme.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(
                      height: 1.h,
                      color: AdminTheme.theme.contentTheme.kE6E6E6),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      onCameraTap();
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 16.h, horizontal: 16.w),
                      child: Row(
                        children: [
                          Icon(
                            Icons.camera_alt,
                            size: 18.sp,
                            color: AdminTheme.theme.contentTheme.black,
                          ),
                          16.horizontalSpace,
                          Expanded(
                            child: MyText.titleLarge(
                              'camera'.tr(),
                              textAlign: TextAlign.start,
                              fontWeight: 600,
                              fontSize: 18.sp,
                              color: AdminTheme.theme.contentTheme.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          } catch (e) {
            print("Error in ImageSourceBottomSheet builder: $e");
            return Container(
                child: Text("Error loading options")); // Show an error message
          }
        },
      );
    } catch (e) {
      print("Error showing ImageSourceBottomSheet: $e");
    }
  }
}
