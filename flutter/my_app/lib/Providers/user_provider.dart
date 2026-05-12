// user_provider.dart

import 'package:flutter/material.dart';
import 'package:my_app/Api/user_api.dart';
import 'package:my_app/Models/users_model.dart';
import 'dart:io';


class UserProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;

  Future<void> fetchUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await UserApi.getUserProfile();
    } catch (e) {
      debugPrint("User fetch error: $e");
    }

    _isLoading = false;
    notifyListeners();
  } 

Future<bool> updateUser({
  required String fullName,
  required String email,
  required String mobile,
  Map<String, dynamic>? address,
  File? aadharFront,
  File? aadharBack,
  File? panImage,
  String? panNumber,
  String? aadharNumber,
}) async {
  try {
    final updated = await UserApi.updateProfile(  // ← capture returned UserModel
      fullName: fullName,
      email: email,
      mobile: mobile,
      address: address,
      aadharFront: aadharFront,
      aadharBack: aadharBack,
      panImage: panImage,
      panNumber: panNumber,
      aadharNumber: aadharNumber,
    );
    _user = updated;         // ← update local user immediately
    notifyListeners();       // ← notify so Consumer rebuilds with new values
    return true;
  } catch (e) {
    print("ERROR: $e");
    return false;
  }
}                                                   
}                                                                     