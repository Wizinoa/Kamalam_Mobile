class PaymentModel {
  final String amount;
  final String paymentMethod;
  final String schemeId;

  PaymentModel({
    required this.amount,
    required this.paymentMethod,
    required this.schemeId,
  });

  Map<String, dynamic> toJson() {
    return {
      "amount": amount,
      "paymentMethod": paymentMethod,
      "schemeId": schemeId,
    };
  }
}