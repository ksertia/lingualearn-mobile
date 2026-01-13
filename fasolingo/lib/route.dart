import 'package:fasolingo/views/app/home/dashboard.dart';
import 'package:fasolingo/views/app/home/esaai.dart';
import 'package:fasolingo/views/auth/forget_password/enter_phone_number.dart';
import 'package:fasolingo/views/auth/forget_password/new_password.dart';
import 'package:fasolingo/views/auth/forget_password/otpcode.dart';
import 'package:fasolingo/views/auth/login.dart';
import 'package:fasolingo/views/auth/register.dart';
import 'package:fasolingo/views/splash.dart';
import 'package:get/get.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String register = '/register';
  static const String numberphone = '/numberphone';
  static const String otpCode = '/otpCode';
  static const String newPassword = '/newPassword';
  static const String essaipage = '/essaipage';
  // 2. La liste des pages (GetPage)
  static List<GetPage> routes = [
    GetPage(
      name: splash,
      page: () => const SplashCree(), 
    ),
    GetPage(
      name: login,
      page: () => const LoginPage(), 
    ),
    GetPage(
      name: dashboard,
      page: () => const HomePage(), 
    ),
        GetPage(
      name: register,
      page: () => const RegisterPage(), 
    ),
       GetPage(
      name: numberphone,
      page: () => const EnterPhonenumberPagge(), 
    ),
      GetPage(
      name: otpCode,
      page: () => const OtpcodePage(), 
    ),
          GetPage(
      name: newPassword,
      page: () => const NewPasswordPage(), 
    ),
      GetPage(
      name: essaipage,
      page: () => const EsaaiPage(), 
    ),
  ];
}