import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> login(String email, String password) async {
    try {
      _errorMessage = null;
      final response = await ApiService.login(email, password);
      
      debugPrint('Réponse API login: $response');
      
      final token = response['token'];
      debugPrint('Token extrait login: ${token != null ? "présent (${token.runtimeType})" : "null"}');
      
      if (token != null && token.toString().isNotEmpty) {
        await ApiService.saveToken(token.toString());
        debugPrint('Token sauvegardé avec succès');
        
        // Récupérer l'utilisateur
        if (response.containsKey('user') && response['user'] != null) {
          final userData = response['user'];
          if (userData is Map<String, dynamic>) {
            _user = userData;
          } else if (userData is Map) {
            _user = Map<String, dynamic>.from(userData);
          }
          debugPrint('Utilisateur récupéré: ${_user?['email'] ?? 'email non trouvé'}');
        }
        
        _isAuthenticated = true;
        notifyListeners();
        debugPrint('Authentification réussie');
        return true;
      }
      
      _errorMessage = 'Token manquant dans la réponse. Clés disponibles: ${response.keys.join(", ")}';
      debugPrint('Erreur login: $_errorMessage');
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      debugPrint('Exception login: $_errorMessage');
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(Map<String, dynamic> data) async {
    try {
      _errorMessage = null;
      final response = await ApiService.register(data);
      
      // Debug: afficher la réponse complète
      debugPrint('Réponse API register: $response');
      
      // Vérifier si le token existe
      final token = response['token'];
      debugPrint('Token extrait: ${token != null ? "présent (${token.runtimeType})" : "null"}');
      
      if (token != null && token.toString().isNotEmpty) {
        await ApiService.saveToken(token.toString());
        debugPrint('Token sauvegardé avec succès');
        
        // Récupérer l'utilisateur
        if (response.containsKey('user') && response['user'] != null) {
          final userData = response['user'];
          if (userData is Map<String, dynamic>) {
            _user = userData;
          } else if (userData is Map) {
            _user = Map<String, dynamic>.from(userData);
          }
          debugPrint('Utilisateur récupéré: ${_user?['email'] ?? 'email non trouvé'}');
        } else {
          debugPrint('Avertissement: Pas de données utilisateur dans la réponse');
        }
        
        _isAuthenticated = true;
        notifyListeners();
        debugPrint('Authentification réussie');
        return true;
      }
      
      // Si pas de token, vérifier s'il y a un message d'erreur
      if (response.containsKey('message')) {
        _errorMessage = response['message'].toString();
      } else {
        _errorMessage = 'Token manquant dans la réponse. Clés disponibles: ${response.keys.join(", ")}';
      }
      debugPrint('Erreur register: $_errorMessage');
      debugPrint('Réponse complète: $response');
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      debugPrint('Exception register: $_errorMessage');
      notifyListeners();
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

