import 'package:flutter/material.dart';
import 'package:my_app/Api/savings_history_api.dart';
import 'package:my_app/Models/savings_history_models.dart';

class SavingsHistoryProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  SavingsSummary? _summary;
  SavingsSummary? get summary => _summary;

  List<SavingsTransaction> _transactions = [];
  List<SavingsTransaction> get transactions => _transactions;

  int _transactionCount = 0;
  int get transactionCount => _transactionCount;

  // Track if the asset has no savings data
  bool _hasNoData = false;
  bool get hasNoData => _hasNoData;

  Future<void> fetchSavingsHistory(String assetType) async {
    try {
      _isLoading = true;
      _hasNoData = false;
      // Clear previous data before fetching new
      _summary = null;
      _transactions = [];
      _transactionCount = 0;
      notifyListeners();

      final response = await SavingsHistoryApi.getSavingsHistory(assetType);

      if (response == null) {
        _hasNoData = true;
        _summary = null;
        _transactions = [];
        _transactionCount = 0;
      } else {
        _hasNoData = false;
        _summary = response.summary;
        _transactions = response.data;
        _transactionCount = response.transactionCount;
      }
    } catch (e) {
      debugPrint('Savings History Error: $e');
      _hasNoData = true;
      _summary = null;
      _transactions = [];
      _transactionCount = 0;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
