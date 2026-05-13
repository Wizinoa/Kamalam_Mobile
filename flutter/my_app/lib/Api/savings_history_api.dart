import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_app/Environment/env.dart';
import 'package:my_app/Models/savings_history_models.dart';
import 'package:my_app/Utils/local_storage.dart';

class SavingsHistoryApi {
  static Future<SavingsHistoryResponse?> getSavingsHistory(
    String assetType,
  ) async {
    try {
      final token = await LocalStorage.getToken();
      final url = Uri.parse(
        "${AppEnv.baseUrl}/api/v1/savings/history?assetType=$assetType",
      );

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      final data = jsonDecode(response.body);

      // If success is false, return null (no data for this asset type)
      if (data['success'] == false) {
        return null;
      }

      if (response.statusCode == 200) {
        return SavingsHistoryResponse.fromJson(data);
      }

      throw Exception(data['message'] ?? 'Failed to fetch savings history');
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}