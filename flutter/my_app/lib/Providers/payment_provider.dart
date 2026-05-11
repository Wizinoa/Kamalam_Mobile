import 'package:flutter/material.dart';
import 'package:my_app/Api/payment_api.dart';
import 'package:my_app/Models/payment_models.dart';

class PaymentProvider extends ChangeNotifier {
  bool isLoading = false;

  // ✅ Returns full map so screen can read order.id
  Future<Map<String, dynamic>?> createPayment({
    required String amount,
    required String paymentMethod,
    required String schemeId,
  }) async {
    isLoading = true;
    notifyListeners();

    final model = PaymentModel(
      amount: amount,
      paymentMethod: paymentMethod,
      schemeId: schemeId,
    );

    final data = await PaymentApi.createPayment(model);

    isLoading = false;
    notifyListeners();

    return data;
  }
}