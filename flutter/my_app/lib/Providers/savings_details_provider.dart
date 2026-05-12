import 'package:flutter/material.dart';
import 'package:my_app/Api/savings_details_api.dart';
import 'package:my_app/Models/savings_models.dart';


class SavingsProvider
    extends ChangeNotifier {

  bool isLoading = false;

  List<SavingsSummaryModel>
      savingsList = [];

  Future<void>
      fetchSavingsDetails() async {

    isLoading = true;

    notifyListeners();

    savingsList =
        await SavingsApi
            .getSavingsSummary();

    isLoading = false;

    notifyListeners();
  }
}