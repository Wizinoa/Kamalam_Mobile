// ignore_for_file: file_names

class GoldPrice {
  final String id;
  final String goldType;
  final int buyPrice;
  final int sellPrice;
  final bool isActive;
  final DateTime effectiveFrom;

  GoldPrice({
    required this.id,
    required this.goldType,
    required this.buyPrice,
    required this.sellPrice,
    required this.isActive,
    required this.effectiveFrom,
  });

  factory GoldPrice.fromJson(Map<String, dynamic> json) {
    return GoldPrice(
      id: json['_id'],
      goldType: json['goldType'],
      buyPrice: json['buyPrice'],
      sellPrice: json['sellPrice'],
      isActive: json['isActive'],
      effectiveFrom: DateTime.parse(json['effectiveFrom']),
    );
  }
}