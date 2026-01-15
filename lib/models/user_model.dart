class UserModel {
  final String role;
  final String firstName;
  final String lastName;
  final String? createdAt;
  final String email;
  final String phone;
  final Address? address;

  UserModel(
      {required this.role,
      required this.firstName,
      required this.lastName,
      required this.email,
      required this.phone,
        this.createdAt,
      this.address});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      role: json['role'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      createdAt: json['createdAt'],
      phone: json['phone'],
      address: json['address'] != null ? Address.fromJson(json['address']) : null,
    );
  }
}

class Address {
  final String street;
  final String doorNumber;
  final String doorColor;
  final String sector;
  final String neighborhood;
  final String city;
  final String postalCode;
  final String arrondissement;
  final double latitude;
  final double longitude;

  Address({
    required this.street,
    required this.doorNumber,
    required this.doorColor,
    required this.sector,
    required this.neighborhood,
    required this.city,
    required this.postalCode,
    required this.arrondissement,
    required this.latitude,
    required this.longitude,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      street: json['street'] ?? '',
      doorNumber: json['doorNumber'] ?? '',
      doorColor: json['doorColor'] ?? '',
      sector: json['sector'] ?? '',
      neighborhood: json['neighborhood'] ?? '',
      city: json['city'] ?? '',
      postalCode: json['postalCode'] ?? '',
      arrondissement: json['arrondissement'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
    );
  }
}
