import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  Map<String, dynamic>? _user;
  bool _isAuthenticated = false;

  Map<String, dynamic>? get user => _user;
  bool get isAuthenticated => _isAuthenticated;

  Future<void> checkAuth() async {
    final token = await ApiService.getToken();
    if (token != null) {
      try {
        _user = await ApiService.getUser();
        _isAuthenticated = true;
        notifyListeners();
      } catch (e) {
        _isAuthenticated = false;
        _user = null;
        notifyListeners();
      }
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      final response = await ApiService.login(email, password);
      if (response['token'] != null) {
        await ApiService.saveToken(response['token']);
        _user = response['user'];
        _isAuthenticated = true;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> register(Map<String, dynamic> data) async {
    try {
      final response = await ApiService.register(data);
      if (response['token'] != null) {
        await ApiService.saveToken(response['token']);
        _user = response['user'];
        _isAuthenticated = true;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    await ApiService.logout();
    _user = null;
    _isAuthenticated = false;
    notifyListeners();
  }
}

