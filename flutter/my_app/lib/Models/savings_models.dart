class SavingsSummaryModel {
  final String userId;
  final String name;
  final String savingsId;
  final String status;

  final String assetType;
  final String schemeName;
  final String schemeId;
  final String purity;

  final double totalSavedAmount;
  final double totalGoldAccumulated;

  final double benefitEarned;
  final double rewardsEarned;
  final double totalGoldSaved;

  final double targetAmount;
  final double targetWeight;
  final double targetAchievedPercentage;

  final DateTime startDate;

  SavingsSummaryModel({
    required this.userId,
    required this.name,
    required this.savingsId,
    required this.status,
    required this.assetType,
    required this.schemeName,
    required this.schemeId,
    required this.purity,
    required this.totalSavedAmount,
    required this.totalGoldAccumulated,
    required this.benefitEarned,
    required this.rewardsEarned,
    required this.totalGoldSaved,
    required this.targetAmount,
    required this.targetWeight,
    required this.targetAchievedPercentage,
    required this.startDate,
  });

  factory SavingsSummaryModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return SavingsSummaryModel(
      userId: json["userId"] ?? "",

      name: json["name"] ?? "",

      savingsId: json["savingsId"] ?? "",

      status: json["status"] ?? "",

      assetType: json["assetType"] ?? "",

      schemeName: json["schemeName"] ?? "",

      schemeId: json["schemeId"] ?? "",

      purity: json["purity"] ?? "",

      totalSavedAmount:
          (json["totalSavedAmount"] ?? 0)
              .toDouble(),

      totalGoldAccumulated:
          (json["totalGoldAccumulated"] ?? 0)
              .toDouble(),

      benefitEarned:
          (json["benefitEarned"] ?? 0)
              .toDouble(),

      rewardsEarned:
          (json["rewardsEarned"] ?? 0)
              .toDouble(),

      totalGoldSaved:
          (json["totalGoldSaved"] ?? 0)
              .toDouble(),

      targetAmount:
          (json["targetAmount"] ?? 0)
              .toDouble(),

      targetWeight:
          (json["targetWeight"] ?? 0)
              .toDouble(),

      targetAchievedPercentage:
          (json[
                  "targetAchievedPercentage"] ??
              0)
              .toDouble(),

      startDate: DateTime.parse(
        json["startDate"],
      ),
    );
  }
}