import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:my_app/Environment/env.dart';
import 'package:my_app/Models/notifications_models.dart';
import 'package:my_app/Utils/local_storage.dart';


class NotificationApi {
  Future<List<NotificationModel>> fetchNotifications() async {
    final token = await LocalStorage.getToken();

    if (token == null) {
      throw Exception("User not logged in");
    }

    final url = Uri.parse(
      "${AppEnv.baseUrl}/api/v1/notifications",
    );

    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {

      final List notifications = data['notifications'];

      return notifications
          .map((e) => NotificationModel.fromJson(e))
          .toList();

    } else {
      throw Exception(
        data['message'] ?? "Failed to fetch notifications",
      );
    }
  }
}