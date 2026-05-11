class GoldPrice {
  final String id;
  final String assetType;
  final int buyPrice;
  final int sellPrice;
  final String? purity;
  final double changePercentage;
  final bool isIncrease;
  final String? date;
  final String? time;
  

  GoldPrice({
    required this.id,
    required this.assetType,
    required this.buyPrice,
    required this.sellPrice,
    this.purity,
    required this.changePercentage,
    required this.isIncrease,
    this.date,
    this.time
  });

  factory GoldPrice.fromJson(Map<String, dynamic> json) {
    return GoldPrice(
      id: json['id'] ?? '',
      assetType: json['assetType'] ?? '',
      buyPrice: (json['buyPrice'] ?? 0).toInt(),
      sellPrice: (json['sellPrice'] ?? 0).toInt(),
      purity: json['purity'],
      changePercentage: (json['changePercentage'] ?? 0).toDouble(),
      isIncrease: json['isIncrease'] ?? false,
      date:json['date'] ?? '',
      time: json['time'] ?? '',
    );
  }
}