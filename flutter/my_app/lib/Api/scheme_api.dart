import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_app/Environment/env.dart';
import 'package:my_app/Models/scheme_models.dart';
import 'package:my_app/Utils/local_storage.dart';

class SchemeApi {
  static Future<List<SchemeModel>> fetchSchemes() async {
     final token = await LocalStorage.getToken();
    if (token == null) {
      throw Exception("User not logged in");
    }
    final url = Uri.parse(
      "${AppEnv.baseUrl}/api/v1/schemes",
    );
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final List schemes = data['schemes'];

      return schemes
          .map((e) => SchemeModel.fromJson(e))
          .toList();
    } else {
      throw Exception("Failed to load schemes");
    }
  }
}