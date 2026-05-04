// user_provider.dart

import 'package:flutter/material.dart';
import 'package:my_app/Api/user_api.dart';
import 'package:my_app/Models/UsersModel.dart';


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
}) async {
  _isLoading = true;
  notifyListeners();

  try {
    final updatedUser = await UserApi.updateProfile(
      fullName: fullName,
      email: email,
      mobile: mobile,
    );

    _user = updatedUser; // ✅ update local state
    return true;
  } catch (e) {
    debugPrint("Update error: $e");
    return false;
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}                                                      
}                                                                     