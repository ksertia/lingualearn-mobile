import 'package:fasolingo/helpers/storage/local_storage.dart';
import 'package:fasolingo/helpers/utils/ui_mixins.dart';
import 'package:fasolingo/helpers/my_widgets/my_spacing.dart';
import 'package:fasolingo/helpers/my_widgets/my_text_style.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Custom Text Input Fields
class TextInputFields extends StatefulWidget {
  /// Constructs a new TextInputFields
  const TextInputFields(
      {super.key,
      this.suffixWidget,
      this.fillColor,
      this.prefixWidget,
      this.keyboardType,
      this.validator,
      this.controller,
      this.obSecureText,
      this.onTap,
      this.readOnly = false,
      this.contentPadding,
      this.textAlign,
      this.name,
      this.hintText,
      this.suffix,
      this.focusNode,
      this.nameColor,
      this.hintTextStyle,
      this.textStyle,
      this.titleTextStyle,
      this.suffixIconConstraints,
      this.filled,
      this.borderColor,
      this.onChanged,
      this.initialValue,
      this.errorStyle,
      this.maxLine = 1,
      this.fontSize,
      this.onFieldSubmitted,
      this.prefixIconConstraints,
      this.inputFormatters,
      this.decoration});

  /// Suffix widget
  final Widget? suffixWidget;

  final InputDecoration? decoration;

  /// Prefix widget
  final Widget? prefixWidget;

  /// Keyboard type
  final TextInputType? keyboardType;

  /// Validator
  final String? Function(String?)? validator;

  /// TextEditing controller
  final TextEditingController? controller;
  final List<TextInputFormatter>? inputFormatters;
  final bool? obSecureText;
  final VoidCallback? onTap;
  final TextAlign? textAlign;
  final TextStyle? errorStyle;
  final double? fontSize;
  final bool readOnly;
  final Color? fillColor;
  final String? name;
  final String? initialValue;
  final EdgeInsetsGeometry? contentPadding;
  final String? hintText;
  final Widget? suffix;
  final FocusNode? focusNode;
  final Color? nameColor;
  final TextStyle? hintTextStyle;
  final Function(String)? onChanged;
  final TextStyle? textStyle;
  final TextStyle? titleTextStyle;
  final bool? filled;
  final Color? borderColor;
  final BoxConstraints? suffixIconConstraints;
  final BoxConstraints? prefixIconConstraints;
  final int maxLine;
  final Function(String)? onFieldSubmitted;

  @override
  State<TextInputFields> createState() => _TextInputFieldsState();
}

class _TextInputFieldsState extends State<TextInputFields>
    with SingleTickerProviderStateMixin, UIMixin {
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (widget.name != null)
            Text(
              widget.name!,
              style: widget.titleTextStyle ??
                  MyTextStyle.bodySmall(
                    fontWeight: 400,
                    fontSize: kIsWeb ? 15 : 15.sp,
                    color: contentTheme.black,
                  ),
            ),
          if (widget.name != null) MySpacing.height(8),
          TextFormField(
            scrollPadding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 15.sp * 20),
            onFieldSubmitted: widget.onFieldSubmitted,
            initialValue: widget.initialValue,
            textCapitalization: TextCapitalization.sentences,
            readOnly: widget.readOnly,
            textAlign: widget.textAlign ?? TextAlign.start,
            style: widget.textStyle ??
                MyTextStyle.bodySmall(
                    fontWeight: 400,
                    fontSize: 16.sp,
                    color: contentTheme.black),
            onChanged: widget.onChanged,
            onTap: widget.onTap,
            obscureText: widget.obSecureText ?? false,
            controller: widget.controller,
            keyboardType: widget.keyboardType,
            // enabled: readOnly,
            cursorColor: contentTheme.onPrimary,
            validator: widget.validator,
            inputFormatters: widget.inputFormatters,
            maxLines: widget.maxLine,
            decoration: widget.decoration ??
                InputDecoration(
                  fillColor: widget.fillColor ?? contentTheme.kF6F6F6,
                  filled: widget.filled,
                  hintText: widget.hintText,
                  hintStyle: widget.hintTextStyle ??
                      MyTextStyle.bodySmall(
                          fontWeight: 400,
                          fontSize: kIsWeb ? 14 : 14.sp,
                          color: contentTheme.kB7B7B7),
                  errorMaxLines: 2,
                  errorStyle: widget.errorStyle?? TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12.sp,
                    color: contentTheme.danger,),
                  contentPadding: widget.contentPadding ??
                      EdgeInsets.only(
                          bottom: kIsWeb ? 12 : 12,
                          top: kIsWeb ? 12 : 12,
                          left: 15.w,
                          right: 10.w),
                  border: border,
                  isDense: true,
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(
                      width: 1.w,
                      color: widget.borderColor ?? contentTheme.k005EA2,
                    ),
                  ),
                  suffixIconConstraints: widget.suffixIconConstraints,
                  disabledBorder: border,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(
                      width: 1.w,
                      color: LocalStorage.getTheme() == "Dark"
                          ? widget.borderColor ?? contentTheme.primary
                          : widget.borderColor ?? contentTheme.k005EA2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(
                      width: 1.w,
                      color: contentTheme.red,
                    ),
                  ),
                  prefixIconConstraints: widget.prefixIconConstraints,
                  suffix: widget.suffix,
                  enabledBorder: border,
                  suffixIcon: widget.suffixWidget,
                  prefixIcon: widget.prefixWidget,
                ),
          ),
        ],
      );

  /// Border
  OutlineInputBorder get border => OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(
          width: 1.w,
          color: widget.borderColor ?? contentTheme.kE6E6E6,
        ),
      );
}
