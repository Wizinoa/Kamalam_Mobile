class PassbookModels {
  final String savingsId;
  final String schemeName;
  final String allocatedId;
  final double averageRate;
  final double totalSavedAmount;
  final double savedWeight;
  final double benefitEarned;
  final double rewardsEarned;
  final double totalGoldSaved;
  final DateTime? dateOfJoining;
  final DateTime? maturityDate;
  final double targetAmount;
  final double targetAchievedPercentage;
  final double remainingAmount;
  final String status;
  final String assetType;



  PassbookModels({
    required this.savingsId,
    required this.schemeName,
    required this.allocatedId,
    required this.averageRate,
    required this.totalSavedAmount,
    required this.savedWeight,
    required this.benefitEarned,
    required this.rewardsEarned,
    required this.totalGoldSaved,
    required this.dateOfJoining,
    required this.maturityDate,
    required this.targetAmount,
    required this.targetAchievedPercentage,
    required this.remainingAmount,
    required this.status,
    required this.assetType,
  });

  factory PassbookModels.fromJson(Map<String, dynamic> json) {
    return PassbookModels(
      savingsId: json['savingsId'] ?? '',
      schemeName: json['schemeName'] ?? '',
      allocatedId: json['allocatedId'] ?? '',
      averageRate: (json['averageRate'] ?? 0).toDouble(),
      totalSavedAmount: (json['totalSavedAmount'] ?? 0).toDouble(),
      savedWeight: (json['savedWeight'] ?? 0).toDouble(),
      benefitEarned: (json['benefitEarned'] ?? 0).toDouble(),
      rewardsEarned: (json['rewardsEarned'] ?? 0).toDouble(),
      totalGoldSaved: (json['totalGoldSaved'] ?? 0).toDouble(),
      dateOfJoining: json['dateOfJoining'] != null
          ? DateTime.tryParse(json['dateOfJoining'])
          : null,
      maturityDate: json['maturityDate'] != null
          ? DateTime.tryParse(json['maturityDate'])
          : null,
      targetAmount: (json['targetAmount'] ?? 0).toDouble(),
      targetAchievedPercentage:
          (json['targetAchievedPercentage'] ?? 0).toDouble(),
      remainingAmount: (json['remainingAmount'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      assetType: json['assetType'] ?? '',
    );
  }
}