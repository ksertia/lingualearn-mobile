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
  final userData = json['user'] ?? json;
  final profileData = userData['profile'] ?? {};
  
  final currentLang = json['currentLanguage'];
  
  String? foundLevelId;
  
  if (currentLang != null && currentLang['levels'] != null) {
    final levels = currentLang['levels'] as List;
    if (levels.isNotEmpty) {
      foundLevelId = levels[0]['id']; 
    }
  }

  return UserModel(
    id: userData['id'] ?? "",
    firstName: profileData['firstName'] ?? userData['username'] ?? "Apprenant",
    lastName: profileData['lastName'] ?? "",
    email: userData['email'] ?? "",
    phone: userData['phone'] ?? "",
    username: userData['username'],
    accountType: userData['accountType'] ?? "learner",
    parentId: userData['parentId'],
    
    selectedLanguageId: currentLang != null ? currentLang['id'] : null, 
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