class PassbookModels {
  final String savingsId;
  final String userSavingsId;
  final String schemeName;
  final String allocatedId;
  final String schemeType;
  final String schemeTypeLabel;
  final String assetType;
  final String? purity;
  final String? purityLabel;
  final String assetLabel;
  final int durationMonths;
  final double averageRate;
  final double totalSavedAmount;
  final double savedWeight;
  final double benefitEarned;
  final double rewardsEarned;
  final double totalGoldSaved;
  final DateTime? dateOfJoining;
  final DateTime? maturityDate;
  final int? remainingMonths;
  final int? remainingDays;
  final bool isMatured;
  final double targetAmount;
  final double targetAchievedPercentage;
  final double remainingAmount;
  final String status;

  const PassbookModels({
    required this.savingsId,
    required this.userSavingsId,
    required this.schemeName,
    required this.allocatedId,
    required this.schemeType,
    required this.schemeTypeLabel,
    required this.assetType,
    required this.purity,
    required this.purityLabel,
    required this.assetLabel,
    required this.durationMonths,
    required this.averageRate,
    required this.totalSavedAmount,
    required this.savedWeight,
    required this.benefitEarned,
    required this.rewardsEarned,
    required this.totalGoldSaved,
    required this.dateOfJoining,
    required this.maturityDate,
    required this.remainingMonths,
    required this.remainingDays,
    required this.isMatured,
    required this.targetAmount,
    required this.targetAchievedPercentage,
    required this.remainingAmount,
    required this.status,
  });

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  static int? _toNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static DateTime? _toDate(dynamic value) {
    if (value == null || value.toString().isEmpty) return null;
    return DateTime.tryParse(value.toString());
  }

  factory PassbookModels.fromJson(Map<String, dynamic> json) {
    return PassbookModels(
      savingsId: json['savingsId']?.toString() ?? '',
      userSavingsId: json['userSavingsId']?.toString() ?? '',
      schemeName: json['schemeName']?.toString() ?? '',
      allocatedId: json['allocatedId']?.toString() ?? '',
      schemeType: json['schemeType']?.toString().toLowerCase() ?? '',
      schemeTypeLabel: json['schemeTypeLabel']?.toString() ?? '',
      assetType: json['assetType']?.toString() ?? '',
      purity: json['purity']?.toString(),
      purityLabel: json['purityLabel']?.toString(),
      assetLabel: json['assetLabel']?.toString() ?? '',
      durationMonths: _toInt(json['durationMonths']),
      averageRate: _toDouble(json['averageRate']),
      totalSavedAmount: _toDouble(json['totalSavedAmount']),
      savedWeight: _toDouble(json['savedWeight']),
      benefitEarned: _toDouble(json['benefitEarned']),
      rewardsEarned: _toDouble(json['rewardsEarned']),
      totalGoldSaved: _toDouble(json['totalGoldSaved']),
      dateOfJoining: _toDate(json['dateOfJoining']),
      maturityDate: _toDate(json['maturityDate']),
      remainingMonths: _toNullableInt(json['remainingMonths']),
      remainingDays: _toNullableInt(json['remainingDays']),
      isMatured: json['isMatured'] == true,
      targetAmount: _toDouble(json['targetAmount']),
      targetAchievedPercentage: _toDouble(json['targetAchievedPercentage']),
      remainingAmount: _toDouble(json['remainingAmount']),
      status: json['status']?.toString() ?? '',
    );
  }
}
