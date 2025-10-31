class CurrentSubscription {
  final int subscriptionId;
  final String packageName;
  final String packageDescription;
  final double packagePrice;
  final int packageDurationDays;
  final String status;
  final DateTime startDate;
  final DateTime endDate;
  final int daysRemaining;

  CurrentSubscription({
    required this.subscriptionId,
    required this.packageName,
    required this.packageDescription,
    required this.packagePrice,
    required this.packageDurationDays,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.daysRemaining,
  });

  factory CurrentSubscription.fromJson(Map<String, dynamic> json) {
    return CurrentSubscription(
      subscriptionId: json['subscriptionId'] ?? 0,
      packageName: json['packageName'] ?? '',
      packageDescription: json['packageDescription'] ?? '',
      packagePrice: json['packagePrice'] ?? 0,
      packageDurationDays: json['packageDurationDays'] ?? 0,
      status: json['status'] ?? '',
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      daysRemaining: json['daysRemaining'] ?? 0,
    );
  }
}
