import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'YOUR_API_URL_HERE'; // À remplacer par l'URL de l'API déployée

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
    final response = await http.post(
      Uri.parse('$baseUrl/api/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return jsonDecode(response.body);
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
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/api/user'),
      headers: headers,
    );
    return jsonDecode(response.body);
  }

  // Companies
  static Future<List<dynamic>> getCompanies() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/api/companies'),
      headers: headers,
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> createCompany(Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/api/companies'),
      headers: headers,
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> updateCompany(int id, Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/api/companies/$id'),
      headers: headers,
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }

  static Future<void> deleteCompany(int id) async {
    final headers = await _getHeaders();
    await http.delete(
      Uri.parse('$baseUrl/api/companies/$id'),
      headers: headers,
    );
  }

  // Posts
  static Future<List<dynamic>> getPosts({String? search}) async {
    final headers = await _getHeaders();
    final uri = search != null
        ? Uri.parse('$baseUrl/api/posts?search=$search')
        : Uri.parse('$baseUrl/api/posts');
    final response = await http.get(uri, headers: headers);
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> createPost(Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/api/posts'),
      headers: headers,
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> updatePost(int id, Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/api/posts/$id'),
      headers: headers,
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }

  static Future<void> deletePost(int id) async {
    final headers = await _getHeaders();
    await http.delete(
      Uri.parse('$baseUrl/api/posts/$id'),
      headers: headers,
    );
  }
}

