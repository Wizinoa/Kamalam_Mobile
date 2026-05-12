import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_app/Environment/env.dart';
import 'package:my_app/Models/receipt_models.dart';

import 'package:my_app/Utils/local_storage.dart';

class ReceiptsApi {
  static Future<List<ReceiptModel>> fetchReceipts(String savingsId) async {
    try {
      final token = await LocalStorage.getToken();

      final url = Uri.parse(
        "${AppEnv.baseUrl}/api/v1/savings/$savingsId/receipts",
      );

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        final List list = decoded['data'] ?? [];

        return list.map((e) => ReceiptModel.fromJson(e)).toList();
      }

      return [];
    } catch (e) {
      print("Receipts API Error: $e");
      return [];
    }
  }
}