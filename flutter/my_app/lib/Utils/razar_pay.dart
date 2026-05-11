import 'package:flutter/services.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorPayService {
  RazorPayService() : _razorpay = Razorpay();

  final Razorpay _razorpay;

  void openCheckout({
    required int amountInRupees,
    required String key,
    required String name,
    required String id,        // ← this is now the real Razorpay order_id
    required String description,
    required String prefillContact,
    required String prefillEmail,
    required void Function(PaymentSuccessResponse) onSuccess,
    required void Function(PaymentFailureResponse) onError,
    required void Function(ExternalWalletResponse) onExternalWallet,
    void Function(String)? onPluginError,
  }) {
    try {
      _razorpay.clear();

      _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, onSuccess);
      _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, onError);
      _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, onExternalWallet);

      final options = {
        'key': key,
        'amount': amountInRupees * 100,
        'currency': 'INR',
        'name': name,
        'description': description,
        'order_id': id,           // ✅ real Razorpay order_id → gives signature on success
        'image': 'https://i.postimg.cc/d3tby2qW/logo.png',
        'prefill': {
          'contact': prefillContact,
          'email': prefillEmail,
        },
        'method': {
          'upi': true,
          'card': true,
          'netbanking': true,
          'wallet': true,
        },
        'upi': {
          'flow': 'intent',
        },
        'theme': {
          'color': '#C6003A',
        },
      };

      _razorpay.open(options);
    } on MissingPluginException {
      onPluginError?.call(
        'Razorpay plugin not registered. Run flutter clean & rebuild.',
      );
    }
  }

  void dispose() {
    _razorpay.clear();
  }
}