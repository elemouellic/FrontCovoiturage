// lib/services/authentication_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to authenticate users
class AuthenticationService {
  final String baseUrl =
      "http://127.0.0.1:8000/api"; // Replace with your Symfony API URL

  /// Login the user
  Future<bool> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      body: {'username': username, 'password': password},
    );

    // If the server returns a 200 OK response, then the login was successful
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

  /// Register a new user
  Future<String?> register(String login, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'login': login, 'password': password}),
    );

    // If the server returns a 201 Created response, then the registration was successful
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

  /// Insert a new person
  Future<http.Response> insertPersonne(String firstname, String name,
      String phone, String email, int cityId) async {
    String? token = await getToken();

    if (token == null) {
      return http.Response('Unauthorized', 401);
    }

    // Insert the person
    final response = await http.post(
      Uri.parse('$baseUrl/insertpersonne'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        'firstname': firstname,
        'name': name,
        'phone': phone,
        'email': email,
        'cityId': cityId,
      }),
    );

    return response;
  }

  /// Get the list of cities
  Future<List<Map<String, dynamic>>> getCities() async {
    // Get the token
    String? token = await getToken();

    // Check if the token is null
    if (token == null) {
      return [];
    }

    // Get the list of cities
    final response = await http.get(
      Uri.parse('$baseUrl/listeville'), // Utiliser votre route existante
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    // If the server returns a 200 OK response, then the request was successful
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final cities = jsonResponse
          .map<Map<String, dynamic>>((city) => {
                'id': city['id'],
                'name': city['name'],
                'zipcode': city['zipcode']
              })
          .toList(); // Extract the list of cities
      return cities;
    } else {
      return [];
    }
  }

  /// Get the token from the SharedPreferences
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}
