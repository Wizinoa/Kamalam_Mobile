import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_app/Models/instant_payment_models.dart';
import 'package:my_app/Models/payment_models.dart';
import 'package:my_app/Utils/local_storage.dart';
import 'package:my_app/Environment/env.dart';

class PaymentApi {

  // ✅ Returns full response map so Flutter can read order.id
  static Future<Map<String, dynamic>?> createPayment(PaymentModel model) async {
    try {
      final token = await LocalStorage.getToken();
      if (token == null) throw Exception("User not logged in");

      final url = Uri.parse("${AppEnv.baseUrl}/api/v1/deposit/create");

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(model.toJson()),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Create Payment Success: $data");
        return data; // ✅ { success, order: { id: "order_xxx" }, deposit: {...} }
      }

      print("Create Payment Error: ${response.body}");
      return null;
    } catch (e) {
      print("API Exception: $e");
      return null;
    }
  }

static Future<Map<String, dynamic>?> instantPayment(
    InstantPaymentModels model) async {
  try {
    final token = await LocalStorage.getToken();

    if (token == null) {
      throw Exception("User not logged in");
    }

    final url = Uri.parse(
      "${AppEnv.baseUrl}/api/v1/instant/create",
    );
final body = {
  "assetType": model.assetType,
  "grams": num.parse(model.grams.toString()),
  "paymentMethod": model.paymentMethod,
};

    print("REQUEST BODY => ${jsonEncode(body)}");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );

    print("STATUS CODE => ${response.statusCode}");
    print("RESPONSE => ${response.body}");

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      return data;
    }

    return null;
  } catch (e) {
    print("API Exception => $e");
    return null;
  }
}
}