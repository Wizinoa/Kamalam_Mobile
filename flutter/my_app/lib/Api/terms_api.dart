import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/Environment/env.dart';
import 'package:my_app/Models/terms_models.dart';
import 'package:my_app/Utils/local_storage.dart';

class TermsApiService {

  // ── GET /api/v1/terms ────────────────────────────────────
  static Future<List<TermsModel>> fetchTerms() async {
    try {
      final token = await LocalStorage.getToken();
      final url = Uri.parse('${AppEnv.baseUrl}/api/v1/terms');

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
        return list.map((e) => TermsModel.fromJson(e)).toList();
      }

      throw Exception(data['message'] ?? 'Failed to load terms.');
    } catch (e) {
      debugPrint('TermsApiService.fetchTerms error: $e');
      throw Exception('Fetch terms failed: $e');
    }
  }

  // ── GET /api/v1/privacy ──────────────────────────────────
  static Future<List<TermsModel>> fetchPrivacy() async {
    try {
      final token = await LocalStorage.getToken();
      final url = Uri.parse('${AppEnv.baseUrl}/api/v1/privacy');

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
        return list.map((e) => TermsModel.fromJson(e)).toList();
      }

      throw Exception(data['message'] ?? 'Failed to load privacy policy.');
    } catch (e) {
      debugPrint('TermsApiService.fetchPrivacy error: $e');
      throw Exception('Fetch privacy failed: $e');
    }
  }
}