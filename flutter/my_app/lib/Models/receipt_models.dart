class ReceiptModel {
  final String id;
  final String transactionType;
  final double amount;
  final double grams;
  final String status;
  final DateTime createdAt;
  final String transactionId;

  ReceiptModel({
    required this.id,
    required this.transactionType,
    required this.amount,
    required this.grams,
    required this.status,
    required this.createdAt,
    required this.transactionId,
  });

  factory ReceiptModel.fromJson(Map<String, dynamic> json) {
    return ReceiptModel(
      id: json['_id'] ?? '',
      transactionType: json['transaction_type'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      grams: (json['grams'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      transactionId: json['transactionId'] ?? '',
    );
  }
}