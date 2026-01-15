import 'package:fasolingo/helpers/my_widgets/my_text.dart';
import 'package:fasolingo/helpers/utils/ui_mixins.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AmountButton extends StatefulWidget {
  final String amount;
  final VoidCallback onPressed;

  const AmountButton({Key? key, required this.amount, required this.onPressed})
      : super(key: key);

  @override
  State<AmountButton> createState() => _AmountButtonState();
}

class _AmountButtonState extends State<AmountButton>
    with SingleTickerProviderStateMixin, UIMixin {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onPressed,
      child: Container(
        width: 112.w,
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: contentTheme.black),
        ),
        child: Center(
          child: MyText.titleMedium(
            widget.amount,
            fontWeight: 500,
            fontSize: 16.sp,
            color: contentTheme.black,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
