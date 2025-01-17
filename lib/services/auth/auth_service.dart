import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tiny_desk/core/config/config.dart';

import 'dart:io' show Process;

class AuthService {
  final String baseUrl = Config.baseUlr;

  // Login service
  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Sauvegarde du token localement
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('authToken', data['token']);

      return data;
    } else {
      final error = jsonDecode(response.body);
      return {
        'success': false,
        'message': error['message'] ?? 'Erreur inconnue',
      };
    }
  }

  // Connexion GitHub
  Future<void> loginWithGitHub() async {
    const url = 'http://localhost:8080/auth/github';

    try {
      await Process.run('xdg-open', [url]);
    } catch (e) {
      throw 'Impossible de lancer $url: $e';
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  Future<Map<String, dynamic>> signup(
      String username, String password, String confirmation) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
        'confirmation': confirmation
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Échec de l\' inscription');
    }
  }
}
