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
    print("📦 UserModel.fromJson - Données reçues: $json");
    
    // Les données utilisateur sont dans json['user']
    final userData = json['user'] ?? json;
    final profileData = userData['profile'] ?? {};
    
    // Récupération directe de selectedLanguageId et selectedLevelId depuis userData
    final String? selectedLanguageId = userData['selectedLanguageId']?.toString();
    final String? selectedLevelId = userData['selectedLevelId']?.toString();
    
    print("✅ Langue sélectionnée (from userData): $selectedLanguageId");
    print("✅ Niveau sélectionné (from userData): $selectedLevelId");
    
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