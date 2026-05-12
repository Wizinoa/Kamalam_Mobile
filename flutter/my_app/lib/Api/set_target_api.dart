// api/set_target_api.dart

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:my_app/Environment/env.dart';
import 'package:my_app/Models/set_target_models.dart';
import 'package:my_app/Utils/local_storage.dart';

class SetTargetApi {

  static Future<bool> setTarget(
    SetTargetModel model,
  ) async {

    try {

      final token = await LocalStorage.getToken();

      final url = Uri.parse(
        "${AppEnv.baseUrl}/api/v1/savings/set-target",
      );

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(
          model.toJson(),
        ),
      );

      final data = jsonDecode(
        response.body,
      );

      print(response.body);

      return response.statusCode == 200 ||
          response.statusCode == 201 &&
              data['success'] == true;

    } catch (e) {

      throw Exception(
        "Set target failed: $e",
      );
    }
  }
}