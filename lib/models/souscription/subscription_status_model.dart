class SubscriptionPlanModel {
  final String id;
  final String planCode;
  final String planName;
  final String description;
  final String priceMonthly;
  final String priceYearly;
  final String? reducePrice;
  final String? percentage;
  final String currency;
  final int maxSubAccounts;
  final bool isActive;
  final DateTime createdAt;

  SubscriptionPlanModel({
    required this.id,
    required this.planCode,
    required this.planName,
    required this.description,
    required this.priceMonthly,
    required this.priceYearly,
    this.reducePrice,
    this.percentage,
    required this.currency,
    required this.maxSubAccounts,
    required this.isActive,
    required this.createdAt,
  });

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanModel(
      id: json['id']?.toString() ?? '',
      planCode: json['planCode']?.toString() ?? '',
      planName: json['planName']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      priceMonthly: json['priceMonthly']?.toString() ?? '0',
      priceYearly: json['priceYearly']?.toString() ?? '0',
      reducePrice: json['reducePrice']?.toString(),
      percentage: json['percentage']?.toString(),
      currency: json['currency']?.toString() ?? 'XOF',
      maxSubAccounts: json['maxSubAccounts'] is int
          ? json['maxSubAccounts']
          : int.tryParse(json['maxSubAccounts']?.toString() ?? '0') ?? 0,
      isActive: json['isActive'] == true,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

class SubscriptionModel {
  final String id;
  final String userId;
  final String planId;
  final String status;
  final String billingCycle;
  final DateTime currentPeriodStart;
  final DateTime currentPeriodEnd;
  final bool cancelAtPeriodEnd;
  final DateTime? canceledAt;
  final DateTime createdAt;
  final SubscriptionPlanModel? plan;

  SubscriptionModel({
    required this.id,
    required this.userId,
    required this.planId,
    required this.status,
    required this.billingCycle,
    required this.currentPeriodStart,
    required this.currentPeriodEnd,
    required this.cancelAtPeriodEnd,
    this.canceledAt,
    required this.createdAt,
    this.plan,
  });

  bool get isActive => status.toLowerCase() == 'active';

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    final planJson = json['plan'];
    return SubscriptionModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      planId: json['planId']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      billingCycle: json['billingCycle']?.toString() ?? '',
      currentPeriodStart:
          DateTime.tryParse(json['currentPeriodStart']?.toString() ?? '') ??
              DateTime.now(),
      currentPeriodEnd:
          DateTime.tryParse(json['currentPeriodEnd']?.toString() ?? '') ??
              DateTime.now(),
      cancelAtPeriodEnd: json['cancelAtPeriodEnd'] == true,
      canceledAt:
          DateTime.tryParse(json['canceledAt']?.toString() ?? ''),
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
              DateTime.now(),
      plan: planJson is Map
          ? SubscriptionPlanModel.fromJson(
              Map<String, dynamic>.from(planJson))
          : null,
    );
  }
}

class SubscriptionStatusModel {
  final bool hasSubscription;
  final bool isActive;
  final SubscriptionModel? subscription;
  final DateTime? expiresAt;

  SubscriptionStatusModel({
    required this.hasSubscription,
    required this.isActive,
    this.subscription,
    this.expiresAt,
  });

  factory SubscriptionStatusModel.fromJson(Map<String, dynamic> json) {
    final subJson = json['subscription'];
    return SubscriptionStatusModel(
      hasSubscription: json['hasSubscription'] == true,
      isActive: json['isActive'] == true,
      subscription: subJson is Map
          ? SubscriptionModel.fromJson(Map<String, dynamic>.from(subJson))
          : null,
      expiresAt: DateTime.tryParse(json['expiresAt']?.toString() ?? ''),
    );
  }
}
