import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:my_app/Models/gold_models.dart';

import '../Environment/env.dart';

import '../Utils/local_storage.dart';

class GoldApi {
  Future<Map<String, GoldPrice?>> fetchGoldPrice() async {
    try {
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
          final assetType = (item['assetType'] ?? '')
              .toString()
              .toLowerCase()
              .trim();

          final purity = (item['purity'] ?? '').toString().toLowerCase().trim();

          /// GOLD -> ONLY 22K
          if (assetType == 'gold' && purity == '22k') {
            goldPrice = GoldPrice.fromJson(item);
          }
          /// SILVER -> NO PURITY CHECK
          else if (assetType == 'silver' || assetType == 'sliver') {
            silverPrice = GoldPrice.fromJson(item);
          }
        }

        return {'gold': goldPrice, 'silver': silverPrice};
      } else {
        throw Exception(decoded['message'] ?? "Failed to fetch gold price");
      }
    } catch (e) {
      throw Exception("Gold price fetch failed: $e");
    }
  }
}
