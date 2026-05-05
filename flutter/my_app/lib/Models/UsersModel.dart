class UserModel {
  final String id;
  final String mobile;
  final String email;
  final String fullName;

  final Map<String, dynamic>? address;

  final bool isVerified;
  final bool isBlocked;

  final String kycStatus;

  final String? aadharFrontImage;
  final String? aadharBackImage;
  final String? panImage;

  final double goldBalance;

  UserModel({
    required this.id,
    required this.mobile,
    required this.email,
    required this.fullName,
    this.address,
    required this.isVerified,
    required this.isBlocked,
    required this.kycStatus,
    this.aadharFrontImage,
    this.aadharBackImage,
    this.panImage,
    required this.goldBalance,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '',
      mobile: json['mobile'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',

      address: json['address'],

      isVerified: json['isVerified'] ?? false,
      isBlocked: json['isBlocked'] ?? false,

      kycStatus: json['kycStatus'] ?? '',

      aadharFrontImage: json['aadharfrontImage'],
      aadharBackImage: json['aadharbackImage'],
      panImage: json['panImage'],

      goldBalance: (json['goldBalance'] ?? 0).toDouble(),
    );
  }
}