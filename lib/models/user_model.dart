/// Décode un pourcentage renvoyé par l'API. Certains endpoints (ex:
/// currentLanguageProgress.overallProgress) sérialisent un `Decimal` Prisma
/// non converti côté backend, sous la forme `{s: signe, e: exposant,
/// d: [chiffres]}` au lieu d'un nombre simple — `int.tryParse(value.toString())`
/// échoue silencieusement sur cette forme et retombe toujours à 0.
int _parsePercentage(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.round();
  if (value is String) return int.tryParse(value) ?? double.tryParse(value)?.round() ?? 0;
  if (value is Map) {
    final digits = value['d'];
    if (digits is List && digits.isNotEmpty) {
      final sign = (value['s'] is num && (value['s'] as num) < 0) ? -1 : 1;
      final magnitude = int.tryParse(digits.first.toString()) ?? 0;
      return sign * magnitude;
    }
  }
  return 0;
}

class CurrentStateInfo {
  final String? levelId;
  final String? levelName;
  final String? moduleId;
  final String? moduleTitle;
  final String? pathId;
  final String? pathTitle;
  final String? stepId;
  final String? stepTitle;
  final String? stepType;

  CurrentStateInfo({
    this.levelId,
    this.levelName,
    this.moduleId,
    this.moduleTitle,
    this.pathId,
    this.pathTitle,
    this.stepId,
    this.stepTitle,
    this.stepType,
  });

  factory CurrentStateInfo.fromJson(Map<String, dynamic> json) {
    final level = json['currentLevel'] is Map
        ? Map<String, dynamic>.from(json['currentLevel'] as Map)
        : null;
    final module = json['currentModule'] is Map
        ? Map<String, dynamic>.from(json['currentModule'] as Map)
        : null;
    final path = json['currentPath'] is Map
        ? Map<String, dynamic>.from(json['currentPath'] as Map)
        : null;
    final step = json['currentStep'] is Map
        ? Map<String, dynamic>.from(json['currentStep'] as Map)
        : null;

    return CurrentStateInfo(
      levelId: level?['id']?.toString(),
      levelName: level?['name']?.toString(),
      moduleId: module?['id']?.toString(),
      moduleTitle: module?['title']?.toString(),
      pathId: path?['id']?.toString(),
      pathTitle: path?['title']?.toString(),
      stepId: step?['id']?.toString(),
      stepTitle: step?['title']?.toString(),
      stepType: step?['stepType']?.toString(),
    );
  }
}

class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String? username;
  final String accountType;
  final String? parentId;
  final String? selectedLanguageId;
  final String? selectedLevelId;

  // Progression courante — repli utilisé quand /users/my-progress ne
  // renvoie encore rien pour ce compte (ex: langue sélectionnée mais pas
  // encore de module/étape entamé côté endpoint de progression dédié).
  final String? currentLanguageId;
  final String? currentLanguageName;
  final String? currentLanguageCode;
  final int currentLanguageProgressPercentage;
  final CurrentStateInfo? currentState;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.username,
    required this.accountType,
    this.parentId,
    this.selectedLanguageId,
    this.selectedLevelId,
    this.currentLanguageId,
    this.currentLanguageName,
    this.currentLanguageCode,
    this.currentLanguageProgressPercentage = 0,
    this.currentState,
  });

  UserModel copyWith({
    String? selectedLanguageId,
    String? selectedLevelId,
  }) {
    return UserModel(
      id: id,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      username: username,
      accountType: accountType,
      parentId: parentId,
      selectedLanguageId: selectedLanguageId ?? this.selectedLanguageId,
      selectedLevelId: selectedLevelId ?? this.selectedLevelId,
      currentLanguageId: currentLanguageId,
      currentLanguageName: currentLanguageName,
      currentLanguageCode: currentLanguageCode,
      currentLanguageProgressPercentage: currentLanguageProgressPercentage,
      currentState: currentState,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Les données utilisateur sont dans json['user'], mais currentLanguage/
    // currentLanguageProgress/currentState sont des champs frères de "user"
    // (pas nichés dedans) sur la réponse de /auth/profile et de login.
    final userData = json['user'] ?? json;
    final profileData = userData['profile'] ?? {};

    final String? selectedLanguageId = userData['selectedLanguageId']?.toString();
    final String? selectedLevelId = userData['selectedLevelId']?.toString();

    final currentLanguageJson = json['currentLanguage'];
    final currentLanguageProgressJson = json['currentLanguageProgress'];
    final currentStateJson = json['currentState'];

    return UserModel(
      id: userData['id']?.toString() ?? "",
      firstName: profileData['firstName'] ?? userData['firstName'] ?? "",
      lastName: profileData['lastName'] ?? userData['lastName'] ?? "",
      email: userData['email'] ?? "",
      phone: userData['phone'] ?? "",
      username: userData['username'],
      accountType: userData['accountType'] ?? "learner",
      parentId: userData['parentId']?.toString(),
      selectedLanguageId: selectedLanguageId,
      selectedLevelId: selectedLevelId,
      currentLanguageId: currentLanguageJson is Map
          ? currentLanguageJson['id']?.toString()
          : null,
      currentLanguageName: currentLanguageJson is Map
          ? currentLanguageJson['name']?.toString()
          : null,
      currentLanguageCode: currentLanguageJson is Map
          ? currentLanguageJson['code']?.toString()
          : null,
      currentLanguageProgressPercentage: currentLanguageProgressJson is Map
          ? _parsePercentage(currentLanguageProgressJson['overallProgress'])
          : 0,
      currentState: currentStateJson is Map
          ? CurrentStateInfo.fromJson(
              Map<String, dynamic>.from(currentStateJson))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'username': username,
      'accountType': accountType,
      'parentId': parentId,
      'selectedLanguageId': selectedLanguageId,
      'selectedLevelId': selectedLevelId,
    };
  }
}
