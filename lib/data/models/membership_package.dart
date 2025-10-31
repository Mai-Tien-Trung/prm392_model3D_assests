class MembershipPackage {
  final int packageId;
  final String packageName;
  final String packageDescription;
  final double packagePrice;
  final int packageDurationDays;
  final String modelGenerationLimitDisplay;

  MembershipPackage({
    required this.packageId,
    required this.packageName,
    required this.packageDescription,
    required this.packagePrice,
    required this.packageDurationDays,
    required this.modelGenerationLimitDisplay,
  });

  factory MembershipPackage.fromJson(Map<String, dynamic> json) {
    return MembershipPackage(
      packageId: json['packageId'],
      packageName: json['packageName'],
      packageDescription: json['description'],
      packagePrice: json['price'],
      packageDurationDays: json['durationDays'],
      modelGenerationLimitDisplay: json['modelGenerationLimitDisplay'] ?? '',
    );
  }
}
