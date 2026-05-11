import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_app/Environment/env.dart';
import 'package:my_app/Models/gold_models.dart';
import 'package:my_app/Utils/local_storage.dart';

class GoldApi {
  Future<Map<String, GoldPrice?>> fetchGoldPrice() async {
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
    final decoded = jsonDecode(response.body);
    if (response.statusCode == 200) {
      final List<dynamic> dataList = decoded['data'] ?? [];
      GoldPrice? goldPrice;
      GoldPrice? silverPrice;
      for (final item in dataList) {
        final assetType = (item['assetType'] ?? '').toString().toLowerCase().trim();
        if (assetType.contains('gold')) {
          goldPrice = GoldPrice.fromJson(item);
        } else if (assetType.contains('silver') || assetType.contains('sliver')) {
          silverPrice = GoldPrice.fromJson(item);
        }
      }
      return {'gold': goldPrice, 'silver': silverPrice};
    } else {
      throw Exception(decoded['message'] ?? "Failed to fetch gold price");
    }
  }
}