// providers/set_target_provider.dart

import 'package:flutter/material.dart';
import 'package:my_app/Api/set_target_api.dart';
import 'package:my_app/Models/set_target_models.dart';

class SetTargetProvider extends ChangeNotifier {

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<bool> setTarget(
    SetTargetModel model,
  ) async {

    _isLoading = true;
    notifyListeners();

    bool success = false;

    try {

      success = await SetTargetApi.setTarget(
        model,
      );

    } catch (e) {

      debugPrint(
        "Set Target Error: $e",
      );
    }

    _isLoading = false;
    notifyListeners();

    return success;
  }
}