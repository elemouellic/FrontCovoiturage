import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontcovoiturage/extensions/string_extension.dart';
import '../services/authentication_service.dart';
import 'home__account__add_car.dart'; // Import the AddCarWidget

class HomeAccount extends StatefulWidget {
  @override
  _HomeAccountState createState() => _HomeAccountState();
}

class _HomeAccountState extends State<HomeAccount> {
  Map<String, dynamic>? user;

  final AuthenticationService authService = AuthenticationService();

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
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const CircularProgressIndicator(); // Show loading indicator while user data is loading
    } else {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: TextEditingController(text: user!['firstname']),
                decoration: const InputDecoration(labelText: 'Prénom'),
                enabled: true,
              ),
              TextField(
                controller: TextEditingController(text: user!['name']),
                decoration: const InputDecoration(labelText: 'Nom'),
                enabled: true,
              ),
              TextField(
                controller: TextEditingController(text: user!['phone']),
                decoration: const InputDecoration(labelText: 'Téléphone'),
                enabled: true,
              ),
              TextField(
                controller: TextEditingController(text: user!['email']),
                decoration: const InputDecoration(labelText: 'Email'),
                enabled: true,
              ),
              TextField(
                controller: TextEditingController(
                    text: user!['city'].toString().capitalizeEachWord()),
                decoration: const InputDecoration(labelText: 'Ville'),
                enabled: true,
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/car'); // todo update student
                },
                child: const Text('Mettre à jour'),
              ),
              if (user!['car'] != null &&
                  user!['brand'] != null &&
                  user!['matriculation'] != null)
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final response =
                            await authService.deleteCar(user!['carId']);
                        if (response.statusCode == 200) {
                          // Handle successful deletion
                          // For example, you can remove the car fields from the UI
                          setState(() {
                            user!.remove('car');
                            user!.remove('brand');
                            user!.remove('matriculation');
                            user!.remove('carId');
                          });
                        } else {
                          // Handle error
                          SnackBar(
                              content: Text(
                                  'Error while deleting the car: ${response.body}'));
                        }
                      },
                      child: const Text('Supprimer voiture'),
                    ),
                    TextField(
                      controller: TextEditingController(text: user!['car']),
                      decoration: const InputDecoration(labelText: 'Voiture'),
                      enabled: false,
                    ),
                    TextField(
                      controller: TextEditingController(text: user!['brand']),
                      decoration: const InputDecoration(labelText: 'Marque'),
                      enabled: false,
                    ),
                    TextField(
                      controller:
                          TextEditingController(text: user!['matriculation']),
                      decoration:
                          const InputDecoration(labelText: 'Immatriculation'),
                      enabled: false,
                    ),
                    TextField(
                      controller: TextEditingController(
                          text: user!['places'].toString()),
                      decoration:
                          const InputDecoration(labelText: 'Nombre de places'),
                      enabled: false,
                    ),
                  ],
                )
              else
                AddCarWidget(
                  authService: authService,
                  onCarAdded: () {
                    // Handle car added
                    // For example, you can reload the user data
                    loadUser();
                  },
                  studentId: user!['id'],
                ),
            ],
          ),
        ),
      );
    }
  }
}
