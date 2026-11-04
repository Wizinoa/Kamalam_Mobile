class ReceiptModel {
  final String id;
  final String transactionType;
  final double amount;
  final double grams;
  final String status;
  final DateTime? createdAt;
  final String transactionId;

  // The API returns purity inside the populated schemeId object.
  final String? purity;

  // Extra nested scheme details, useful if needed elsewhere in the UI.
  final String? schemeName;
  final String? schemeType;
  final String? assetType;
  final String? schemeCode;

  ReceiptModel({
    required this.id,
    required this.transactionType,
    required this.amount,
    required this.grams,
    required this.status,
    required this.createdAt,
    required this.transactionId,
    this.purity,
    this.schemeName,
    this.schemeType,
    this.assetType,
    this.schemeCode,
  });

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  factory ReceiptModel.fromJson(Map<String, dynamic> json) {
    // Handles the populated schemeId map in your transaction API.
    final dynamic rawScheme = json['schemeId'];
    final Map<String, dynamic> scheme = rawScheme is Map
        ? Map<String, dynamic>.from(rawScheme)
        : <String, dynamic>{};

    final dynamic rawCreatedAt = json['createdAt'];

    return ReceiptModel(
      id: json['_id']?.toString() ?? '',
      transactionType: json['transaction_type']?.toString() ?? '',
      amount: _toDouble(json['amount']),
      grams: _toDouble(json['grams']),
      status: json['status']?.toString() ?? '',
      createdAt: rawCreatedAt == null
          ? null
          : DateTime.tryParse(rawCreatedAt.toString()),
      transactionId: json['transactionId']?.toString() ?? '',
      purity: scheme['purity']?.toString(),
      schemeName: scheme['name']?.toString(),
      schemeType: scheme['schema_type']?.toString(),
      assetType: scheme['assetType']?.toString(),
      schemeCode: scheme['schemeId']?.toString(),
    );
  }
}
