import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationProvider with ChangeNotifier {
  bool _isNotificationEnabled = false;

  NotificationProvider() {
    _loadNotificationSettings();
  }

  bool get isNotificationEnabled => _isNotificationEnabled;

  Future<void> _loadNotificationSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isNotificationEnabled = prefs.getBool('isNotificationEnabled') ?? false;
    notifyListeners();
  }

  Future<void> toggleNotification() async {
    _isNotificationEnabled = !_isNotificationEnabled;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isNotificationEnabled', _isNotificationEnabled);
    notifyListeners();
  }
}