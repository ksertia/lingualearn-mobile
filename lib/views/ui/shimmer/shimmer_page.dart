import 'package:fasolingo/helpers/theme/admin_theme.dart';
import 'package:fasolingo/helpers/my_widgets/my_spacing.dart';
import 'package:fasolingo/helpers/my_widgets/responsive.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerPage extends StatelessWidget {
  const ShimmerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        period: Duration(milliseconds: 1200),
        baseColor: AdminTheme.theme.contentTheme.disabled,
        highlightColor: Colors.grey.shade300,
        child: ListView(
          children: [
            MySpacing.height(flexSpacing),
            Container(
              width: double.infinity,
              height: 180.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                color: Colors.white,
              ),
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  4,
                  (index) => Container(
                    width: 75,
                    height: 35,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)),
                  ),
                )).paddingSymmetric(vertical: 10),
            GridView.builder(
                itemCount: 4,
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.78),
                itemBuilder: (context, index) => Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5)),
                    ))
          ],
        ));
  }
}
