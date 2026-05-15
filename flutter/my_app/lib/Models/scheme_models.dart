class SchemeModel {
  final String id;
  final String assetType;
  final String name;
  final String description;
  final int durationDays;
  final int minDailyDeposit;
  final int maxDailyDeposit;
  final int minTotalDeposit;
  final int lockInPeriod;
  final bool isActive;
  

  SchemeModel({
    required this.id,
    required this.assetType,
    required this.name,
    required this.description,
    required this.durationDays,
    required this.minDailyDeposit,
    required this.maxDailyDeposit,
    required this.minTotalDeposit,
    required this.lockInPeriod,
    required this.isActive,
  });

  factory SchemeModel.fromJson(Map<String, dynamic> json) {
    return SchemeModel(
      id: json['_id'] ?? '',
      assetType: json['assetType'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      durationDays: json['durationDays'] ?? 0,
      minDailyDeposit: json['minDailyDeposit'] ?? 0,
      maxDailyDeposit: json['maxDailyDeposit'] ?? 0,
      minTotalDeposit: json['minTotalDeposit'] ?? 0,
      lockInPeriod: json['lockInPeriod'] ?? 0,
      isActive: json['isActive'] ?? false,
    );
  }
}