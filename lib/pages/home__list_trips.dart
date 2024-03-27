import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontcovoiturage/extensions/string_extension.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';

class AllTripsPage extends StatefulWidget {
  const AllTripsPage({super.key});

  @override
  State<AllTripsPage> createState() => _AllTripsPageState();
}

class _AllTripsPageState extends State<AllTripsPage> {
  Map<String, dynamic>? user;
  int? studentId;
  APIService authService = APIService();
  Future<http.Response>? tripsFuture;

  @override
  void initState() {
    super.initState();
    loadUser();
    // Fetch all the trips
    tripsFuture = authService.getTrips();
  }

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    if (userId != null) {
      print('User ID: $userId'); // Debugging line
      final fetchedUser = await authService.getPersonne(userId);
      if (fetchedUser != null) {
        if (mounted) {
          setState(() {
            user = fetchedUser;
          });
          // Get the student's ID from the fetched user
          studentId = fetchedUser['id'];
          print('Student ID: $studentId'); // Debugging line
          // Fetch the student's trips
          tripsFuture = authService.getTrips();
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
                leading: const Icon(Icons.drive_eta_rounded),
                title: Row(
                  children: [
                    Text('${trip['start_city']}'
                        .toString()
                        .capitalizeEachWord()),
                    const Icon(Icons.arrow_forward),
                    Text('${trip['arrive_city']}'
                        .toString()
                        .capitalizeEachWord()),
                  ],
                ),
                subtitle: Text(
                    '${trip['traveldate']} \nConducteur :  ${trip['driver_name']}'),
                trailing: Text('${trip['kmdistance']} kms'),
              );
            },
          );
        } else {
          return const Text(
              'Rien à voir ici pour le moment. Veuillez réessayer plus tard ou contactez le support si le problème persiste');
        }
      } else {
        return const CircularProgressIndicator();
      }
    },
  );
}
}
