import 'package:fasolingo/views/apps/lexique/lexique_page.dart';
import 'package:fasolingo/views/apps/progres/progres_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../helpers/utils/ui_mixins.dart';
import '../../../widgets/bottom_bar/bottom_nav_bar.dart';
import '../../../widgets/bottom_bar/navigation_provider.dart';
import '../setting/settings_page.dart';
import 'dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin, UIMixin {
  @override
  Widget build(BuildContext context) {
    final navigationProvider = context.watch<NavigationProvider>();

    final List<Widget> screens = [
      HomePage(),
      LexiquePage(),
      ProgresPage(),
      SettingScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: navigationProvider.currentIndex,
        children: screens,
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: navigationProvider.currentIndex,
        onTabChange: (index) => navigationProvider.setCurrentIndex(index),
      ),
    );
  }
}
