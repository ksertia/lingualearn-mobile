import 'package:fasolingo/views/apps/change_language.dart';
import 'package:fasolingo/views/apps/decouvrir/bienvenu_page.dart';
import 'package:fasolingo/views/apps/decouvrir/choisie_niveau_page.dart';
import 'package:fasolingo/views/apps/decouvrir/deco_page.dart';
import 'package:fasolingo/views/apps/decouvrir/intro_page.dart';
import 'package:fasolingo/views/apps/decouvrir/selection_langues_page.dart';
import 'package:fasolingo/views/apps/decouvrir/step_mascotte.dart';
import 'package:fasolingo/views/apps/home/dashboard_screen.dart';
import 'package:fasolingo/views/apps/home/home_page.dart';
import 'package:fasolingo/views/apps/home/parcours_page.dart';
//import 'package:fasolingo/views/apps/home/screens/Detaillepage.dart';
//import 'package:fasolingo/views/apps/home/screens/Etapes2.dart';
//import 'package:fasolingo/views/apps/home/screens/Revision.dart';
import 'package:fasolingo/views/apps/home/screens/lesson_selection_screen.dart';
import 'package:fasolingo/views/apps/home/screens/parcours.dart';
import 'package:fasolingo/views/apps/home/screens/stepsscreens.dart';

import 'package:fasolingo/views/apps/lexique/lexique_page.dart';

import 'package:fasolingo/views/apps/profile/edit_profile.dart';
import 'package:fasolingo/views/apps/profile/profile.dart';
import 'package:fasolingo/views/apps/progres/progres_page.dart';
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
    GetPage(name: '/dashboard', page: () =>  HomePage()),
    GetPage(name: '/splash', page: () => const SplashCree()),
    GetPage(name: '/login', page: () => const LoginPage()),
    GetPage(name: '/register', page: () => const RegisterPage()),
    GetPage(name: '/numberphone', page: () => const EnterPhonenumberPagge()),
    GetPage(name: '/otpCode', page: () => const OtpcodePage()),
    GetPage(name: '/newPassword', page: () => const NewPasswordPage()),
    // GetPage(name: '/parcours', page: () =>  ParcoursPage()),
     GetPage(name: '/decouvrir', page: () => const DiscoveryPage()),
     GetPage(name: '/intro', page: () => const IntroPage()),
     GetPage(name: '/step', page: () => const StepMascotte()),
     GetPage(name: '/selection', page: () => const LanguageSelectionPage()),

    GetPage(name: '/stepsscreens', page: () => const StepsScreensPages()),
    //GetPage(name: '/detaillepage', page: () => const DetaillePage()),
    //GetPage(name: '/etapes2pages', page: () => const Etapes2Pages()),
    GetPage(name: '/lessonselectionscreen', page: () => const LessonSelectionScreen()),
    //GetPage(name: '/lesson2', page: () => const DetaillePage()),
    GetPage(name: '/parcoursselectionpage', page: () =>  ParcoursSelectionPage()),
    //GetPage(name: '/parcoursselectionpage', page: () => const ParcoursSelectionPage()),





    GetPage(name: '/bienvenue', page: () => const BienvenuPage()),
     GetPage(name: '/niveau', page: () => const ChoisieNiveauPage()),






    GetPage(name: '/settingScreen', page: () => SettingScreen()),
    GetPage(name: '/HomeScreen', page: () => HomeScreen()),
        GetPage(name: '/lexique', page: () => LexiquePage()),
        GetPage(name: '/progres', page: () => ProgresPage()),
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
