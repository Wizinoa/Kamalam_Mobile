class TransactionModel {
  final String id;
  final String userId;
  final String assetType;
  final String? purity;
  final String type;
  final double amount;
  final double gstPercentage;
  final double gstAmount;
  final double totalAmount;
  final double ratePerGram;
  final double grams;
  final String razorpayOrderId;
  final String paymentMethod;
  final String paymentGateway;
  final String paymentStatus;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String transactionId;
  final String razorpayPaymentId;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.assetType,
    this.purity,
    required this.type,
    required this.amount,
    required this.gstPercentage,
    required this.gstAmount,
    required this.totalAmount,
    required this.ratePerGram,
    required this.grams,
    required this.razorpayOrderId,
    required this.paymentMethod,
    required this.paymentGateway,
    required this.paymentStatus,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.transactionId,
    required this.razorpayPaymentId,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json["_id"] ?? "",
      userId: json["userId"] ?? "",
      assetType: json["assetType"] ?? "",
      purity: json["purity"],
      type: json["type"] ?? "",
      amount: (json["amount"] ?? 0).toDouble(),
      gstPercentage: (json["gstPercentage"] ?? 0).toDouble(),
      gstAmount: (json["gstAmount"] ?? 0).toDouble(),
      totalAmount: (json["totalAmount"] ?? 0).toDouble(),
      ratePerGram: (json["ratePerGram"] ?? 0).toDouble(),
      grams: (json["grams"] ?? 0).toDouble(),
      razorpayOrderId: json["razorpayOrderId"] ?? "",
      paymentMethod: json["paymentMethod"] ?? "",
      paymentGateway: json["paymentGateway"] ?? "",
      paymentStatus: json["paymentStatus"] ?? "",
      status: json["status"] ?? "",
      createdAt: DateTime.parse(json["createdAt"]),
      updatedAt: DateTime.parse(json["updatedAt"]),
      transactionId: json["transactionId"] ?? "",
      razorpayPaymentId: json["razorpayPaymentId"] ?? "",
    );
  }
}