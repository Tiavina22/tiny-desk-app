import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tiny_desk/services/auth/auth_service.dart';

class UserService {
  final String _baseUrl = 'http://localhost:8080';

  Future<Map<String, dynamic>?> getUserInfo() async {
    try {
      final token = await AuthService().getToken();

      print(token); 
      
      final response = await http.get(
        Uri.parse('$_baseUrl/user/user-info'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );


      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['user'];
      } else {
        print('Erreur: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Erreur lors de la récupération des infos utilisateur: $e');
      return null;
    }
  }
}
