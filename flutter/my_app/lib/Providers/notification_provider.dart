import 'package:flutter/material.dart';
import 'package:my_app/Api/notification_api.dart';
import 'package:my_app/Models/notifications_models.dart';

class NotificationProvider extends ChangeNotifier {

  List<NotificationModel> _notificationData = [];

  bool _isLoading = false;
  String? _error;

  List<NotificationModel> get notificationData => _notificationData;

  bool get isLoading => _isLoading;

  String? get error => _error;

  Future<void> fetchNotifications() async {

    _isLoading = true;

    notifyListeners();

    try {

      final result = await NotificationApi().fetchNotifications();

      _notificationData = result;

      _error = null;

    } catch (e) {

      _error = e.toString();

    }

    _isLoading = false;

    notifyListeners();
  }
}