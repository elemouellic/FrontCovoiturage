import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontcovoiturage/services/api_service.dart';
import 'package:frontcovoiturage/extensions/string_extension.dart';

class TripDetailsPage extends StatelessWidget {
  final authService = APIService();
  final Map<String, dynamic> trip;
  final Map<String, dynamic> user;

  TripDetailsPage({required this.trip, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 350, maxHeight: 400),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                'De : ${trip['start_city']}',
                style: TextStyle(fontSize: 20),
              ),
              Text(
                'À : ${trip['arrive_city']}',
                style: TextStyle(fontSize: 20),
              ),
              Text(
                'Date : ${trip['traveldate']}',
                style: TextStyle(fontSize: 20),
              ),
              Text(
                'Conducteur : ${trip['driver_name']}',
                style: TextStyle(fontSize: 20),
              ),
              Text(
                'Distance : ${trip['kmdistance']} kms',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  http.Response response = await authService.insertInscription(
                      trip['id'], user['id']);
                  var jsonResponse = jsonDecode(response.body);
                  if (response.statusCode == 201) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Réservation effectuée avec succès !'),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            '${jsonResponse['message']}'),
                      ),
                    );
                  }
                },
                child: Text('Réserver'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
