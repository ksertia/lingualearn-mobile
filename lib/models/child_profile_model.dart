class ChildProfileModel {
  final String? firstName;
  final String? lastName;
  final String? avatarUrl;

  const ChildProfileModel({
    this.firstName,
    this.lastName,
    this.avatarUrl,
  });

  factory ChildProfileModel.fromJson(Map<String, dynamic> json) {
    return ChildProfileModel(
      firstName: json['firstName']?.toString(),
      lastName: json['lastName']?.toString(),
      avatarUrl: json['avatarUrl']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'avatarUrl': avatarUrl,
    };
  }

  String get fullName {
    final fn = (firstName ?? '').trim();
    final ln = (lastName ?? '').trim();
    final full = ('$fn $ln').trim();
    return full;
  }
}
