class BannerModel {
  final String? bannerImage;
  final DateTime updatedAt;

  BannerModel({
    this.bannerImage,
    required this.updatedAt,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      bannerImage: json['banner_image'],
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}