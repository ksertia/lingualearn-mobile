class PlanModel {
  final String id;
  final String planCode;
  final String planName;
  final String description;
  final String priceMonthly;
  final String priceYearly;
  final String? reducePrice; // Nullable
  final String? percentage;  // Nullable
  final String currency;
  final Map<String, dynamic> features;
  final int maxSubAccounts;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int subscriptionCount;

  PlanModel({
    required this.id,
    required this.planCode,
    required this.planName,
    required this.description,
    required this.priceMonthly,
    required this.priceYearly,
    this.reducePrice,
    this.percentage,
    required this.currency,
    required this.features,
    required this.maxSubAccounts,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.subscriptionCount,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      id: json['id'] ?? '',
      planCode: json['planCode'] ?? '',
      planName: json['planName'] ?? '',
      description: json['description'] ?? '',
      // On convertit en String au cas où le serveur renvoie un num
      priceMonthly: json['priceMonthly']?.toString() ?? '0',
      priceYearly: json['priceYearly']?.toString() ?? '0',
      reducePrice: json['reducePrice']?.toString(),
      percentage: json['percentage']?.toString(),
      currency: json['currency'] ?? 'XOF',
      features: json['features'] ?? {},
      maxSubAccounts: json['maxSubAccounts'] ?? 1,
      isActive: json['isActive'] ?? false,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : DateTime.now(),
      // Extraction du champ imbriqué _count.subscriptions
      subscriptionCount: json['_count']?['subscriptions'] ?? 0,
    );
  }

  // Méthode pour transformer l'objet en Map (utile pour le debug ou l'envoi au serveur)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'planCode': planCode,
      'planName': planName,
      'description': description,
      'priceMonthly': priceMonthly,
      'priceYearly': priceYearly,
      'reducePrice': reducePrice,
      'percentage': percentage,
      'currency': currency,
      'features': features,
      'maxSubAccounts': maxSubAccounts,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '_count': {'subscriptions': subscriptionCount},
    };
  }
}