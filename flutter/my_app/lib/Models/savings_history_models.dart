// ─────────────────────────────────────────────────────────────
//  savings_history_models.dart
//  FIX: schemeId is a nested object in the API response,
//       not a plain string. We parse it properly here.
// ─────────────────────────────────────────────────────────────

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
          .map((e) => SavingsTransaction.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

// ── Summary ───────────────────────────────────────────────────
class SavingsSummary {
  final String assetType;
  final double targetAmount;
  final double targetWeight;
  final double totalSavedAmount;
  final double totalGoldAccumulated; // used for both gold & silver grams
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
      totalGoldAccumulated: (json['totalGoldAccumulated'] ?? 0).toDouble(),
      remainingAmount: (json['remainingAmount'] ?? 0).toDouble(),
      targetAchievedPercentage:
          (json['targetAchievedPercentage'] ?? 0).toDouble(),
    );
  }
}

// ── Scheme (nested inside each transaction) ───────────────────
class TransactionScheme {
  final String id;        // Mongo _id
  final String schemeId;  // human-readable e.g. "SCH--2026-0005"
  final String name;
  final String assetType; // "gold" | "silver"
  final String schemaType;
  final int durationDays;
  final int lockInPeriod;

  TransactionScheme({
    required this.id,
    required this.schemeId,
    required this.name,
    required this.assetType,
    required this.schemaType,
    required this.durationDays,
    required this.lockInPeriod,
  });

  factory TransactionScheme.fromJson(Map<String, dynamic> json) {
    return TransactionScheme(
      id: json['_id'] ?? '',
      schemeId: json['schemeId'] ?? '',
      name: json['name'] ?? '',
      assetType: json['assetType'] ?? '',
      schemaType: json['schema_type'] ?? '',
      durationDays: json['durationDays'] ?? 0,
      lockInPeriod: json['lockInPeriod'] ?? 0,
    );
  }

  /// Fallback when schemeId field arrives as a plain string (old records)
  factory TransactionScheme.fromString(String id) {
    return TransactionScheme(
      id: id,
      schemeId: id,
      name: '',
      assetType: '',
      schemaType: '',
      durationDays: 0,
      lockInPeriod: 0,
    );
  }
}

// ── User (nested inside each transaction) ─────────────────────
class TransactionUser {
  final String id;
  final String fullName;
  final String mobile;
  final String email;
  final String userId; // e.g. "DG-0002"

  TransactionUser({
    required this.id,
    required this.fullName,
    required this.mobile,
    required this.email,
    required this.userId,
  });

  factory TransactionUser.fromJson(Map<String, dynamic> json) {
    return TransactionUser(
      id: json['_id'] ?? '',
      fullName: json['fullName'] ?? '',
      mobile: json['mobile'] ?? '',
      email: json['email'] ?? '',
      userId: json['userId'] ?? '',
    );
  }

  factory TransactionUser.empty() => TransactionUser(
        id: '',
        fullName: '',
        mobile: '',
        email: '',
        userId: '',
      );
}

// ── Transaction ───────────────────────────────────────────────
class SavingsTransaction {
  final String id;
  final TransactionScheme scheme; // ✅ FIX: was String, now object
  final TransactionUser user;     // ✅ FIX: was absent, now parsed
  final double amount;
  final double grams;
  final String paymentMethod;
  final String paymentStatus;
  final DateTime createdAt;
  final String transactionId;

  SavingsTransaction({
    required this.id,
    required this.scheme,
    required this.user,
    required this.amount,
    required this.grams,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.createdAt,
    required this.transactionId,
  });

  // ── Convenience accessors used in the UI ──
  String get schemeId    => scheme.schemeId; // "SCH--2026-0005"
  String get schemeName  => scheme.name;     // "Pure silver"
  String get assetType   => scheme.assetType;

  factory SavingsTransaction.fromJson(Map<String, dynamic> json) {
    // schemeId can arrive as a Map (populated) OR a plain String (ref only)
    TransactionScheme scheme;
    final rawScheme = json['schemeId'];
    if (rawScheme is Map<String, dynamic>) {
      scheme = TransactionScheme.fromJson(rawScheme);
    } else {
      scheme = TransactionScheme.fromString(rawScheme?.toString() ?? '');
    }

    // userId can arrive as a Map (populated) OR a plain String
    TransactionUser user;
    final rawUser = json['userId'];
    if (rawUser is Map<String, dynamic>) {
      user = TransactionUser.fromJson(rawUser);
    } else {
      user = TransactionUser.empty();
    }

    return SavingsTransaction(
      id: json['_id'] ?? '',
      scheme: scheme,
      user: user,
      amount: (json['amount'] ?? 0).toDouble(),
      grams: (json['grams'] ?? 0).toDouble(),
      paymentMethod: json['paymentMethod'] ?? '',
      paymentStatus: json['paymentStatus'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      transactionId: json['transactionId'] ?? '',
    );
  }
}