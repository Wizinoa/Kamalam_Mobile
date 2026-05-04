import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_app/Environment/env.dart';
import 'package:my_app/Models/UsersModel.dart';
import '../utils/local_storage.dart';

class UserApi {
  static Future<UserModel> getUserProfile() async {
    final token = await LocalStorage.getToken();
    final response = await http.get(
      Uri.parse("${AppEnv.baseUrl}/api/v1/user/profile"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return UserModel.fromJson(data['user']);
    } else {
      throw Exception(data['message'] ?? "Failed to fetch profile");
    }
  }

static Future<UserModel> updateProfile({
  required String fullName,
  required String email,
  required String mobile,
}) async {
  final token = await LocalStorage.getToken();
  final response = await http.put( // ✅ use PUT or PATCH
    Uri.parse("${AppEnv.baseUrl}/api/v1/user/profile"),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    },
    body: jsonEncode({
      "fullName": fullName,
      "email": email,
      "mobile": mobile,
    }),
  );

  final data = jsonDecode(response.body);
  if (response.statusCode == 200) {
    return UserModel.fromJson(data['user']);
  } else {
    throw Exception(data['message'] ?? "Failed to update profile");
  }
}
}