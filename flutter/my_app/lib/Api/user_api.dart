import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_app/Environment/env.dart';
import 'package:my_app/Models/users_model.dart';
import '../utils/local_storage.dart';
import 'dart:io';

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
  Map<String, dynamic>? address,
  File? aadharFront,
  File? aadharBack,
  File? panImage,
}) async {
  final token = await LocalStorage.getToken();
  if (token == null) {
    throw Exception("Token missing");
  }
  final url = Uri.parse("${AppEnv.baseUrl}/api/v1/user/profile");
  final hasImages =
      aadharFront != null || aadharBack != null || panImage != null;
  try {
    if (!hasImages) {
      final response = await http.put(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "fullName": fullName,
          "email": email,
          "mobile": mobile,
          "address": address ?? {},
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return UserModel.fromJson(data['data']);
      } else {
        throw Exception(data['message'] ?? "Update failed");
      }
    }
    final request = http.MultipartRequest('PUT', url);
    request.headers['Authorization'] = "Bearer $token";
    request.fields['fullName'] = fullName;
    request.fields['email'] = email;
    request.fields['mobile'] = mobile;

    if (address != null) {
      request.fields['address'] = jsonEncode(address);
    }

    /// Helper
    Future<void> addFile(File file, String key) async {
      if (await file.exists()) {
        request.files.add(
          await http.MultipartFile.fromPath(key, file.path),
        );
      }
    }

    if (aadharFront != null) {
      await addFile(aadharFront, 'aadharfrontImage');
    }

    if (aadharBack != null) {
      await addFile(aadharBack, 'aadharbackImage');
    }

    if (panImage != null) {
      await addFile(panImage, 'panImage');
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    final data = jsonDecode(response.body);

    print("📡 MULTIPART STATUS: ${response.statusCode}");
    print("📡 MULTIPART BODY: ${response.body}");

    if (response.statusCode == 200 && data['success'] == true) {
      return UserModel.fromJson(data['data']);
    } else {
      throw Exception(data['message'] ?? "Update failed");
    }
  } catch (e) {
    print("❌ API ERROR: $e");
    rethrow;
  }
}

}