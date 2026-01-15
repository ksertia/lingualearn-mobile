import 'package:fasolingo/helpers/theme/admin_theme.dart';
import 'package:fasolingo/helpers/my_widgets/my_container.dart';
import 'package:fasolingo/helpers/my_widgets/my_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class ChatDetailShimmer extends StatelessWidget {
  const ChatDetailShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15),
        itemBuilder: (context, index) => Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            enabled: true,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    MyContainer.rounded(
                      height: 35,
                      width: 35,
                      paddingAll: 0,
                    ),
                    MySpacing.width(7),
                    Container(
                      constraints: BoxConstraints(
                          maxWidth: MySpacing.fullWidth(context) * 0.70),
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.w, vertical: 8),
                      decoration: BoxDecoration(
                          color: AdminTheme.theme.contentTheme.kE6E6E6,
                          borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 230.w,
                            height: 13.0,
                            color: Colors.white,
                          ),
                          5.verticalSpace,
                          Container(
                            width: 230.w,
                            height: 13.0,
                            color: Colors.white,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                10.verticalSpace,
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      constraints: BoxConstraints(
                          maxWidth: MySpacing.fullWidth(context) * 0.70),
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.w, vertical: 8),
                      decoration: BoxDecoration(
                          color: AdminTheme.theme.contentTheme.kE6E6E6,
                          borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 230.w,
                            height: 13.0,
                            color: Colors.white,
                          ),
                          5.verticalSpace,
                          Container(
                            width: 230.w,
                            height: 13.0,
                            color: Colors.white,
                          )
                        ],
                      ),
                    )
                  ],
                )
              ],
            )),
        separatorBuilder: (context, index) => 10.verticalSpace,
        itemCount: 5);
  }
}
