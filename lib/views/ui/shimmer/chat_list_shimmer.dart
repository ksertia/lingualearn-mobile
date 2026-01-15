import 'package:fasolingo/helpers/theme/admin_theme.dart';
import 'package:fasolingo/helpers/my_widgets/my_container.dart';
import 'package:fasolingo/helpers/my_widgets/my_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class ChatListShimmer extends StatelessWidget {
  const ChatListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        separatorBuilder: (context, index) => 15.verticalSpace,
        itemCount: 10,
        itemBuilder: (context, index) => Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              enabled: true,
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MyContainer.rounded(
                        height: 45,
                        width: 45,
                        paddingAll: 0,
                        color: AdminTheme.theme.contentTheme.kDarkColor,
                      ),
                      MySpacing.width(12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 180.w,
                              height: 13.0,
                              color: AdminTheme.theme.contentTheme.kDarkColor,
                            ),
                            MySpacing.height(7),
                            Container(
                              width: 90.w,
                              height: 10.0,
                              color: AdminTheme.theme.contentTheme.kDarkColor,
                            )
                          ],
                        ),
                      ),
                      MySpacing.width(15),
                      Container(
                        height: 10.0,
                        width: 50.w,
                        color: AdminTheme.theme.contentTheme.kDarkColor,
                      )
                    ],
                  )
                ],
              ),
            ));
  }
}
