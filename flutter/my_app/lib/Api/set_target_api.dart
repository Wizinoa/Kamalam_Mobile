
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_app/Environment/env.dart';
import 'package:my_app/Models/set_target_models.dart';
import 'package:my_app/Utils/local_storage.dart';

class SetTargetApi {
  SetTargetApi._();

  // ── POST /api/v1/savings/set-target ──────────────────────────
  static Future<bool> setTarget(SetTargetModel model) async {
    try {
      final token = await LocalStorage.getToken();
      final url = Uri.parse('${AppEnv.baseUrl}/api/v1/savings/set-target');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(model.toJson()),
      );

      final data = jsonDecode(response.body);
      return (response.statusCode == 200 || response.statusCode == 201) &&
          data['success'] == true;
    } catch (e) {
      throw Exception('Set target failed: $e');
    }
  }

  // ── GET /api/v1/savings/targets/:assetType ────────────────────
  static Future<SavingsTargetResponse?> getTarget(String assetType) async {
    try {
      final token = await LocalStorage.getToken();
      final url = Uri.parse(
        '${AppEnv.baseUrl}/api/v1/savings/targets/${assetType.toLowerCase()}',
      );

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      // 404 or success=false means no target set yet → return null
      if (response.statusCode == 404 || data['success'] == false) {
        return null;
      }

      if (response.statusCode == 200) {
        return SavingsTargetResponse.fromJson(data);
      }

      return null;
    } catch (e) {
      return null; // network error → treat as no target
    }
  }
}