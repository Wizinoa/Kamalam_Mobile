class SavingsHistoryResponse {
  final bool success;
  final SavingsSummary summary;
  final int transactionCount;
  final List<SavingsTransaction> data;

  SavingsHistoryResponse({
    required this.success,
    required this.summary,
    required this.transactionCount,
    required this.data,
  });

  factory SavingsHistoryResponse.fromJson(Map<String, dynamic> json) {
    return SavingsHistoryResponse(
      success: json['success'] ?? false,
      summary: SavingsSummary.fromJson(json['summary'] ?? {}),
      transactionCount: json['transactionCount'] ?? 0,
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => SavingsTransaction.fromJson(e))
          .toList(),
    );
  }
}

class SavingsSummary {
  final String assetType;
  final double targetAmount;
  final double targetWeight;
  final double totalSavedAmount;
  final double totalGoldAccumulated;
  final double remainingAmount;
  final double targetAchievedPercentage;

  SavingsSummary({
    required this.assetType,
    required this.targetAmount,
    required this.targetWeight,
    required this.totalSavedAmount,
    required this.totalGoldAccumulated,
    required this.remainingAmount,
    required this.targetAchievedPercentage,
  });

  factory SavingsSummary.fromJson(Map<String, dynamic> json) {
    return SavingsSummary(
      assetType: json['assetType'] ?? '',
      targetAmount: (json['targetAmount'] ?? 0).toDouble(),
      targetWeight: (json['targetWeight'] ?? 0).toDouble(),
      totalSavedAmount: (json['totalSavedAmount'] ?? 0).toDouble(),
      totalGoldAccumulated:
          (json['totalGoldAccumulated'] ?? 0).toDouble(),
      remainingAmount: (json['remainingAmount'] ?? 0).toDouble(),
      targetAchievedPercentage:
          (json['targetAchievedPercentage'] ?? 0).toDouble(),
    );
  }
}

class SavingsTransaction {
  final String id;
  final String schemeId;
  final double amount;
  final double grams;
  final String paymentMethod;
  final String paymentStatus;
  final DateTime createdAt;
  final String transactionId;

  SavingsTransaction({
    required this.id,
    required this.schemeId,
    required this.amount,
    required this.grams,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.createdAt,
    required this.transactionId,
  });

  factory SavingsTransaction.fromJson(Map<String, dynamic> json) {
    return SavingsTransaction(
      id: json['_id'] ?? '',
      schemeId: json['schemeId'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      grams: (json['grams'] ?? 0).toDouble(),
      paymentMethod: json['paymentMethod'] ?? '',
      paymentStatus: json['paymentStatus'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      transactionId: json['transactionId'] ?? '',
    );
  }
}