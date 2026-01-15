import 'package:flutter/foundation.dart';

class NavigationProvider with ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void goToDashboard() => setCurrentIndex(0);
  void goToMessages() => setCurrentIndex(1);
  void goToSettings() => setCurrentIndex(2);
}
