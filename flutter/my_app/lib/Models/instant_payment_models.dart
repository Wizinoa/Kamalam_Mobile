class InstantPaymentModels {
  final String assetType;
  final String grams;
  final String paymentMethod;

  InstantPaymentModels({
    required this.assetType,
    required this.grams,
    required this.paymentMethod,
  });

  Map<String, dynamic> toJson() {
    return {
      "assetType": assetType,
      "paymentMethod": grams,
      "schemeId": paymentMethod,
    };
  }
}