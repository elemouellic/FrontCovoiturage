// lib/services/authentication_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationService {
  final String baseUrl =
      "http://127.0.0.1:8000/api"; // Replace with your Symfony API URL

  Future<bool> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      body: {'username': username, 'password': password},
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final token = jsonResponse['token'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);

      return true;
    } else {
      return false;
    }
  }

  Future<String?> register(String login, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'login': login, 'password': password}),
    );

    if (response.statusCode == 201) {
      final jsonResponse = jsonDecode(response.body);
      final token = jsonResponse['token'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);

      return null;
    } else if (response.statusCode == 400) {
      final jsonResponse = jsonDecode(response.body);
      final message = jsonResponse['message'];

      return message;
    } else {
      return 'An unknown error occurred.';
    }
  }

  Future<bool> insertPersonne(String firstname, String name, String phone,
      String email, int cityId) async {
    // Récupérer le token
    String? token = await getToken();

    // Vérifier si le token est null
    if (token == null) {
      print('Token is null');
      return false;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/insertpersonne'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
        // Ajouter le token à l'en-tête de la requête
      },
      body: jsonEncode(<String, dynamic>{
        'firstname': firstname,
        'name': name,
        'phone': phone,
        'email': email,
        'cityId': cityId,
      }),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }

Future<List<Map<String, dynamic>>> getCities() async {
  // Récupérer le token
  String? token = await getToken();

  // Vérifier si le token est null
  if (token == null) {
    print('Token is null');
    return [];
  }

  final response = await http.get(
    Uri.parse('$baseUrl/listeville'), // Utiliser votre route existante
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    final cities = jsonResponse.map<Map<String, dynamic>>((city) => {'id': city['id'], 'name': city['name'], 'zipcode': city['zipcode']}).toList(); // Extraire les id, noms et codes postaux des villes
    return cities;
  } else {
    return [];
  }
}  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}
