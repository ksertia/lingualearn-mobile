import 'package:fasolingo/helpers/utils/ui_mixins.dart';
import 'package:fasolingo/helpers/my_widgets/my_spacing.dart';
import 'package:fasolingo/helpers/my_widgets/my_text.dart';
import 'package:fasolingo/helpers/my_widgets/my_text_style.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomListTile extends StatefulWidget {
  final String? leading;
  final String? title;
  final String? subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  const CustomListTile({
    Key? key,
    required this.leading,
    required this.title,
    this.subtitle,
    required this.trailing,
    required this.onTap,
  }) : super(key: key);

  @override
  State<CustomListTile> createState() => _CustomListTileState();
}

class _CustomListTileState extends State<CustomListTile>
    with SingleTickerProviderStateMixin, UIMixin {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Padding(
        padding: MySpacing.symmetric(vertical: 5),
        child: Row(
          children: [
            Image.asset(
              widget.leading ?? "",
              height: kIsWeb ? 20 : 24,
              width: kIsWeb ? 20 : 24.w,
              fit: BoxFit.cover,
              color: contentTheme.black,
            ),
            MySpacing.width(16.0.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText.bodyMedium(
                    widget.title ?? "",
                    style: MyTextStyle.bodySmall(
                        fontWeight: 400,
                        fontSize: kIsWeb ? 18 : 18.sp,
                        color: contentTheme.black),
                  ),
                  if (widget.subtitle != null) ...[
                    MySpacing.height(6.0.w),
                    MyText.bodySmall(
                      widget.subtitle ?? "",
                      style: MyTextStyle.bodySmall(
                        fontWeight: 400,
                        fontSize: kIsWeb ? 12 : 12.sp,
                        color: contentTheme.black,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            widget.trailing,
          ],
        ),
      ),
    );
  }
}
