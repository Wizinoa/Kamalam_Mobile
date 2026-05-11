import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_app/Environment/env.dart';
import 'package:my_app/Models/banner_models.dart';
import 'package:my_app/Utils/local_storage.dart';

class BannerApi {
  Future<List<BannerModel>> fetchBanners() async {
    final token = await LocalStorage.getToken();

    if (token == null) {
      throw Exception("User not logged in");
    }

    final url = Uri.parse(
      "${AppEnv.baseUrl}/api/v1/banner",
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
      final List bannerList = data['data'];

      return bannerList
          .map((e) => BannerModel.fromJson(e))
          .toList();
    } else {
      throw Exception(
        data['message'] ?? "Failed to fetch banners",
      );
    }
  }
}