import 'package:flutter/foundation.dart';

class AppState extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _username = '';
  int _currentTabIndex = 0;
  bool _notifications = true;
  bool _darkMode = false;
  bool _locationSharing = true;

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  String get username => _username;
  int get currentTabIndex => _currentTabIndex;
  bool get notifications => _notifications;
  bool get darkMode => _darkMode;
  bool get locationSharing => _locationSharing;

  // Login/Logout
  void login(String username) {
    _username = username;
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    _username = '';
    _isLoggedIn = false;
    _currentTabIndex = 0;
    notifyListeners();
  }

  // Tab Navigation
  void setCurrentTab(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

  // Settings
  void setNotifications(bool value) {
    _notifications = value;
    notifyListeners();
  }

  void setDarkMode(bool value) {
    _darkMode = value;
    notifyListeners();
  }

  void setLocationSharing(bool value) {
    _locationSharing = value;
    notifyListeners();
  }
}

// Models for data
class Collection {
  final String id;
  final String client;
  final String address;
  final String type;
  final String time;
  final String status;
  final String priority;

  Collection({
    required this.id,
    required this.client,
    required this.address,
    required this.type,
    required this.time,
    required this.status,
    required this.priority,
  });
}

class QRData {
  final String type;
  final String client;
  final String address;
  final String collectionType;
  final String scheduledTime;
  final String pointId;
  final String instructions;

  QRData({
    required this.type,
    required this.client,
    required this.address,
    required this.collectionType,
    required this.scheduledTime,
    required this.pointId,
    required this.instructions,
  });
}


