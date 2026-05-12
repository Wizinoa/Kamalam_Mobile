// models/set_target_model.dart

class SetTargetModel {

  final String assetType;
  final double targetAmount;
  final double targetWeight;
  final int durationMonths;

  SetTargetModel({
    required this.assetType,
    required this.targetAmount,
    required this.targetWeight,
    required this.durationMonths,
  });

  Map<String, dynamic> toJson() {
    return {
      "assetType": assetType.toLowerCase(),
      "targetAmount": targetAmount,
      "targetWeight": targetWeight,
      "durationMonths": durationMonths,
    };
  }
}