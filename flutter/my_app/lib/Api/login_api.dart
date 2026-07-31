import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_app/Environment/env.dart';
import 'package:my_app/Utils/local_storage.dart';

class AuthApi {
  Future<bool> sendOtp(String contact, {bool isEmail = false}) async {
    final url = Uri.parse("${AppEnv.baseUrl}/api/v1/auth/send-otp");

    final Map<String, String> body;
    if (isEmail) {
      body = {"email": contact};
    } else {
      body = {"mobile": contact};
    }

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? data['error'] ?? 'Failed to send OTP');
    }
  }

Future<Map<String, dynamic>> registerUser({
  required String mobile,
  required String fullName,
  required String email,
  required String role,
}) async {
  try {
    final url = Uri.parse("${AppEnv.baseUrl}/api/v1/admin/users");

    final body = {
      "mobile": mobile,
      "fullName": fullName,
      "email": email,
      "role": role,
    };

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    print("STATUS CODE : ${response.statusCode}");
    print("BODY : ${response.body}");

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return data;
    }

    throw Exception(
      data["message"] ??
          data["error"] ??
          data["errors"]?.toString() ??
          "Registration failed",
    );
  } on http.ClientException catch (e) {
    throw Exception(e.message);
  } on FormatException {
    throw Exception("Invalid response from server");
  } catch (e) {
  if (e is Exception) rethrow;
  throw Exception(e.toString());
}
}

  Future<Map<String, dynamic>> otpVerification({
    required String mobile,
    required String otp,
    required String email,
  }) async {
    final url = Uri.parse("${AppEnv.baseUrl}/api/v1/auth/verify-otp");

    final body = {"mobile": mobile, "otp": otp, "email": email};

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return data;
    } else {
      throw Exception(data['message'] ?? "Registration failed");
    }
  }

  Future<Map<String, dynamic>> registerMpin({
    required String mobile,
    required String email,
    required String mpin,
  }) async {
    final url = Uri.parse("${AppEnv.baseUrl}/api/v1/auth/set-mpin");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"mobile": mobile, "email": email, "mpin": mpin}),
    );

    final data = jsonDecode(response.body);

    /// ❌ HTTP ERROR
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(data['error'] ?? "Something went wrong");
    }

    /// ❌ API FAIL
    if (data['success'] != true) {
      throw Exception(data['error'] ?? data['message'] ?? "Failed");
    }

    /// ✅ SUCCESS ONLY
    return data;
  }
Future<Map<String, dynamic>> loginApi({
  required String mobile,
  required String email,
  required String mpin,
}) async {
  final url = Uri.parse("${AppEnv.baseUrl}/api/v1/auth/user/login");

  final body = {
    "mobile": mobile,
    "email": email,
    "mpin": mpin,
  };

  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(body),
  );

  final data = jsonDecode(response.body);

  if (response.statusCode == 200 || response.statusCode == 201) {
    final token = data['token']?.toString() ?? "";

    final user = data['user'] ?? {};

    final userEmail = user['email']?.toString() ?? "";


    await LocalStorage.saveToken(token);

    if (userEmail.isNotEmpty) {
      await LocalStorage.saveEmail(userEmail);
    }

    // Optional: save mobile too
    // await LocalStorage.saveMobile(userMobile);

    return data;
  }

  throw Exception(
    data['error'] ?? data['message'] ?? "Something went wrong",
  );
}
}
