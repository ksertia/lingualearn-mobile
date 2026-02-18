import 'package:flutter/foundation.dart';

class NavigationProvider with ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void goToDashboard() => setCurrentIndex(0);
  void goToLexique() => setCurrentIndex(1);
  void goToProgres() => setCurrentIndex(2);
  void goToSettings() => setCurrentIndex(3);
  
  /// Réinitialise l'index de navigation à 0 (accueil/dashboard)
  void resetIndex() {
    _currentIndex = 0;
    notifyListeners();
  }
}
