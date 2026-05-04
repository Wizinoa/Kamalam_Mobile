import 'package:flutter/material.dart';
import 'package:my_app/Api/gold_api.dart';
import 'package:my_app/Models/GoldModels.dart';

class GoldPriceProvider extends ChangeNotifier {
  GoldPrice? _goldData;
  bool _isLoading = false;
  String? _error;

  GoldPrice? get goldData => _goldData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchGoldPrice() async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await GoldApi().fetchGoldPrice();
      _goldData = result;
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}