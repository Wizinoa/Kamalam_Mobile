import 'package:flutter/material.dart';
import 'package:my_app/Api/scheme_api.dart';
import 'package:my_app/Models/scheme_models.dart';


class SchemeProvider extends ChangeNotifier {
  List<SchemeModel> _schemes = [];
  bool _isLoading = false;
  List<SchemeModel> get schemes => _schemes;
  bool get isLoading => _isLoading;

  Future<void> fetchSchemes() async {
    try {
      _isLoading = true;
      notifyListeners();
      _schemes = await SchemeApi.fetchSchemes();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }
}