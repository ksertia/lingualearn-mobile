/*
* File : Admin Theme
* Version : 1.0.0
* */

import 'package:fasolingo/helpers/storage/local_storage.dart';
import 'package:flutter/material.dart';

enum LeftBarThemeType { light, dark }

enum ContentThemeType { light, dark }

enum RightBarThemeType { light, dark }

enum POOLTYPE {
  myPool,
  invitedPool,
  myContribution,
  publicPool,
  periodicPool,
  draft,
  myApprovals
}

enum ContentThemeColor {
  primary,
  secondary,
  success,
  info,
  warning,
  danger,
  light,
  dark,
  // New Added
  pink,
  green,
  red;

  Color get color {
    return (AdminTheme.theme.contentTheme.getMappedIntoThemeColor[this]
            ?['color']) ??
        Colors.black;
  }

  Color get onColor {
    return (AdminTheme.theme.contentTheme.getMappedIntoThemeColor[this]
            ?['onColor']) ??
        Colors.white;
  }
}

class LeftBarTheme {
  final Color background, onBackground;
  final Color labelColor;
  final Color activeItemColor, activeItemBackground;

  LeftBarTheme({
    this.background = const Color(0xffffffff),
    this.onBackground = const Color(0xff313a46),
    this.labelColor = const Color(0xff6c757d),
    this.activeItemColor = const Color(0xff3874ff),
    // this.activeItemColor = const Color(0xff006784),
    this.activeItemBackground = const Color(0x153874ff),

    // this.activeItemBackground = const Color(0x14006784),
  });

  //--------------------------------------  Left Bar Theme ----------------------------------------//

  static final LeftBarTheme lightLeftBarTheme = LeftBarTheme();

  static final LeftBarTheme darkLeftBarTheme = LeftBarTheme(
      background: const Color(0xff282c32),
      onBackground: const Color(0xffdcdcdc),
      labelColor: const Color(0xff879baf),
      activeItemBackground: const Color(0xff363c44),
      activeItemColor: const Color(0xffffffff));

  static LeftBarTheme getThemeFromType(LeftBarThemeType leftBarThemeType) {
    switch (leftBarThemeType) {
      case LeftBarThemeType.light:
        return lightLeftBarTheme;
      case LeftBarThemeType.dark:
        return darkLeftBarTheme;
    }
  }
}

class TopBarTheme {
  final Color background;
  final Color onBackground;

  TopBarTheme({
    this.background = const Color(0xffffffff),
    this.onBackground = const Color(0xff313a46),
  });

  //--------------------------------------  Left Bar Theme ----------------------------------------//

  static final TopBarTheme lightTopBarTheme = TopBarTheme();

  static final TopBarTheme darkTopBarTheme = TopBarTheme(
      background: const Color(0xff2c3036),
      onBackground: const Color(0xffdcdcdc));
}

class RightBarTheme {
  final Color disabled, onDisabled;
  final Color activeSwitchBorderColor, inactiveSwitchBorderColor;

  RightBarTheme({
    this.disabled = const Color(0xffffffff),
    this.activeSwitchBorderColor = const Color(0xff727cf5),
    this.inactiveSwitchBorderColor = const Color(0xffdee2e6),
    this.onDisabled = const Color(0xff313a46),
  });

  //--------------------------------------  Left Bar Theme ----------------------------------------//

  static final RightBarTheme lightRightBarTheme = RightBarTheme(
      disabled: const Color(0xffffffff),
      onDisabled: const Color(0xffdee2e6),
      activeSwitchBorderColor: const Color(0xff727cf5),
      inactiveSwitchBorderColor: const Color(0xffdee2e6));

  static final RightBarTheme darkRightBarTheme = RightBarTheme(
      disabled: const Color(0xff444d57),
      activeSwitchBorderColor: const Color(0xff727cf5),
      inactiveSwitchBorderColor: const Color(0xffdee2e6),
      onDisabled: const Color(0xff515a65));
}

class ContentTheme {
  final Color background, onBackground;
  final Color primary, onPrimary;
  final Color secondary, onSecondary;
  final Color success, onSuccess;
  final Color danger, onDanger;
  final Color warning, onWarning;
  final Color info, onInfo;
  final Color light, onLight;
  final Color dark, onDark;
  final Color green;
  final Color textTertiary;
  final Color textSecondary;

  // New Added----------------
  final Color purple, onPurple;
  final Color pink, onPink;
  final Color red, onRed;
  final Color black, k0B7927, smallGun;
  final Color curserColor;
  final Color k5E5E5E;
  final Color k8A8A8A, kFFD9BF;
  final Color white, helpFloating;
  final Color k004860;
  final Color kEFEFEF;
  final Color kFCD116;
  final Color backgroundColor;
  final Color eventBackgroundColor;
  final Color kProfileBackground;
  final Color k1A1A1A;
  final Color kPoolBackground;
  final Color k71B970;
  final Color k005EA2;
  final Color k1E1E1E;
  final Color k545454;
  final Color k0A0A0A;
  final Color k50637D, kF9F9F9;
  final Color kFFE3B0;
  final Color k707070, k261408, k191410;
  final Color kD9D9D9, kCECECE;
  final Color k0090C0;
  final Color k090A0A;
  final Color k5A5A5A;
  final Color kF2F2F2;
  final Color k060606;
  final Color kEDEDED;
  final Color kB7B7B7;
  final Color k222222;
  final Color kF6F6F6;
  final Color k606060;
  final Color k61646B;
  final Color k00243F;
  final Color k929292;
  final Color k437E42;
  final Color kCBCBCB;
  final Color k32882A;
  final Color k2D2D2D;
  final Color kECECEC;
  final Color kDBDBDB;
  final Color kA29F9F;
  final Color k2A2A2A;
  final Color kF1F3F8;
  final Color k1D1B20;
  final Color withdrawalColor;
  final Color pendingColor;
  final Color rejectedColor;
  final Color withdrawalTextColor;
  final Color pendingTextColor;
  final Color rejectedTextColor;
  final Color F26607;
  final Color bottomBarColor, cardBorderColor, walletCardColor;
  final Color kD4372C;
  final Color kB0B0B0;
  final Color k3FAA35;
  final Color kAFAFAF;
  final Color kF7DA44;
  final Color kEB3D31;
  final Color kCAF6C6;
  final Color k333333;
  final Color k636363;
  final Color kDark333333;
  final Color kE6E6E6, k0775F2, kD2E2F5, tranTabBorderColor;
  final Color kEDF4ED, kD23131;
  final Color k1D4F19;
  final Color kDF2020;
  final Color k6A6A6A;
  final Color k8F9BB3;
  final Color k00374A;
  final Color kDADADA, k13D243, k13D2433;
  final Color k222B45;
  final Color kCED3DE;
  final Color kDFDFDF;
  final Color kDarkColor;
  final Color k7FC7DF;
  final Color k32A9FF;
  final Color kF0F0F0;
  final Color kAAAAAA;
  final Color k2C542C;
  final Color kE6F0F8;
  final Color k0068B4;
  final Color kF5F5F5, k6D6D6D;
  final Color kD9DDE7, plugCount;
  final Color k304EA8;
  final Color k2BBA29;
  final Color kD2D2D2;
  final Color k7A7A7A;
  final Color k1E8564;
  final Color kC0C0C0;
  final Color kF2EFEA;
  final Color k535353;
  final Color kBEBEBE;
  final Color kFF0000, kFFA500, k00FF00, k0077FF, k5D3FD3;

  //--------------------------

  final Color cardBackground, cardShadow, cardBorder, cardText, cardTextMuted;

  final Color title;

  final Color disabled, onDisabled;

  Map<ContentThemeColor, Map<String, Color>> get getMappedIntoThemeColor {
    var c = AdminTheme.theme.contentTheme;
    return {
      ContentThemeColor.primary: {'color': c.primary, 'onColor': c.onPrimary},
      ContentThemeColor.secondary: {
        'color': c.secondary,
        'onColor': c.onSecondary
      },
      ContentThemeColor.success: {'color': c.success, 'onColor': c.onSuccess},
      ContentThemeColor.info: {'color': c.info, 'onColor': c.onInfo},
      ContentThemeColor.warning: {'color': c.warning, 'onColor': c.onWarning},
      ContentThemeColor.danger: {'color': c.danger, 'onColor': c.onDanger},
      ContentThemeColor.light: {'color': c.light, 'onColor': c.onLight},
      ContentThemeColor.dark: {'color': c.dark, 'onColor': c.onDark},
      // New Added
      ContentThemeColor.pink: {'color': c.pink, 'onColor': c.onPink},
      // ContentThemeColor.blue: {'color': c.blue, 'onColor': c.onBlue},
      // ContentThemeColor.green: {'color': c.green, 'onColor': c.onGreen},
      ContentThemeColor.red: {'color': c.red, 'onColor': c.onRed},
    };
  }

  ContentTheme(
      {this.background = const Color(0xfffafbfe),
      this.kFF0000 = const Color(0xffFF0000),
      this.kFFA500 = const Color(0xffFFA500),
      this.textTertiary = const Color(0xFF9CA3AF),
      this.textSecondary = const Color(0xFF6B7280),
      this.k00FF00 = const Color(0xff00FF00),
      this.k0077FF = const Color(0xff0077FF),
      this.k1E8564 = const Color(0xff1E8564),
      this.kF9F9F9 = const Color(0xffF9F9F9),
      this.k5D3FD3 = const Color(0xff5D3FD3),
      this.kDBDBDB = const Color(0xffDBDBDB),
      this.kProfileBackground = const Color(0xffEFEFEF),
      this.kA29F9F = const Color(0xffA29F9F),
      this.kDF2020 = const Color(0xffDF2020),
      this.kFCD116 = const Color(0xffFCD116),
      this.eventBackgroundColor = const Color(0xffEFEFEF),
      this.k636363 = const Color(0xff636363),
      this.helpFloating = const Color(0xffFFD9BF),
      this.k191410 = const Color(0xff191410),
      this.k222222 = const Color(0xff222222),
      this.k090A0A = const Color(0xff090A0A),
      this.k50637D = const Color(0xff50637D),
      this.kD2E2F5 = const Color(0xffD2E2F5),
      this.smallGun = const Color(0xffD9D9D9),
      this.k13D243 = const Color(0xff13D243),
      this.k13D2433 = const Color(0xff13D243),
      this.k0B7927 = const Color(0xff0B7927),
      this.k5E5E5E = const Color(0xff5E5E5E),
      this.kFFD9BF = const Color(0xffFFD9BF),
      this.kE6F0F8 = const Color(0xffE6F0F8),
      this.k61646B = const Color(0xff61646B),
      this.tranTabBorderColor = const Color(0xff000000),
      this.kBEBEBE = const Color(0xffBEBEBE),
      this.k0090C0 = const Color(0xff0090C0),
      this.k2C542C = const Color(0xff2C542C),
      this.walletCardColor = const Color(0xff191410),
      this.k0068B4 = const Color(0xff0068B4),
      this.plugCount = const Color(0xff61646B),
      this.kC0C0C0 = const Color(0xffC0C0C0),
      this.kDADADA = const Color(0xffDADADA),
      this.kCBCBCB = const Color(0xffCBCBCB),
      this.k535353 = const Color(0xff535353),
      this.kF2EFEA = const Color(0xffF2EFEA),
      this.F26607 = const Color(0xffF26607),
      this.kD23131 = const Color(0xffD23131),
      this.withdrawalColor = const Color(0xffCAF6C6),
      this.pendingColor = const Color(0xffFFE3B0),
      this.rejectedColor = const Color(0xffF9C3BF),
      this.withdrawalTextColor = const Color(0xff4A8C49),
      this.rejectedTextColor = const Color(0xffEB3D31),
      this.pendingTextColor = const Color(0xffFFA500),
      this.bottomBarColor = const Color(0xffffffff),
      this.cardBorderColor = const Color(0xff261408),
      this.backgroundColor = const Color(0xffffffff),
      this.kPoolBackground = const Color(0xffffffff),
      this.kDarkColor = const Color(0xff00000),
      this.kCECECE = const Color(0xffCECECE),
      this.kDark333333 = const Color(0xff333333),
      this.curserColor = const Color(0xff000000),
      this.kEDF4ED = const Color(0xffEDF4ED),
      this.k7A7A7A = const Color(0xff7A7A7A),
      this.k0775F2 = const Color(0xff0775F2),
      this.k261408 = const Color(0xff261408),
      this.k0A0A0A = const Color(0xff0A0A0A),
      this.k1D1B20 = const Color(0xff1D1B20),
      this.kF1F3F8 = const Color(0xffF1F3F8),
      this.kB0B0B0 = const Color(0xffB0B0B0),
      this.k3FAA35 = const Color(0xff3FAA35),
      this.k929292 = const Color(0xff929292),
      this.k437E42 = const Color(0xff437E42),
      this.kECECEC = const Color(0xffECECEC),
      this.k6A6A6A = const Color(0xff6A6A6A),
      this.onBackground = const Color(0xffF1F1F2),
      this.green = const Color(0xff71B970),
      this.black = const Color(0xff000000),
      this.k8A8A8A = const Color(0xff8A8A8A),
      this.k2A2A2A = const Color(0xff2A2A2A),
      this.kF2F2F2 = const Color(0xffF2F2F2),
      this.k005EA2 = const Color(0xff005EA2),
      this.k545454 = const Color(0xff545454),
      this.k32882A = const Color(0xff32882A),
      this.kCAF6C6 = const Color(0xffCAF6C6),
      this.primary = const Color(0xff28a745),
      this.k060606 = const Color(0xff060606),
      this.k1D4F19 = const Color(0xff1D4F19),
      this.kE6E6E6 = const Color(0xffE6E6E6),
      this.kEDEDED = const Color(0xffEDEDED),
      this.k707070 = const Color(0xff707070),
      this.kB7B7B7 = const Color(0xffB7B7B7),
      this.kEFEFEF = const Color(0xffEFEFEF),
      this.kFFE3B0 = const Color(0xffFFE3B0),
      this.k1E1E1E = const Color(0xff1E1E1E),
      this.kF6F6F6 = const Color(0xffF6F6F6),
      this.k606060 = const Color(0xff606060),
      this.k00243F = const Color(0xff00243F),
      this.k333333 = const Color(0xff333333),
      this.k2D2D2D = const Color(0xff2D2D2D),
      this.k5A5A5A = const Color(0xff5A5A5A),
      // this.primary = const Color(0xff006784),
      this.onPrimary = const Color(0xff28a745),
      this.disabled = const Color(0xffffffff),
      this.onDisabled = const Color(0xffffffff),
      this.secondary = const Color(0xff6c757d),
      this.onSecondary = const Color(0xffffffff),
      this.kAAAAAA = const Color(0xffAAAAAA),
      this.success = const Color(0xff00be82),
      // this.success = const Color(0xff198754),
      this.onSuccess = const Color(0xffffffff),
      this.danger = const Color(0xffdc3545),
      this.onDanger = const Color(0xffffffff),
      this.warning = const Color(0xffffc107),
      this.onWarning = const Color(0xff313a46),
      this.info = const Color(0xff0dcaf0),
      this.onInfo = const Color(0xffffffff),
      this.light = const Color(0xffeef2f7),
      this.onLight = const Color(0xff313a46),
      this.dark = const Color(0xff313a46),
      this.onDark = const Color(0xffffffff),
      this.cardBackground = const Color(0xffffffff),
      this.cardShadow = const Color(0xffffffff),
      this.cardBorder = const Color(0xffffffff),
      this.cardText = const Color(0xff6c757d),
      this.cardTextMuted = const Color(0xff98a6ad),
      this.title = const Color(0xff6c757d),
      this.k1A1A1A = const Color(0xff1A1A1A),
      this.kF5F5F5 = const Color(0xffF5F5F5),

      // New Added
      this.pink = const Color(0xffFF1087),
      this.onPink = const Color(0xffffffff),
      this.purple = const Color(0xff800080),
      this.onPurple = const Color(0xffFF0000),
      this.red = const Color(0xffFF0000),
      this.white = const Color(0xffFFFFFF),
      this.onRed = const Color(0xffffffff),
      this.k004860 = const Color(0xFF004860),
      this.k71B970 = const Color(0xFF71B970),
      this.kD9D9D9 = const Color(0xff000000),
      this.kAFAFAF = const Color(0xffAFAFAF),
      this.kF7DA44 = const Color(0xffF7DA44),
      this.kEB3D31 = const Color(0xffEB3D31),
      this.k8F9BB3 = const Color(0xff8F9BB3),
      this.k00374A = const Color(0xff00374A),
      this.k222B45 = const Color(0xff222B45),
      this.kCED3DE = const Color(0xffCED3DE),
      this.kDFDFDF = const Color(0xffDFDFDF),
      this.k7FC7DF = const Color(0xff7FC7DF),
      this.k32A9FF = const Color(0xff32A9FF),
      this.kF0F0F0 = const Color(0xffF0F0F0),
      this.k6D6D6D = const Color(0xff6D6D6D),
      this.kD9DDE7 = const Color(0xffD9DDE7),
      this.k304EA8 = const Color(0xff304EA8),
      this.k2BBA29 = const Color(0xff2BBA29),
      this.kD2D2D2 = const Color(0xffD2D2D2),
      this.kD4372C = const Color(0xffD4372C)});

  //--------------------------------------  Left Bar Theme ----------------------------------------//

  static final ContentTheme lightContentTheme = ContentTheme(
      background: const Color(0xfffafbfe),
      onBackground: const Color(0xff313a46),
      kD9D9D9: const Color(0xff000000),
      k2D2D2D: const Color(0xff000000),
      kFFD9BF: const Color(0xffFFD9BF),
      k191410: Color(0xffffffff),
      plugCount: Color(0xffffffff),
      k0B7927: const Color(0xff0B7927),
      cardBorder: const Color(0xffffffff),
      cardBackground: const Color(0xffffffff),
      cardShadow: const Color(0xff9aa1ab),
      curserColor: const Color(0xff000000),
      cardText: const Color(0xff6c757d),
      k13D2433: const Color(0xff13D243),
      kD23131: const Color(0xffD23131),
      smallGun: const Color(0xffD9D9D9),
      kDarkColor: const Color(0xffffffff),
      title: const Color(0xff6c757d),
      tranTabBorderColor: const Color(0xff000000),
      walletCardColor: const Color(0xff191410),
      cardTextMuted: const Color(0xff98a6ad),
      k1A1A1A: const Color(0xffEFEFEF),
      bottomBarColor: const Color(0xffffffff),
      backgroundColor: const Color(0xffffffff),
      cardBorderColor: const Color(0xff221A14),
      k0A0A0A: const Color(0xffffffff),
      kPoolBackground: const Color(0xffffffff),
      kF6F6F6: const Color(0xffF6F6F6),
      kE6E6E6: const Color(0xffE6E6E6),
      black: const Color(0xff000000));

  static final ContentTheme darkContentTheme = ContentTheme(
    background: const Color(0xffffffff),
    onBackground: const Color(0xffF1F1F2),
    kD9D9D9: const Color(0xffffffff),
    kF6F6F6: const Color(0xff221A14),
    k191410: Color(0xff191410),
    kE6E6E6: const Color(0xff3E342D),
    kFFD9BF: const Color(0xffFFD9BF).withOpacity(0.1),
    disabled: const Color(0xff3C3C3C),
    plugCount: Color(0xff61646B),
    onDisabled: const Color(0xff515a65),
    kD23131: const Color(0xffF33030),
    tranTabBorderColor: const Color(0xff3E342D),
    cardBorder: const Color(0xff464f5b),
    k2D2D2D: const Color(0xff2D2D2D),
    k13D2433: const Color(0xff3E342D),
    smallGun: const Color(0xff3E342D),
    cardBackground: const Color(0xff37404a),
    cardShadow: const Color(0xff01030E),
    cardText: const Color(0xffaab8c5),
    title: const Color(0xffaab8c5),
    k0B7927: const Color(0xff13D243),
    k1A1A1A: const Color(0xff1A1A1A),
    kF2F2F2: const Color(0xDD000000),
    kDarkColor: const Color(0xff1B1B1B),
    kPoolBackground: const Color(0xff1A1A1A),
    eventBackgroundColor: const Color(0xff000000),
    black: const Color(0xffffffff),
    curserColor: const Color(0xff000000),
    k060606: const Color(0xffffffff),
    bottomBarColor: const Color(0xff221A14),
    backgroundColor: const Color(0xff191410),
    walletCardColor: const Color(0xff221A14),
    cardBorderColor: const Color(0xffffffff),
    kFFE3B0: const Color(0xffffffff),
    k545454: const Color(0xffCBCBCB),
    kEFEFEF: const Color(0xffffffff).withOpacity(0.50),
    k0A0A0A: const Color(0xff000000),
    k8A8A8A: const Color(0xffCBCBCB),
    k333333: const Color(0xffCBCBCB),
    k5A5A5A: const Color(0xffffffff).withOpacity(0.80),
    kDark333333: const Color(0xff000000),
    kProfileBackground: const Color(0xff1B1B1B),
    cardTextMuted: const Color(
      0xff8391a2,
    ),
  );
}

class AdminTheme {
  final LeftBarTheme leftBarTheme;
  final RightBarTheme rightBarTheme;
  final TopBarTheme topBarTheme;
  final ContentTheme contentTheme;

  AdminTheme({
    required this.leftBarTheme,
    required this.topBarTheme,
    required this.rightBarTheme,
    required this.contentTheme,
  });

  //--------------------------------------  Left Bar Theme ----------------------------------------//

  static AdminTheme theme = AdminTheme(
      leftBarTheme: LeftBarTheme.lightLeftBarTheme,
      topBarTheme: TopBarTheme.lightTopBarTheme,
      rightBarTheme: RightBarTheme.lightRightBarTheme,
      contentTheme: ContentTheme.lightContentTheme);

  static void setTheme(BuildContext context) {
    theme = AdminTheme(
        leftBarTheme:
            MediaQuery.of(context).platformBrightness == Brightness.dark
                ? LeftBarTheme.darkLeftBarTheme
                : LeftBarTheme.lightLeftBarTheme,
        topBarTheme:
            MediaQuery.of(context).platformBrightness == Brightness.dark
                ? TopBarTheme.darkTopBarTheme
                : TopBarTheme.lightTopBarTheme,
        rightBarTheme:
            MediaQuery.of(context).platformBrightness == Brightness.dark
                ? RightBarTheme.darkRightBarTheme
                : RightBarTheme.lightRightBarTheme,
        contentTheme: LocalStorage.getTheme() == "Dark"
            ? ContentTheme.darkContentTheme
            : ContentTheme.lightContentTheme);
  }
}
