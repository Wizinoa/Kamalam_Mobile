import 'package:flutter/services.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorPayService {
  RazorPayService() : _razorpay = Razorpay();

  final Razorpay _razorpay;

void openCheckout({
  required int amountInRupees,
  required String key,
  required String name,
  required String description,
  required String prefillContact,
  required String prefillEmail,
  required void Function(PaymentSuccessResponse response) onSuccess,
  required void Function(PaymentFailureResponse response) onError,
  required void Function(ExternalWalletResponse response) onExternalWallet,
  void Function(String message)? onPluginError,
}) {
  try {
    _razorpay.clear(); // ✅ prevent duplicate listeners

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, onSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, onError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, onExternalWallet);

    final options = {
      'key': key,
      'amount': amountInRupees * 100,
      'currency': 'INR',
      'name': name,
      'description': description,

       'image': 'https://i.postimg.cc/d3tby2qW/logo.png',

      'prefill': {
        'contact': prefillContact,
        'email': prefillEmail,
      },

      // ✅ UPI ONLY
      'method': {
        'upi': true,
        'card': true,
        'netbanking': true,
        'wallet': true,
      },

      // ✅ Optional: directly open UPI apps
      'upi': {
        'flow': 'intent', // opens GPay, PhonePe, etc.
      },

      // ✅ THEME COLOR
      'theme': {
  'color': '#C6003A', // ✅ correct
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
