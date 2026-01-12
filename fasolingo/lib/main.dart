import 'package:fasolingo/route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Fasolingo',
      debugShowCheckedModeBanner: false,
      
      // Configuration des routes
      initialRoute: AppRoutes.splash, // On démarre sur le splash
      getPages: AppRoutes.routes,     
      
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
    );
  }
}