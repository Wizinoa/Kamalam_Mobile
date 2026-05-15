import 'package:flutter/material.dart';
import 'package:my_app/Api/instant_transaction_api.dart';
import 'package:my_app/Models/instant_transaction_models.dart';

class TransactionProvider extends ChangeNotifier {
  bool isLoading = false;
  List<TransactionModel> transactions = [];

  /// [filter] values: "" = all, "thisMonth", "last3Months", "thisYear"
  Future<void> fetchTransactions({String filter = ""}) async {
    try {
      isLoading = true;
      notifyListeners();

      transactions = await TransactionApi.getTransactions(filter: filter);
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}