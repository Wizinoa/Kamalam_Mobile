import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:my_app/Environment/env.dart';
import 'package:my_app/Models/savings_models.dart';
import 'package:my_app/Utils/local_storage.dart';

class SavingsApi {

  static Future<List<SavingsSummaryModel>>
      getSavingsSummary() async {

    try {

      final token =
          await LocalStorage.getToken();

      final url = Uri.parse(
        "${AppEnv.baseUrl}/api/v1/savings/summary",
      );

      final response = await http.get(
        url,
        headers: {
          "Content-Type":
              "application/json",

          "Authorization":
              "Bearer $token",
        },
      );

      final data =
          jsonDecode(response.body);

      if (response.statusCode == 200) {

        final List<dynamic> list =
            data["data"];

        return list
            .map(
              (e) =>
                  SavingsSummaryModel
                      .fromJson(e),
            )
            .toList();
      }

      return [];

    } catch (e) {

      print(e);

      return [];
    }
  }
}