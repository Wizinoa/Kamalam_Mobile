// ─────────────────────────────────────────────────────────────
//  set_target_models.dart
// ─────────────────────────────────────────────────────────────

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

  Map<String, dynamic> toJson() => {
        'assetType': assetType.toLowerCase(),
        'targetAmount': targetAmount,
        'targetWeight': targetWeight,
        'durationMonths': durationMonths,
      };
}

// ── GET /savings/targets/:assetType response ──────────────────
class SavingsTargetResponse {
  final bool success;
  final SavingsTargetData? target;

  SavingsTargetResponse({required this.success, this.target});

  factory SavingsTargetResponse.fromJson(Map<String, dynamic> json) {
    return SavingsTargetResponse(
      success: json['success'] ?? false,
      // API may return target under 'target' or 'data'
      target: json['target'] != null
          ? SavingsTargetData.fromJson(json['target'])
          : json['data'] != null
              ? SavingsTargetData.fromJson(json['data'])
              : null,
    );
  }
}

class SavingsTargetData {
  final String id;
  final String assetType;
  final double targetAmount;
  final double targetWeight;
  final int durationMonths;
  final double savedAmount;
  final double savedWeight;
  final double achievedPercentage;
  final String status; // 'active' | 'completed' | etc.
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SavingsTargetData({
    required this.id,
    required this.assetType,
    required this.targetAmount,
    required this.targetWeight,
    required this.durationMonths,
    required this.savedAmount,
    required this.savedWeight,
    required this.achievedPercentage,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  bool get isGold => assetType.toLowerCase() == 'gold';
  String get metalLabel => isGold ? 'Gold' : 'Silver';
  String get purityLabel => isGold ? '22KT' : '999';

  factory SavingsTargetData.fromJson(Map<String, dynamic> json) {
    return SavingsTargetData(
      id: json['_id'] ?? '',
      assetType: json['assetType'] ?? '',
      targetAmount: (json['targetAmount'] ?? 0).toDouble(),
      targetWeight: (json['targetWeight'] ?? 0).toDouble(),
      durationMonths: (json['durationMonths'] ?? json['duration'] ?? 0),
      savedAmount: (json['savedAmount'] ?? json['totalSavedAmount'] ?? 0).toDouble(),
      savedWeight: (json['savedWeight'] ?? json['totalGoldAccumulated'] ?? 0).toDouble(),
      achievedPercentage:
          (json['achievedPercentage'] ?? json['targetAchievedPercentage'] ?? 0)
              .toDouble(),
      status: json['status'] ?? 'active',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }
}