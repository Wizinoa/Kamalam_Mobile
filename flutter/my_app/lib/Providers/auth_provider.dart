import 'package:flutter/material.dart';
import 'package:my_app/Api/login_api.dart';

class AuthProvider extends ChangeNotifier {
  final AuthApi _api = AuthApi();

  bool _isLoading = false;
  bool get isLoading => _isLoading;
Future<void> sendOtp(String contact, {bool isEmail = false}) async {
  _isLoading = true;
  notifyListeners();

  try {
    await _api.sendOtp(contact, isEmail: isEmail);
  } catch (e) {
    rethrow;
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

  Future<void> registerUser({
    required String mobile,
    required String fullName,
    required String email,
    // required String password,
    required String role,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _api.registerUser(
        mobile: mobile,
        fullName: fullName,
        // password: password,
        email: email,
        role: role,
      );
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> otpVerification({
    required String mobile,
    required String otp,
    required String email,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _api.otpVerification(
        mobile: mobile,
        otp: otp,
        email: email,
      );
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> registerMpin({
    required String mobile,
    required String email,
    required String mpin,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _api.registerMpin(mobile: mobile, email: email, mpin: mpin);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loginApi({
    required String mobile,
    required String email,
    required String mpin,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _api.loginApi(mobile: mobile, email: email, mpin: mpin);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
