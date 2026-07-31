class ReferralData {
  final String referralCode;
  final int totalFilleuls;
  final int totalRewarded;
  final int totalXpEarned;
  final int totalCoinsEarned;
  final List<FilleulModel> filleuls;

  ReferralData({
    required this.referralCode,
    required this.totalFilleuls,
    required this.totalRewarded,
    required this.totalXpEarned,
    required this.totalCoinsEarned,
    required this.filleuls,
  });

  factory ReferralData.fromJson(Map<String, dynamic> json) {
    return ReferralData(
      referralCode: json['referralCode']?.toString() ?? '',
      totalFilleuls: (json['totalFilleuls'] as num?)?.toInt() ?? 0,
      totalRewarded: (json['totalRewarded'] as num?)?.toInt() ?? 0,
      totalXpEarned: (json['totalXpEarned'] as num?)?.toInt() ?? 0,
      totalCoinsEarned: (json['totalCoinsEarned'] as num?)?.toInt() ?? 0,
      filleuls: json['filleuls'] is List
          ? (json['filleuls'] as List)
              .map((f) =>
                  FilleulModel.fromJson(Map<String, dynamic>.from(f as Map)))
              .toList()
          : [],
    );
  }
}

class FilleulModel {
  final String username;
  final String firstName;
  final String status;
  final DateTime? joinedAt;
  final DateTime? rewardedAt;

  FilleulModel({
    required this.username,
    required this.firstName,
    required this.status,
    this.joinedAt,
    this.rewardedAt,
  });

  bool get isRewarded {
    final s = status.toLowerCase();
    return s == 'rewarded' || s == 'completed';
  }

  String get displayName => firstName.isNotEmpty ? firstName : username;

  factory FilleulModel.fromJson(Map<String, dynamic> json) {
    return FilleulModel(
      username: json['username']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      joinedAt: DateTime.tryParse(json['joinedAt']?.toString() ?? ''),
      rewardedAt: DateTime.tryParse(json['rewardedAt']?.toString() ?? ''),
    );
  }
}
