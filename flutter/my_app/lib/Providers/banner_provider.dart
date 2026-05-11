import 'package:flutter/material.dart';
import 'package:my_app/Api/banner_api.dart';
import 'package:my_app/Models/banner_models.dart';


class BannerProvider extends ChangeNotifier {
  List<BannerModel> _banners = [];
  bool _isLoading = false;
  String? _error;
  List<BannerModel> get banners => _banners;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Future<void> fetchBanners() async {
    _isLoading = true;
    notifyListeners();
    try {
      _banners = await BannerApi().fetchBanners();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}