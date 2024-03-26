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
              Icon(
                Icons.account_circle,
                size: 100,
              ),
              Text(
                'Prénom: ${user!['firstname']}',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                'Nom: ${user!['name']}',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                'Téléphone: ${user!['phone']}',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                'Email: ${user!['email']}',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                'Ville: ${user!['city'].toString().capitalizeEachWord()}',
                style: TextStyle(fontSize: 16),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/car'); // todo update student
                },
                child: const Text('Mettre à jour profil'),
              ),
              if (user!['car'] != null &&
                  user!['brand'] != null &&
                  user!['matriculation'] != null)
                Column(
                  children: [
                    Icon(
                      Icons.directions_car,
                      size: 100,
                    ),
                    Text(
                      'Voiture: ${user!['car']}',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Marque: ${user!['brand']}',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Immatriculation: ${user!['matriculation']}',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Nombre de places: ${user!['places'].toString()}',
                      style: TextStyle(fontSize: 16),
                    ),
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
                  ],
                )
              else
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                          child: AddCarWidget(
                            authService: authService,
                            onCarAdded: () {
                              loadUser();
                            },
                            studentId: user!['id'],
                          ),
                        );
                      },
                    );
                  },
                  child: const Text('Ajouter voiture'),
                ),
            ],
          ),
        ),
      );
    }
  }
}
