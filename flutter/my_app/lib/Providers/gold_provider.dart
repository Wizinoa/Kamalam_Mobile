import 'package:flutter/material.dart';
import 'package:my_app/Api/gold_api.dart';
import 'package:my_app/Models/gold_models.dart';

class GoldPriceProvider extends ChangeNotifier {
  GoldPrice? _goldData;
  GoldPrice? _silverData;
  bool _isLoading = false;
  String? _error;

  GoldPrice? get goldData => _goldData;
  GoldPrice? get silverData => _silverData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchGoldPrice() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final Map<String, GoldPrice?> result = await GoldApi().fetchGoldPrice();
      _goldData = result['gold'];
      _silverData = result['silver'];
    } catch (e) {
      _error = e.toString();
      debugPrint('GoldPriceProvider error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}