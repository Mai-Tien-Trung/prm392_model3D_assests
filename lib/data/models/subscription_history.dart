class SubscriptionHistory {
  final int subscriptionId;
  final String packageName;
  final String packageDescription;
  final double packagePrice;
  final int packageDurationDays;
  final String status;
  final DateTime createdAt;

  SubscriptionHistory({
    required this.subscriptionId,
    required this.packageName,
    required this.packageDescription,
    required this.packagePrice,
    required this.packageDurationDays,
    required this.status,
    required this.createdAt,
  });

  factory SubscriptionHistory.fromJson(Map<String, dynamic> json) {
    return SubscriptionHistory(
      subscriptionId: json['subscriptionId'],
      packageName: json['packageName'],
      packageDescription: json['packageDescription'],
      packagePrice: json['packagePrice'],
      packageDurationDays: json['packageDurationDays'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
