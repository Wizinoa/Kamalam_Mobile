import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:my_app/Environment/env.dart';
import 'package:my_app/Models/reward_models.dart';
import 'package:my_app/Utils/local_storage.dart';

class RewardApi {

  static Future<List<RewardModel>> getRewards(
    String savingsId,
  ) async {

    try {

      final token = await LocalStorage.getToken();

      final url = Uri.parse(
        "${AppEnv.baseUrl}/api/v1/savings/$savingsId/rewards",
      );

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data['success'] == true) {

        return (data['data'] as List)
            .map(
              (e) => RewardModel.fromJson(e),
            )
            .toList();
      } else {
        return [];
      }

    } catch (e) {
      throw Exception(
        "Failed to fetch rewards: $e",
      );
    }
  }
}