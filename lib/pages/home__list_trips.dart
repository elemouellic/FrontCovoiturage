import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontcovoiturage/extensions/string_extension.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';
import 'home___trip_detail.dart';

class AllTripsPage extends StatefulWidget {
  const AllTripsPage({Key? key}) : super(key: key);

  @override
  State<AllTripsPage> createState() => _AllTripsPageState();
}

class _AllTripsPageState extends State<AllTripsPage> {
  List<Map<String, dynamic>>? trips;
  Map<String, dynamic>? user;
  APIService authService = APIService();

  @override
  void initState() {
    super.initState();
    loadUser();
    loadTrips();
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
        }
      }
    }
  }

  Future<void> loadTrips() async {
    final response = await authService.getTrips();
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (mounted) {
        setState(() {
          trips = List<Map<String, dynamic>>.from(data);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: trips?.length ?? 0,
      itemBuilder: (context, index) {
        final trip = trips![index];
        return ListTile(
          leading: const Icon(Icons.drive_eta_rounded),
          title: Row(
            children: [
              Text('${trip['start_city']}'.toString().capitalizeEachWord()),
              const Icon(Icons.arrow_forward),
              Text('${trip['arrive_city']}'.toString().capitalizeEachWord()),
            ],
          ),
          subtitle: Text(
              '${trip['traveldate']} \nConducteur :  ${trip['driver_name']}'),
          trailing: Text('${trip['kmdistance']} kms'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TripDetailsPage(trip: trip, user: user!),
              ),
            );
          },
        );
      },
    );
  }
}
