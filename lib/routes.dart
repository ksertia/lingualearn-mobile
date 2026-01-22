import 'package:fasolingo/views/apps/change_language.dart';
import 'package:fasolingo/views/apps/decouvrir/deco_page.dart';
import 'package:fasolingo/views/apps/decouvrir/intro_page.dart';
import 'package:fasolingo/views/apps/decouvrir/selection_langues_page.dart';
import 'package:fasolingo/views/apps/decouvrir/step_mascotte.dart';
import 'package:fasolingo/views/apps/home/dashboard_screen.dart';
import 'package:fasolingo/views/apps/home/home_page.dart';
import 'package:fasolingo/views/apps/profile/edit_profile.dart';
import 'package:fasolingo/views/apps/profile/profile.dart';
import 'package:fasolingo/views/apps/setting/settings_page.dart';
import 'package:fasolingo/views/apps/setting/widget/select_language.dart';
import 'package:fasolingo/views/auth/forget_password/enter_phone_number.dart';
import 'package:fasolingo/views/auth/forget_password/new_password.dart';
import 'package:fasolingo/views/auth/forget_password/otpcode.dart';
import 'package:fasolingo/views/auth/login.dart';
import 'package:fasolingo/views/auth/register.dart';
import 'package:fasolingo/views/splash.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'helpers/services/auth_services.dart';
import 'views/error_pages/coming_soon_page.dart';
import 'views/error_pages/error_404.dart';
import 'views/error_pages/error_500.dart';
import 'views/error_pages/maintenance_page.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (route == '/auth/login') {
      print("Autorisation route login");
      return null;
    }
    if (!AuthService.isLoggedIn) {
      print("Redirection forcée vers /auth/login");
      return const RouteSettings(name: '/auth/login');
    }
    print("Autorisation route protégée: $route");
    return null;
  }
}

getPageRoute() {
  var routes = [
    GetPage(name: '/dashboard', page: () => const HomePage()),
    GetPage(name: '/splash', page: () => const SplashCree()),
    GetPage(name: '/login', page: () => const LoginPage()),
    GetPage(name: '/dashboard', page: () => const HomePage()),
    GetPage(name: '/register', page: () => const RegisterPage()),
    GetPage(name: '/numberphone', page: () => const EnterPhonenumberPagge()),
    GetPage(name: '/otpCode', page: () => const OtpcodePage()),
    GetPage(name: '/newPassword', page: () => const NewPasswordPage()),
     GetPage(name: '/decouvrir', page: () => const DiscoveryPage()),
     GetPage(name: '/intro', page: () => const IntroPage()),
     GetPage(name: '/step', page: () => const StepMascotte()),
     GetPage(name: '/selection', page: () => const LanguageSelectionPage()),
     




    GetPage(name: '/settingScreen', page: () => SettingScreen()),
    GetPage(name: '/HomeScreen', page: () => HomeScreen()),
    GetPage(
        name: '/profile',
        page: () => const ProfilePage(),
        middlewares: [AuthMiddleware()]),
    GetPage(
        name: '/profileDetail',
        page: () => const ProfileDetails(),
        middlewares: [AuthMiddleware()]),

    GetPage(name: '/selectLanguageScreen', page: () => SelectLanguageScreen()),
    GetPage(name: '/changeLanguageScreen', page: () => ChangeLanguageScreen()),

    ///---------------- Auth ----------------///
    //GetPage(name: '/auth/login', page: () => const LoginPage()),

    ///---------------- Error ----------------///
    GetPage(
        name: '/coming-soon',
        page: () => const ComingSoonPage(),
        middlewares: [AuthMiddleware()]),
    GetPage(
        name: '/error-404',
        page: () => const Error404(),
        middlewares: [AuthMiddleware()]),
    GetPage(
        name: '/error-500',
        page: () => const Error500(),
        middlewares: [AuthMiddleware()]),
    GetPage(
        name: '/maintenance',
        page: () => const MaintenancePage(),
        middlewares: [AuthMiddleware()]),

    ///---------------- Maps ----------------///
  ];
  return routes
      .map(
        (e) => GetPage(
            name: e.name,
            page: e.page,
            middlewares: e.middlewares,
            transition: Transition.noTransition),
      )
      .toList();
}
