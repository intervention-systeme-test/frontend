import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://web-production-84e92.up.railway.app'; // API déployée sur Railway

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  static Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Auth
  static Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/register'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode(data),
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        final body = response.body;
        debugPrint('Réponse register brute: $body');
        final decoded = jsonDecode(body) as Map<String, dynamic>;
        debugPrint('Réponse register décodée: $decoded');
        debugPrint('Token présent: ${decoded.containsKey('token')}');
        return decoded;
      } else if (response.statusCode == 422) {
        // Erreur de validation
        try {
          final errorBody = jsonDecode(response.body);
          if (errorBody['errors'] != null) {
            final errors = errorBody['errors'] as Map<String, dynamic>;
            final firstError = errors.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              throw Exception(firstError[0]);
            }
          }
          throw Exception(errorBody['message'] ?? 'Erreur de validation');
        } catch (e) {
          if (e is Exception) rethrow;
          throw Exception('Erreur de validation');
        }
      } else if (response.statusCode == 500) {
        // Essayer d'extraire le message d'erreur de la réponse
        debugPrint('Erreur 500 - Status: ${response.statusCode}');
        debugPrint('Erreur 500 - Headers: ${response.headers}');
        debugPrint('Erreur 500 - Body: ${response.body}');
        
        try {
          final errorBody = jsonDecode(response.body);
          final errorMsg = errorBody['message'] ?? 
                          errorBody['error'] ?? 
                          errorBody['exception'] ??
                          'Erreur serveur (500)';
          throw Exception('Erreur serveur: $errorMsg');
        } catch (e) {
          if (e is Exception && !e.toString().contains('Erreur serveur:')) {
            // Si ce n'est pas notre exception, c'est une erreur de décodage
            final bodyPreview = response.body.length > 300 
                ? '${response.body.substring(0, 300)}...' 
                : response.body;
            throw Exception('Erreur serveur (500). Détails: $bodyPreview');
          }
          rethrow;
        }
      } else {
        try {
          final errorBody = jsonDecode(response.body);
          throw Exception(errorBody['message'] ?? 'Erreur lors de l\'inscription (code ${response.statusCode})');
        } catch (e) {
          if (e is Exception) rethrow;
          throw Exception('Erreur lors de l\'inscription (code ${response.statusCode})');
        }
      }
    } on SocketException catch (e) {
      throw Exception('Erreur de connexion réseau: Impossible de se connecter au serveur');
    } on HttpException catch (e) {
      throw Exception('Erreur HTTP: ${e.message}');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Erreur inattendue: ${e.toString()}');
    }
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/login'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      
      if (response.statusCode == 200) {
        final body = response.body;
        debugPrint('Réponse login brute: $body');
        try {
          final decoded = jsonDecode(body) as Map<String, dynamic>;
          debugPrint('Réponse login décodée: $decoded');
          debugPrint('Token présent: ${decoded.containsKey('token')}');
          return decoded;
        } catch (e) {
          debugPrint('Erreur décodage JSON login: $e');
          throw Exception('Réponse invalide du serveur');
        }
      } else if (response.statusCode == 422) {
        // Erreur de validation
        try {
          final errorBody = jsonDecode(response.body);
          if (errorBody['errors'] != null) {
            final errors = errorBody['errors'] as Map<String, dynamic>;
            final firstError = errors.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              throw Exception(firstError[0]);
            }
          }
          throw Exception(errorBody['message'] ?? 'Email ou mot de passe incorrect');
        } catch (e) {
          if (e is Exception) rethrow;
          throw Exception('Email ou mot de passe incorrect');
        }
      } else if (response.statusCode == 500) {
        debugPrint('Erreur 500 login - Status: ${response.statusCode}');
        debugPrint('Erreur 500 login - Body: ${response.body}');
        try {
          final errorBody = jsonDecode(response.body);
          final errorMsg = errorBody['message'] ?? 
                          errorBody['error'] ?? 
                          'Erreur serveur (500)';
          throw Exception('Erreur serveur: $errorMsg');
        } catch (e) {
          if (e is Exception && !e.toString().contains('Erreur serveur:')) {
            final bodyPreview = response.body.length > 300 
                ? '${response.body.substring(0, 300)}...' 
                : response.body;
            throw Exception('Erreur serveur (500). Détails: $bodyPreview');
          }
          rethrow;
        }
      } else {
        try {
          final errorBody = jsonDecode(response.body);
          throw Exception(errorBody['message'] ?? 'Email ou mot de passe incorrect');
        } catch (e) {
          if (e is Exception) rethrow;
          throw Exception('Erreur de connexion (code ${response.statusCode})');
        }
      }
    } on SocketException catch (e) {
      throw Exception('Erreur de connexion réseau: Impossible de se connecter au serveur');
    } on HttpException catch (e) {
      throw Exception('Erreur HTTP: ${e.message}');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Erreur inattendue: ${e.toString()}');
    }
  }

  static Future<void> logout() async {
    final headers = await _getHeaders();
    await http.post(
      Uri.parse('$baseUrl/api/logout'),
      headers: headers,
    );
    await removeToken();
  }

  static Future<Map<String, dynamic>> getUser() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/user'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 401) {
        await removeToken();
        throw Exception('Session expirée. Veuillez vous reconnecter.');
      } else {
        throw Exception('Erreur lors de la récupération du profil');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Erreur de connexion: ${e.toString()}');
    }
  }

  // Companies
  static Future<List<dynamic>> getCompanies() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/companies'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        throw Exception('Erreur lors de la récupération des entreprises');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Erreur de connexion: ${e.toString()}');
    }
  }

  static Future<Map<String, dynamic>> createCompany(Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/companies'),
        headers: headers,
        body: jsonEncode(data),
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Erreur lors de la création de l\'entreprise');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Erreur de connexion: ${e.toString()}');
    }
  }

  static Future<Map<String, dynamic>> updateCompany(int id, Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/api/companies/$id'),
        headers: headers,
        body: jsonEncode(data),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Erreur lors de la modification de l\'entreprise');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Erreur de connexion: ${e.toString()}');
    }
  }

  static Future<void> deleteCompany(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/api/companies/$id'),
        headers: headers,
      );
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Erreur lors de la suppression de l\'entreprise');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Erreur de connexion: ${e.toString()}');
    }
  }

  // Posts
  static Future<List<dynamic>> getPosts({String? search}) async {
    try {
      final headers = await _getHeaders();
      final uri = search != null
          ? Uri.parse('$baseUrl/api/posts?search=${Uri.encodeComponent(search)}')
          : Uri.parse('$baseUrl/api/posts');
      final response = await http.get(uri, headers: headers);
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        throw Exception('Erreur lors de la récupération des publications');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Erreur de connexion: ${e.toString()}');
    }
  }

  static Future<Map<String, dynamic>> createPost(Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/posts'),
        headers: headers,
        body: jsonEncode(data),
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Erreur lors de la création de la publication');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Erreur de connexion: ${e.toString()}');
    }
  }

  static Future<Map<String, dynamic>> updatePost(int id, Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/api/posts/$id'),
        headers: headers,
        body: jsonEncode(data),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Erreur lors de la modification de la publication');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Erreur de connexion: ${e.toString()}');
    }
  }

  static Future<void> deletePost(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/api/posts/$id'),
        headers: headers,
      );
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Erreur lors de la suppression de la publication');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Erreur de connexion: ${e.toString()}');
    }
  }
}

