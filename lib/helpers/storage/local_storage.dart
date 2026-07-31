import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tibi/helpers/localizations/language.dart';
import 'package:tibi/helpers/services/auth_services.dart';
import 'package:tibi/helpers/theme/theme_customizer.dart';

class LocalStorage {
  static const String _loggedInUserKey = "user";
  static const String _themeCustomizerKey = "theme_customizer";
  static const String _languageKey = "lang_code";
  static const String _userIDKey = "user_id";
  static const String _userWalletIDKey = "user_wallet_id";
  static const String _userCurrencyIDKey = "user_currency_id";
  static const String _userCurrencyLabel = "user_currency_label";
  static const String _userWalletBalance = "user_wallet_balance";

  static const String _userNameKey = "user_name";
  static const String _authToken = "auth_token";
  static const String _refreshToken = "refresh_token";
  static const String _phoneNumber = "phone";
  static const String _email = "email";
  static const String _theme = "theme";
  static const String _setAppLink = "setAppLink";
  static const String _countryID = "countryID";
  static const String _appLinkPoolID = "appLinkID";
  static const String _password = "password";
  static const String _loggedIn = "loggedIn";
  static const String _notification = "notification";
  static const String _pendingLoginInfo = "pending_login_info";
  static const String _pendingLoginExpiry = "pending_login_expiry";

  // Durée pendant laquelle les identifiants saisis à l'inscription restent
  // proposés au pré-remplissage du formulaire de connexion.
  static const Duration pendingLoginTtl = Duration(minutes: 15);

  static const String _vientDeLaDecouverteKey = "vient_de_la_decouverte";
  static const String _selectedLevelIdKey = "selected_level_id";

  static const String _languageIndexKey =
      'app_language_index'; // New key for index

  static SharedPreferences? _preferencesInstance;

  static SharedPreferences get preferences {
    if (_preferencesInstance == null) {
      throw ("Call LocalStorage.init() to initialize local storage");
    }
    return _preferencesInstance!;
  }

  static Future<void> init() async {
    _preferencesInstance = await SharedPreferences.getInstance();
    await initData();
  }


// Dans ton fichier local_storage.dart

// Pour sauvegarder quand il commence la découverte
  static Future<bool> setVientDeLaDecouverte(bool value) async {
    return preferences.setBool(_vientDeLaDecouverteKey, value);
  }

  // Pour vérifier au moment du login
  static bool getVientDeLaDecouverte() {
    return preferences.getBool(_vientDeLaDecouverteKey) ?? false;
  }

  // Pour sauvegarder le niveau sélectionné
  static Future<bool> setSelectedLevelId(String levelId) async {
    return preferences.setString(_selectedLevelIdKey, levelId);
  }

  // Pour récupérer le niveau sélectionné
  static String? getSelectedLevelId() {
    return preferences.getString(_selectedLevelIdKey);
  }

  static Future<void> initData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    AuthService.isLoggedIn = preferences.getBool(_loggedInUserKey) ?? false;
    ThemeCustomizer.fromJSON(preferences.getString(_themeCustomizerKey));
  }

  // Method to save the selected language's index
  static Future<void> setLanguageIndex(int index) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_languageIndexKey, index);
  }

  // Method to get the saved language's index
  static Future<int?> getLanguageIndex() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_languageIndexKey);
  }

  static Future<bool> setLoggedInUser(bool loggedIn) async {
    return preferences.setBool(_loggedInUserKey, loggedIn);
  }

  static Future<bool> setCustomizer(ThemeCustomizer themeCustomizer) {
    return preferences.setString(_themeCustomizerKey, themeCustomizer.toJSON());
  }

  static Future<bool> setLanguage(Language language) {
    return preferences.setString(_languageKey, language.locale.languageCode);
  }

  static String? getLanguage() {
    return preferences.getString(_languageKey);
  }

  static Future<bool> setUserID(String userID) {
    return preferences.setString(_userIDKey, userID);
  }

  static String? getUserID() {
    return preferences.getString(_userIDKey);
  }

  static Future<bool> setUserWalletID(String userID) {
    return preferences.setString(_userWalletIDKey, userID);
  }

  static Future<bool> setUserWalletBalance(String balance) {
    return preferences.setString(_userWalletBalance, balance);
  }

  static String? getUserWalletID() {
    return preferences.getString(_userWalletIDKey);
  }

  static String? getUserWalletBalance() {
    return preferences.getString(_userWalletBalance);
  }

  static Future<bool> setUserCurrencyID(String currencyId) {
    return preferences.setString(_userCurrencyIDKey, currencyId);
  }

  static String? getUserCurrencyID() {
    return preferences.getString(_userCurrencyIDKey);
  }

  static Future<bool> setUserCurrencyLabel(String currencyLabel) {
    return preferences.setString(_userCurrencyIDKey, currencyLabel);
  }

  static String? getUserCurrencyLabel() {
    return preferences.getString(_userCurrencyLabel);
  }

  static Future<bool> setUserName(String userID) {
    return preferences.setString(_userNameKey, userID);
  }

  static String? getUserName() {
    return preferences.getString(_userNameKey);
  }

  static Future<bool> setEmail(String email) {
    return preferences.setString(_email, email);
  }

  static String? getEmail() {
    return preferences.getString(_email);
  }

  static Future<bool> setAuthToken(String token) {
    return preferences.setString(_authToken, token);
  }

  static String? getAuthToken() {
    return preferences.getString(_authToken);
  }

  static Future<bool> setRefreshToken(String token) {
    return preferences.setString(_refreshToken, token);
  }

  static String? getRefreshToken() {
    return preferences.getString(_refreshToken);
  }

  static Future<bool> setPhoneNumber(String phone) {
    return preferences.setString(_phoneNumber, phone);
  }

  static String? getPhoneNumber() {
    return preferences.getString(_phoneNumber);
  }

  static ValueNotifier<String> themeNotifier = ValueNotifier("Light");


  static Future<bool> setTheme(String theme) {
    return preferences.setString(_theme, theme);
  }

  static String? getTheme() {
    return preferences.getString(_theme);
  }

  static Future<bool> setAppLink(bool setValue) {
    return preferences.setBool(_setAppLink, setValue);
  }

  static bool isAppLink() {
    return preferences.getBool(_setAppLink) ?? false;
  }

  static Future<bool> setAppLinkStationID(String id) {
    return preferences.setString(_appLinkPoolID, id);
  }

  static String? getAppLinkStationID() {
    return preferences.getString(_appLinkPoolID);
  }

  static Future<bool> setCountryID(String id) {
    return preferences.setString(_countryID, id);
  }

  static String? getCountryID() {
    return preferences.getString(_countryID);
  }

  static Future<bool> setPassword(String password) {
    return preferences.setString(_password, password);
  }

  static String? getPassword() {
    return preferences.getString(_password);
  }

  static Future<bool> setAlwaysLoggedIn(bool value) {
    return preferences.setBool(_loggedIn, value);
  }

  static bool getAlwaysLoggedIn() {
    return preferences.getBool(_loggedIn) ?? false;
  }

  /// Mémorise temporairement les identifiants saisis à l'inscription pour
  /// pré-remplir le formulaire de connexion — évite à l'utilisateur de les
  /// ressaisir juste après avoir créé son compte.
  static Future<void> setPendingLoginCredentials(
      String loginInfo, String password) async {
    await preferences.setString(_pendingLoginInfo, loginInfo);
    await setPassword(password);
    await preferences.setInt(
      _pendingLoginExpiry,
      DateTime.now().add(pendingLoginTtl).millisecondsSinceEpoch,
    );
  }

  /// Renvoie les identifiants en attente s'ils existent et ne sont pas
  /// expirés, sinon `null` (et nettoie les valeurs périmées au passage).
  static ({String loginInfo, String password})? getPendingLoginCredentials() {
    final expiry = preferences.getInt(_pendingLoginExpiry);
    if (expiry == null || DateTime.now().millisecondsSinceEpoch > expiry) {
      clearPendingLoginCredentials();
      return null;
    }
    final loginInfo = preferences.getString(_pendingLoginInfo);
    final password = getPassword();
    if (loginInfo == null ||
        loginInfo.isEmpty ||
        password == null ||
        password.isEmpty) {
      return null;
    }
    return (loginInfo: loginInfo, password: password);
  }

  static Future<void> clearPendingLoginCredentials() async {
    await preferences.remove(_pendingLoginInfo);
    await preferences.remove(_password);
    await preferences.remove(_pendingLoginExpiry);
  }

  static Future<bool> setNotification(List<String> notification) {
    return preferences.setStringList(_notification, notification);
  }

  static List<String>? getNotification() {
    return preferences.getStringList(_notification);
  }

  static Future<void> removeLoggedInUser() async {
    preferences.remove(_loggedInUserKey);
    preferences.remove(_themeCustomizerKey);
    preferences.remove(_languageKey);
    preferences.remove(_userIDKey);
    preferences.remove(_authToken);
    preferences.remove(_refreshToken);
    preferences.remove(_loggedInUserKey);
    preferences.remove(_password);
  }

  static Future<bool> removeAllUserData() async {
    return preferences.clear();
  }
}
