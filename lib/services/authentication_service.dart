// lib/services/authentication_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to authenticate users
class AuthenticationService {
  final String baseUrl = "http://127.0.0.1:8000/api";

//   _    _                 _____             _
//  | |  | |               |  __ \           | |
//  | |  | |___  ___ _ __  | |__) |___  _   _| |_ ___
//  | |  | / __|/ _ \ '__| |  _  // _ \| | | | __/ _ \
//  | |__| \__ \  __/ |    | | \ \ (_) | |_| | ||  __/
//   \____/|___/\___|_|    |_|  \_\___/ \__,_|\__\___|

  // todo : changer le retour de la fonction login pour qu'elle retourne une http.Response
  /// Login the user
  Future<bool> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({'login': username, 'password': password}),
    );

    // If the server returns a 200 OK response, then the login was successful
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final token = jsonResponse['token'];
      final user = jsonResponse['user'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setInt('userId', user['id']);
      await prefs.setString('userLogin', user['login']);
      await prefs.setStringList('userRoles', List<String>.from(user['roles']));

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

//  _____                            _____             _
//  |  __ \                          |  __ \           | |
//  | |__) |__ _ __ ___  ___  _ __   | |__) |___  _   _| |_ ___
//  |  ___/ _ \ '__/ __|/ _ \| '_ \  |  _  // _ \| | | | __/ _ \
//  | |  |  __/ |  \__ \ (_) | | | | | | \ \ (_) | |_| | ||  __/
//  |_|   \___|_|  |___/\___/|_| |_| |_|  \_\___/ \__,_|\__\___|

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

  Future<http.Response> updatePersonne(int id, String firstname, String name,
      String email, String phone, int cityId) async {
    String? token = await getToken();

    if (token == null) {
      return http.Response('Unauthorized', 401);
    }

    // Insert the person
    final response = await http.put(
      Uri.parse('$baseUrl/updatepersonne'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        'id': id,
        'firstname': firstname,
        'name': name,
        'email': email,
        'phone': phone,
        'cityId': cityId,
      }),
    );

    return response;
  }

  /// Get the person by the user ID
  Future<Map<String, dynamic>?> getPersonne(int id) async {
    String? token = await getToken();

    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/selectpersonne/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return jsonResponse;
    } else {
      return null;
    }
  }

  //   _______   _         _____             _
  //  |__   __| (_)       |  __ \           | |
  //     | |_ __ _ _ __   | |__) |___  _   _| |_ ___
  //     | | '__| | '_ \  |  _  // _ \| | | | __/ _ \
  //     | | |  | | |_) | | | \ \ (_) | |_| | ||  __/
  //     |_|_|  |_| .__/  |_|  \_\___/ \__,_|\__\___|
  //              | |
  //              |_|

  /// Insert a carpooling trip
  Future<http.Response> insertTrip(int driverId, int startCityId, int endCityId,
      double kmDistance, DateTime travelDate, int placesOffered) async {
    String? token = await getToken();

    if (token == null) {
      return http.Response('Unauthorized', 401);
    }

    // Insert the trip
    final response = await http.post(
      Uri.parse('$baseUrl/inserttrajet'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        'drive_id': driverId,
        'start_id': startCityId,
        'arrive_id': endCityId,
        'kmdistance': kmDistance,
        'traveldate': travelDate.toIso8601String(),
        'placesoffered': placesOffered,
      }),
    );

    return response;
  }

//   /// Get all the trips
// Future<http.Response> getTrips(int userId) async {
//   String? token = await getToken();
//
//   if (token == null) {
//     return http.Response('Unauthorized', 401);
//   }
//
//   // Get the list of trips
//   final response = await http.get(
//     Uri.parse('$baseUrl/listetrajet'),
//     headers: <String, String>{
//       'Content-Type': 'application/json; charset=UTF-8',
//       'Authorization': 'Bearer $token',
//     },
//   );
//
//   if (response.statusCode == 200) {
//     final jsonResponse = jsonDecode(response.body);
//     final trips = jsonResponse.where((trip) => trip['driveId'] == userId).toList();
//     return http.Response(jsonEncode(trips), 200);
//   } else {
//     return response;
//   }
// }
  /// Get driver of a trip
  Future<http.Response> getDriverOnTrip(int tripId) async {
    String? token = await getToken();

    if (token == null) {
      return http.Response('Unauthorized', 401);
    }

    // Get the driver of the trip
    final response = await http.get(
      Uri.parse('$baseUrl/listeinscriptionconducteur/$tripId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    return response;
  }

  /// Get the list of trips for a student
  Future<http.Response> getStudentOnTrips(int studentId) async{
    String? token = await getToken();

    if (token == null) {
      return http.Response('Unauthorized', 401);
    }

    // Get the driver of the trip
    final response = await http.get(
      Uri.parse('$baseUrl/listeinscriptionuser/$studentId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    return response;

  }


//    _____             _____             _
//   / ____|           |  __ \           | |
//  | |     __ _ _ __  | |__) |___  _   _| |_ ___
//  | |    / _` | '__| |  _  // _ \| | | | __/ _ \
//  | |___| (_| | |    | | \ \ (_) | |_| | ||  __/
//   \_____\__,_|_|    |_|  \_\___/ \__,_|\__\___|
//
//

  /// Insert a car
  Future<http.Response> insertCar(String model, String matriculation,
      int places, String brand, int studentId) async {
    String? token = await getToken();

    if (token == null) {
      return http.Response('Unauthorized', 401);
    }

    // Insert the car
    final response = await http.post(
      Uri.parse('$baseUrl/insertvoiture'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        'model': model,
        'matriculation': matriculation,
        'places': places,
        'brand': brand,
        'student': studentId,
      }),
    );

    return response;
  }

  /// Delete a car
  Future<http.Response> deleteCar(int carId) async {
    String? token = await getToken();

    if (token == null) {
      return http.Response('Unauthorized', 401);
    }

    // Delete the car
    final response = await http.delete(
      Uri.parse('$baseUrl/deletevoiture/$carId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    return response;
  }

//    _____ _ _           _____             _
//   / ____(_) |         |  __ \           | |
//  | |     _| |_ _   _  | |__) |___  _   _| |_ ___
//  | |    | | __| | | | |  _  // _ \| | | | __/ _ \
//  | |____| | |_| |_| | | | \ \ (_) | |_| | ||  __/
//   \_____|_|\__|\__, | |_|  \_\___/ \__,_|\__\___|
//                 __/ |
//                |___/

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

//   ____                      _ _____             _
//  |  _ \                    | |  __ \           | |
//  | |_) |_ __ __ _ _ __   __| | |__) |___  _   _| |_ ___
//  |  _ <| '__/ _` | '_ \ / _` |  _  // _ \| | | | __/ _ \
//  | |_) | | | (_| | | | | (_| | | \ \ (_) | |_| | ||  __/
//  |____/|_|  \__,_|_| |_|\__,_|_|  \_\___/ \__,_|\__\___|
//
//

  /// Get the list of brands
  Future<http.Response> getBrands() async {
    // Get the token
    String? token = await getToken();

    // Check if the token is null
    if (token == null) {
      return http.Response('Unauthorized', 401);
    }

    // Get the list of brands
    final response = await http.get(
      Uri.parse('$baseUrl/listemarque'), // Utiliser votre route existante
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    // Return the response directly
    return response;
  }

//   _    _ _   _ _
//  | |  | | | (_) |
//  | |  | | |_ _| |___
//  | |  | | __| | / __|
//  | |__| | |_| | \__ \
//   \____/ \__|_|_|___/

  /// Get the token from the SharedPreferences
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// Logout the user by removing the token from the SharedPreferences
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }
}
