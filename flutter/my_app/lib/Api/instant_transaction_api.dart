import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_app/Models/instant_transaction_models.dart';
import '../Utils/local_storage.dart';
import '../Environment/env.dart';

class TransactionApi {
      /// [filter] — "", "thisMonth", "last3Months", "thisYear"
  static Future<List<TransactionModel>> getTransactions({
    String filter = "",
  }) async {
    try {
      final token = await LocalStorage.getToken();

         final String endpoint = filter.isEmpty
          ? "${AppEnv.baseUrl}/api/v1/instant/transactions"
          : "${AppEnv.baseUrl}/api/v1/instant/transactions?filter=$filter";
 
      final url = Uri.parse(endpoint);

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        final List list = data["data"];

        return list
            .map((e) => TransactionModel.fromJson(e))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}