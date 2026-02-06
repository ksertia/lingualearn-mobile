import 'dart:async';
import 'dart:developer';
import 'package:fasolingo/controller/apps/session_controller.dart';
import 'package:fasolingo/routes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import 'package:url_strategy/url_strategy.dart';
import 'helpers/constant/app_constant.dart';
import 'helpers/localizations/app_localization_delegate.dart';
import 'helpers/localizations/language.dart';
import 'helpers/logger/logger.dart';
import 'helpers/remote/api_service.dart';
import 'helpers/remote/local_notification.dart';
import 'helpers/services/navigation_service.dart';
import 'helpers/storage/local_storage.dart';
import 'helpers/theme/admin_theme.dart';
import 'helpers/theme/app_notifier.dart';
import 'helpers/theme/app_style.dart';
import 'helpers/theme/theme_customizer.dart';

import 'widgets/bottom_bar/navigation_provider.dart';

Future<void> main() async {
  // 1. Indispensable pour l'asynchrone
  WidgetsFlutterBinding.ensureInitialized(); 
  
  // 2. Initialisation PRIORITAIRE du stockage (on attend que ce soit fini)
  await GetStorage.init();
  await LocalStorage.init(); 
  
  // 3. Configuration des outils système
  setPathUrlStrategy();
  initLogger();
  
  // 4. Initialisation des services dépendant du stockage
  APIService.initializeAPIService(
      devBaseUrl: AppConstant.baseURl, prodBaseUrl: AppConstant.baseURl);
  
  AppStyle.init();
  
  // Logs de vérification
  log("GetToken ${LocalStorage.getAuthToken()}");
  log("GetUserID ${LocalStorage.getUserID()}");

  // Gestion du thème au démarrage
  if (LocalStorage.getTheme() == "Dark") {
    LocalStorage.setTheme("Dark");
  } else {
    LocalStorage.setTheme("Light");
  }
  
  LocalStorage.setAppLink(false);
  
  // 5. Initialisation finale avant le lancement
  await ThemeCustomizer.init();
  
  // Injection du controller principal
  Get.put(SessionController());

  await SystemChrome.setPreferredOrientations(
    <DeviceOrientation>[
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ],
  );

  if (!kIsWeb) {
    LocalNotification().initialize();
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AppNotifier>(
          create: (context) => AppNotifier(),
        ),
        ChangeNotifierProvider<NavigationProvider>(
          create: (context) => NavigationProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppNotifier>(
      builder: (_, notifier, ___) {
        AdminTheme.setTheme(context);
        return ScreenUtilInit(
          designSize: kIsWeb ? const Size(1280, 832) : const Size(430, 932),
          child: GetMaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            defaultTransition: Transition.native,
            navigatorKey: NavigationService.navigatorKey,
            initialRoute: "/splash", // Ta page d'onboarding/splash
            themeMode: LocalStorage.getTheme() == "Dark"
                ? ThemeMode.dark
                : ThemeMode.light,
            getPages: getPageRoute(),
            builder: (_, child) {
              NavigationService.registerContext(_);
              return Directionality(
                textDirection: AppTheme.textDirection,
                child: child ?? Container(),
              );
            },
            localizationsDelegates: [
              AppLocalizationsDelegate(context),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: Language.getLocales(),
          ),
        );
      },
    );
  }
}