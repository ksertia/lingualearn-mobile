import 'package:fasolingo/model/child_profile_model.dart';

class ChildModel {
  final String id;
  final String? username;
  final String? email;
  final String? phone;
  final bool? isActive;
  final bool? isVerified;
  final String? createdAt;
  final String? lastLogin;
  final String? lastActive;
  final ChildProfileModel? profile;

  const ChildModel({
    required this.id,
    this.username,
    this.email,
    this.phone,
    this.isActive,
    this.isVerified,
    this.createdAt,
    this.lastLogin,
    this.lastActive,
    this.profile,
  });

  factory ChildModel.fromJson(Map<String, dynamic> json) {
    final profileJson = json['profile'];
    return ChildModel(
      id: (json['id'] ?? '').toString(),
      username: json['username']?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      isActive: json['isActive'] as bool?,
      isVerified: json['isVerified'] as bool?,
      createdAt: json['createdAt']?.toString(),
      lastLogin: json['lastLogin']?.toString(),
      lastActive: json['lastActive']?.toString(),
      profile: profileJson is Map<String, dynamic>
          ? ChildProfileModel.fromJson(profileJson)
          : profileJson is Map
              ? ChildProfileModel.fromJson(
                  Map<String, dynamic>.from(profileJson),
                )
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'phone': phone,
      'isActive': isActive,
      'isVerified': isVerified,
      'createdAt': createdAt,
      'lastLogin': lastLogin,
      'lastActive': lastActive,
      'profile': profile?.toJson(),
    };
  }

  String get displayName {
    final name = profile?.fullName ?? '';
    return name.isNotEmpty ? name : (username ?? 'Sous-compte');
  }
}
