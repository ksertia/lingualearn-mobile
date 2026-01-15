import 'package:fasolingo/helpers/extensions/date_time_extention.dart';
import 'package:fasolingo/helpers/theme/admin_theme.dart';
import 'package:fasolingo/helpers/my_widgets/my_spacing.dart';
import 'package:fasolingo/helpers/my_widgets/my_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Utils {
  static InputDecoration get dropdownDecoration => InputDecoration(
      filled: true,
      fillColor: AdminTheme.theme.contentTheme.kDarkColor,
      focusedErrorBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: AdminTheme.theme.contentTheme.red, width: 1)),
      border: OutlineInputBorder(
          borderSide: BorderSide(
              color: AdminTheme.theme.contentTheme.kEDEDED, width: 1)),
      enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: AdminTheme.theme.contentTheme.kEDEDED, width: 1)),
      focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: AdminTheme.theme.contentTheme.kEDEDED, width: 1)),
      contentPadding:
          EdgeInsets.only(bottom: 12.h, top: 12.h, left: 15.w, right: 10.w),
      // isCollapsed: true,
      isDense: true,
      floatingLabelBehavior: FloatingLabelBehavior.never);

  static InputDecoration? decoration = InputDecoration(
      filled: true,
      fillColor: AdminTheme.theme.contentTheme.kPoolBackground,
      hintText: "Select",
      hintStyle: MyTextStyle.bodySmall(
          fontWeight: 400,
          fontSize: 12,
          color: AdminTheme.theme.contentTheme.kB7B7B7),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide(
          width: 1.w,
          color: AdminTheme.theme.contentTheme.red,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide(
          width: 1.w,
          color: AdminTheme.theme.contentTheme.red,
        ),
      ),
      border: OutlineInputBorder().copyWith(
          borderSide: BorderSide(
              color: AdminTheme.theme.contentTheme.kB7B7B7, width: 1)),
      enabledBorder: OutlineInputBorder().copyWith(
          borderSide: BorderSide(
              color: AdminTheme.theme.contentTheme.kB7B7B7, width: 1)),
      focusedBorder: OutlineInputBorder().copyWith(
          borderSide: BorderSide(
              color: AdminTheme.theme.contentTheme.kB7B7B7, width: 1)),
      contentPadding: MySpacing.symmetric(horizontal: 16, vertical: 10),
      isCollapsed: true,
      floatingLabelBehavior: FloatingLabelBehavior.never);
  static getDateStringFromDateTime(DateTime dateTime,
      {bool showMonthShort = false}) {
    String date =
        dateTime.day < 10 ? "0${dateTime.day}" : dateTime.day.toString();
    late String month;
    if (showMonthShort) {
      month = dateTime.getMonthName();
    } else {
      month = dateTime.month < 10
          ? "0${dateTime.month}"
          : dateTime.month.toString();
    }

    String year = dateTime.year.toString();
    String separator = showMonthShort ? " " : "/";
    return "$date$separator$month$separator$year";
  }

  static getTimeStringFromDateTime(
    DateTime dateTime, {
    bool showSecond = true,
  }) {
    String hour = dateTime.hour.toString();
    if (dateTime.hour > 12) {
      hour = (dateTime.hour - 12).toString();
    }

    String minute = dateTime.minute < 10
        ? "0${dateTime.minute}"
        : dateTime.minute.toString();
    String second = "";

    if (showSecond) {
      second = dateTime.second < 10
          ? "0${dateTime.second}"
          : dateTime.second.toString();
    }
    String meridian = "";
    meridian = dateTime.hour < 12 ? " AM" : " PM";

    return "$hour:$minute${showSecond ? ":" : ""}$second$meridian";
  }

  static String getDateTimeStringFromDateTime(DateTime dateTime,
      {bool showSecond = true,
      bool showDate = true,
      bool showTime = true,
      bool showMonthShort = false}) {
    if (showDate && !showTime) {
      return getDateStringFromDateTime(dateTime);
    } else if (!showDate && showTime) {
      return getTimeStringFromDateTime(dateTime, showSecond: showSecond);
    }
    return "${getDateStringFromDateTime(dateTime, showMonthShort: showMonthShort)} ${getTimeStringFromDateTime(dateTime, showSecond: showSecond)}";
  }

  static String getStorageStringFromByte(int bytes) {
    double b = bytes.toDouble(); //1024
    double k = bytes / 1024; //1
    double m = k / 1024; //0.001
    double g = m / 1024; //...
    double t = g / 1024; //...

    if (t >= 1) {
      return "${t.toStringAsFixed(2)} TB";
    } else if (g >= 1) {
      return "${g.toStringAsFixed(2)} GB";
    } else if (m >= 1) {
      return "${m.toStringAsFixed(2)} MB";
    } else if (k >= 1) {
      return "${k.toStringAsFixed(2)} KB";
    } else {
      return "${b.toStringAsFixed(2)} Bytes";
    }
  }
}
