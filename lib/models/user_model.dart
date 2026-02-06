class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String? username;
  final String accountType;
  final String? parentId;
  
  // Champs de session (Langue et Niveau)
  final String? selectedLanguageId;
  final String? selectedLevelId;

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
  });

  // Pour mettre à jour l'utilisateur localement après un choix de langue
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
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // 1. On cible la partie 'user' car le JSON global contient 'user' et 'currentLanguage'
    final userData = json['user'] ?? json;
    final profileData = userData['profile'] ?? {};
    
    // 2. Logique pour extraire le niveau actif (celui qui a un progrès commencé)
    String? foundLevelId;
    final currentLang = json['currentLanguage'];
    
    if (currentLang != null && currentLang['levels'] != null) {
      final levels = currentLang['levels'] as List;
      // On cherche le niveau où userProgress n'est pas vide
      final activeLevel = levels.firstWhere(
        (l) => (l['userProgress'] as List).isNotEmpty,
        orElse: () => null,
      );
      foundLevelId = activeLevel?['id'];
    }

    return UserModel(
      id: userData['id'] ?? "",
      firstName: profileData['firstName'] ?? userData['username'] ?? "Utilisateur",
      lastName: profileData['lastName'] ?? "",
      email: userData['email'] ?? "",
      phone: userData['phone'] ?? "",
      username: userData['username'],
      accountType: userData['accountType'] ?? "learner",
      parentId: userData['parentId'],
      
      // Récupération depuis la structure du backend reçue précédemment
      selectedLanguageId: currentLang?['id'], 
      selectedLevelId: foundLevelId,
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