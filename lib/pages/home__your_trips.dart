import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontcovoiturage/services/authentication_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class UserTripsPage extends StatefulWidget {
  const UserTripsPage({super.key});

  @override
  State<UserTripsPage> createState() => _UserTripsPageState();
}

class _UserTripsPageState extends State<UserTripsPage> {
  Map<String, dynamic>? user;
  AuthenticationService authService = AuthenticationService();
  Future<http.Response>? tripsFuture;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

Future<void> loadUser() async {
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getInt('userId');
  if (userId != null) {
    final fetchedUser = await authService.getPersonne(userId);
    if (fetchedUser != null) {
      if (mounted) {
        setState(() {
          user = fetchedUser;
        });
        // Get the student's ID from the fetched user
        final studentId = fetchedUser['id'];
        // Fetch the student's trips
        tripsFuture = authService.getStudentOnTrips(studentId);
      }
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<http.Response>(
      future: tripsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return const Text('Une erreur est survenue');
        } else if (snapshot.hasData) {
          final response = snapshot.data!;
          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            List trips = [];
            if (data is Map) {
              trips.add(data);
            } else if (data is List) {
              trips = data;
            }
            return ListView.builder(
              itemCount: trips.length,
              itemBuilder: (context, index) {
                final trip = trips[index];
                return ListTile(
                  title: Text('Trajet ${trip['id']}'),
                  // Ajoutez d'autres informations sur le trajet ici
                );
              },
            );
          } else {
            return const Text('Une erreur est survenue');
          }
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}
