import 'package:flutter/material.dart';
import 'package:my_app/Api/receipt_api.dart';
import 'package:my_app/Models/receipt_models.dart';

class ReceiptsProvider extends ChangeNotifier {
  bool isLoading = false;
  List<ReceiptModel> receipts = [];

  Future<void> fetchReceipts(String savingsId) async {
    isLoading = true;
    notifyListeners();

    try {
      receipts = await ReceiptsApi.fetchReceipts(savingsId);
    } catch (e) {
      debugPrint("Receipts Error: $e");
      receipts = [];
    }

    isLoading = false;
    notifyListeners();
  }

  void clear() {
    receipts = [];
    isLoading = false; // ← Show spinner immediately, not old data
    notifyListeners();
  }
}