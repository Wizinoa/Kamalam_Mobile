import 'package:flutter/material.dart';
import 'package:my_app/Api/passbook_api.dart';
import 'package:my_app/Models/passbook_models.dart';

class PassbookProviders extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<PassbookModels> _schemes = [];
  List<PassbookModels> get schemes => _schemes;

  Future<void> fetchSavingsDetails() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await PassbookApi.fetchPassbook();

      if (response != null) {
        _schemes = response; // must be List
      } else {
        _schemes = [];
      }
    } catch (e) {
      debugPrint("Error: $e");
      _schemes = [];
    }

    _isLoading = false;
    notifyListeners();
  }
}