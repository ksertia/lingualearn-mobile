class ClientModel {
  final String id;
  final User userId;
  final String firstName;
  final String lastName;
  final String phone;
  final Address address;
  final String subscriptionStatus;
  final bool acceptTerms;
  final bool receiveOffers;
  final List<SubscriptionHistory> subscriptionHistory;
  final List<dynamic> paymentHistory;
  final List<dynamic> nonPassageReports;
  final String createdAt;
  final List<String> subscribedAgencyId;

  ClientModel({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.address,
    required this.subscriptionStatus,
    required this.acceptTerms,
    required this.receiveOffers,
    required this.subscriptionHistory,
    required this.paymentHistory,
    required this.nonPassageReports,
    required this.createdAt,
    required this.subscribedAgencyId,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    String subscriptionStatus = '';
    if (json['subscriptionHistory'] is List && (json['subscriptionHistory'] as List).isNotEmpty) {
      final lastSub = (json['subscriptionHistory'] as List).last;
      if (lastSub is Map<String, dynamic> && lastSub['status'] is String) {
        subscriptionStatus = lastSub['status'];
      }
    }

    return ClientModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId'] != null
          ? User.fromJson(json['userId'] as Map<String, dynamic>)
          : User.empty(),
      firstName: json['name'] ?? '',
      lastName: json['lastName'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] != null
          ? Address.fromJson(json['address'] as Map<String, dynamic>)
          : Address.empty(),
      subscriptionStatus: subscriptionStatus,
      acceptTerms: json['acceptTerms'] ?? false,
      receiveOffers: json['receiveOffers'] ?? false,
      subscriptionHistory: (json['subscriptionHistory'] != null && json['subscriptionHistory'] is List)
          ? (json['subscriptionHistory'] as List)
          .map((e) => SubscriptionHistory.fromJson(e as Map<String, dynamic>))
          .toList()
          : [],
      paymentHistory: (json['paymentHistory'] != null && json['paymentHistory'] is List)
          ? List<dynamic>.from(json['paymentHistory'])
          : [],
      nonPassageReports: (json['nonPassageReports'] != null && json['nonPassageReports'] is List)
          ? List<dynamic>.from(json['nonPassageReports'])
          : [],
      createdAt: json['createdAt'] ?? '',
      subscribedAgencyId: json['subscribedAgencyId'] != null && json['subscribedAgencyId'] is List
          ? List<String>.from(json['subscribedAgencyId'])
          : [],
    );
  }
}


class User {
  final String id;
  final String email;
  final String role;
  final bool isActive;
  final String createdAt;

  User({
    required this.id,
    required this.email,
    required this.role,
    required this.isActive,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id']?.toString() ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      isActive: json['isActive'] ?? false,
      createdAt: json['createdAt'] ?? '',
    );
  }

  factory User.empty() {
    return User(
      id: '',
      email: '',
      role: '',
      isActive: false,
      createdAt: '',
    );
  }
}

class Address {
  final String street;
  final String doorNumber;
  final String doorColor;
  final String arrondissement;
  final String sector;
  final String neighborhood;
  final String city;
  final String postalCode;
  final double? latitude;
  final double? longitude;

  Address({
    required this.street,
    required this.doorNumber,
    required this.doorColor,
    required this.arrondissement,
    required this.sector,
    required this.neighborhood,
    required this.city,
    required this.postalCode,
    this.latitude,
    this.longitude,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      street: json['street'] ?? '',
      doorNumber: json['doorNumber'] ?? '',
      doorColor: json['doorColor'] ?? '',
      arrondissement: json['arrondissement'] ?? '',
      sector: json['sector'] ?? '',
      neighborhood: json['neighborhood'] ?? '',
      city: json['city'] ?? '',
      postalCode: json['postalCode'] ?? '',
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
    );
  }

  factory Address.empty() {
    return Address(
      street: '',
      doorNumber: '',
      doorColor: '',
      arrondissement: '',
      sector: '',
      neighborhood: '',
      city: '',
      postalCode: '',
      latitude: null,
      longitude: null,
    );
  }
}

class SubscriptionHistory {
  final String date;
  final String status;
  final String offer;
  final String id;

  SubscriptionHistory({
    required this.date,
    required this.status,
    required this.offer,
    required this.id,
  });

  factory SubscriptionHistory.fromJson(Map<String, dynamic> json) {
    return SubscriptionHistory(
      date: json['date'] ?? '',
      status: json['status'] ?? '',
      offer: json['offer'] ?? '',
      id: json['_id']?.toString() ?? '',
    );
  }
}
