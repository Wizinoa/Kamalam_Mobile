import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_app/Environment/env.dart';
import 'package:my_app/Models/GoldModels.dart';
import 'package:my_app/Utils/local_storage.dart';

class GoldApi {
   Future<GoldPrice> fetchGoldPrice() async {
    final token = await LocalStorage.getToken();

    if (token == null) {
      throw Exception("User not logged in");
    }

    final url = Uri.parse("${AppEnv.baseUrl}/api/v1/admin/gold-price");
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      // 👇 extract only currentPrice
      return GoldPrice.fromJson(data['currentPrice']);
    } else {
      throw Exception(data['message'] ?? "Failed to fetch gold price");
    }
  }
}