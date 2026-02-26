import 'package:fasolingo/views/Quiz/quiz_intro_screen.dart';
import 'package:fasolingo/views/apps/change_language.dart';
import 'package:fasolingo/views/apps/decouvrir/bienvenu_page.dart';
import 'package:fasolingo/views/apps/decouvrir/choisie_niveau_page.dart';
import 'package:fasolingo/views/apps/decouvrir/deco_page.dart';
import 'package:fasolingo/views/apps/decouvrir/intro_page.dart';
import 'package:fasolingo/views/apps/decouvrir/langue_decouvert.dart';
import 'package:fasolingo/views/apps/decouvrir/selection_langues_page.dart';
import 'package:fasolingo/views/apps/decouvrir/step_mascotte.dart';
import 'package:fasolingo/views/apps/home/dashboard_screen.dart';
import 'package:fasolingo/views/apps/home/home_page.dart';
import 'package:fasolingo/views/apps/home/parcours_page.dart';
import 'package:fasolingo/views/apps/home/screens/lesson_selection_screen.dart';
import 'package:fasolingo/views/apps/home/screens/parcours.dart';
import 'package:fasolingo/views/apps/home/screens/stepsscreens.dart';

import 'package:fasolingo/views/apps/lexique/lexique_page.dart';

import 'package:fasolingo/views/apps/profile/edit_profile.dart';
import 'package:fasolingo/views/apps/profile/profile.dart';
import 'package:fasolingo/views/apps/progres/progres_page.dart';
import 'package:fasolingo/views/apps/setting/settings_page.dart';
import 'package:fasolingo/views/apps/setting/widget/detail_subscription.dart';
import 'package:fasolingo/views/apps/setting/widget/select_language.dart';
import 'package:fasolingo/views/apps/setting/widget/subsciption_plan.dart';
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
import 'controller/apps/session_controller.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    // Les routes d'authentification sont toujours accessibles
    if (route == '/login' || route == '/register' || route == '/numberphone' || 
        route == '/otpCode' || route == '/newPassword' || route == '/splash') {
      print("✅ Autorisation route d'auth: $route");
      return null;
    }
    
    // Pour les autres routes, vérifier la session
    final session = Get.find<SessionController>();
    if (session.userId.value.isEmpty || session.token.value.isEmpty) {
      print("🚫 Redirection forcée vers /login (session vide)");
      return const RouteSettings(name: '/login');
    }
    print("✅ Autorisation route protégée: $route");
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
     GetPage(name: '/decouvrir', page: () => const DiscoveryPage()),
     GetPage(name: '/intro', page: () => const IntroPage()),
     GetPage(name: '/step', page: () => const StepMascotte()),
     GetPage(name: '/selection', page: () => const LanguageSelectionPage()),

    GetPage(name: '/stepsscreens', page: () => const StepsScreensPages()),
    GetPage(name: '/lessonselectionscreen', page: () => const LessonSelectionScreen()),
    GetPage(name: '/parcoursselectionpage', page: () =>  ParcoursSelectionPage()),
    GetPage(name: '/subscription_details', page: () =>  SubscriptionDetailsPage()),
    GetPage(name: '/subscription_plans', page: () =>  SubscriptionPlansPage()),
    GetPage(name: '/laguedecouvert', page: () =>  LanguageDcouvertPage()),


    GetPage(name: '/quiz_intro_screen', page: () => const QuizIntroScreen(),
    ),



    GetPage(name: '/bienvenue', page: () => const BienvenuPage()),
     GetPage(name: '/niveau', page: () => const ChoisieNiveauPage()),






    GetPage(
        name: '/settingScreen', 
        page: () => SettingScreen(),
        middlewares: [AuthMiddleware()]),
    GetPage(
        name: '/HomeScreen', 
        page: () => HomeScreen(),
        middlewares: [AuthMiddleware()]),
    GetPage(
        name: '/lexique', 
        page: () => LexiquePage(),
        middlewares: [AuthMiddleware()]),
    GetPage(
        name: '/progres', 
        page: () => ProgresPage(),
        middlewares: [AuthMiddleware()]),
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
