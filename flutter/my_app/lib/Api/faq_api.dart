import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/Environment/env.dart';
import 'package:my_app/Models/faq_models.dart';
import 'package:my_app/Utils/local_storage.dart';


class FaqApiService {

  // ── GET /api/v1/faq ──────────────────────────────────────
  static Future<List<FaqModel>> fetchFaq() async {
    try {
      final token = await LocalStorage.getToken();
      final url = Uri.parse('${AppEnv.baseUrl}/api/v1/faq');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          data['success'] == true) {
        final List list = data['data'] ?? [];
        return list.map((e) => FaqModel.fromJson(e)).toList();
      }

      throw Exception(data['message'] ?? 'Failed to load FAQs.');
    } catch (e) {
      debugPrint('FaqApiService.fetchFaq error: $e');
      throw Exception('Fetch FAQ failed: $e');
    }
  }
}