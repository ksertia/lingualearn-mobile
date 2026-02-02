class UserModel {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String? username; 
  final String accountType;
  final String? parentId; 

  UserModel({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.username,
    required this.accountType,
    this.parentId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      firstName: json['firstName'] ?? json['username'] ?? "Utilisateur",
      lastName: json['lastName'] ?? "",
      email: json['email'] ?? "",
      phone: json['phone'] ?? "",
      username: json['username'], 
      accountType: json['accountType'] ?? "learner",
      parentId: json['parentId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'username': username,
      'accountType': accountType,
      'parentId': parentId,
    };
  }
}