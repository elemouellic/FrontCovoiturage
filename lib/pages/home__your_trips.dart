import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontcovoiturage/extensions/string_extension.dart';
import 'package:frontcovoiturage/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class UserTripsPage extends StatefulWidget {
  const UserTripsPage({super.key});

  @override
  State<UserTripsPage> createState() => _UserTripsPageState();
}

class _UserTripsPageState extends State<UserTripsPage> {
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
        tripsFuture = authService.getStudentOnTrips(studentId!);
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
            // Filtrer les trajets où l'utilisateur est le conducteur
            final userTrips =
                trips.where((trip) => trip['drive_id'] == studentId).toList();
            return Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Column(
                  children: [
                    const Text(
                      'Liste des trajets comme passager',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    if (trips.isEmpty)
                      const Text(
                          'Rien à voir ici pour le moment. Veuillez réessayer plus tard ou contactez le support si le problème persiste'),
                    if (trips.isNotEmpty)
                      Expanded(
                        child: ListView.builder(
                          itemCount: trips.length,
                          itemBuilder: (context, index) {
                            final trip = trips[index];
                            return ListTile(
                              leading: const Icon(Icons.drive_eta_rounded),
                              title: Row(
                                children: [
                                  Text('${trip['city_start']}'
                                      .toString()
                                      .capitalizeEachWord()),
                                  const Icon(Icons.arrow_forward),
                                  Text('${trip['city_arrive']}'
                                      .toString()
                                      .capitalizeEachWord()),
                                ],
                              ),
                              subtitle: Text(
                                  '${trip['traveldate']} \nConducteur :  ${trip['name']}'),
                              trailing: Text('${trip['kmdistance']} kms'),
                            );
                          },
                        ),
                      ),
                    const Text(
                      'Liste des trajets comme conducteur',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    if (userTrips.isEmpty)
                      const Text(
                          'Rien à voir ici pour le moment. Veuillez réessayer plus tard ou contactez le support si le problème persiste'),
                    if (userTrips.isNotEmpty)
                      Expanded(
                        child: ListView.builder(
                          itemCount: userTrips.length,
                          itemBuilder: (context, index) {
                            final trip = userTrips[index];
                            return ListTile(
                              leading: const Icon(Icons.drive_eta_rounded),
                              title: Row(
                                children: [
                                  Text('${trip['city_start']}'
                                      .toString()
                                      .capitalizeEachWord()),
                                  const Icon(Icons.arrow_forward),
                                  Text('${trip['city_arrive']}'
                                      .toString()
                                      .capitalizeEachWord()),
                                ],
                              ),
                              subtitle: Text(
                                  '${trip['traveldate']} \nConducteur :  ${user?['name']}'),
                              trailing: Text('${trip['kmdistance']} kms'),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
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
