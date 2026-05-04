// user_model.dart
class UserModel {
  final String id;
  final String mobile;
  final String email;
  final String fullName;

  UserModel({
    required this.id,
    required this.mobile,
    required this.email,
    required this.fullName,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '',
      mobile: json['mobile'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
    );
  }
}
