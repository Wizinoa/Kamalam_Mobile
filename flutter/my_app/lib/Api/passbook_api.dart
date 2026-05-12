import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_app/Environment/env.dart';
import 'package:my_app/Models/passbook_models.dart';
import 'package:my_app/Utils/local_storage.dart';

class PassbookApi {
  static Future<List<PassbookModels>?> fetchPassbook() async {
    try {
      final token = await LocalStorage.getToken();

      final url = Uri.parse(
        "${AppEnv.baseUrl}/api/v1/savings/passbook",
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

        final List data = decoded["data"] ?? [];

        return data
            .map((e) => PassbookModels.fromJson(e))
            .toList();
      }

      print("Passbook API Failed: ${response.body}");
      return null;
    } catch (e) {
      print("Passbook API Error: $e");
      return null;
    }
  }
}