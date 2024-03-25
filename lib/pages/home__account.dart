import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontcovoiturage/extensions/string_extension.dart';
import '../services/authentication_service.dart';

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
        setState(() {
          user = fetchedUser;
        });
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
                controller: TextEditingController(text: user!['city'].toString().capitalizeEachWord()),
                decoration: const InputDecoration(labelText: 'Ville'),
                enabled: true,
              ),
              TextField(
                controller: TextEditingController(
                    text: user!['car'] ?? 'Non renseigné'),
                decoration: const InputDecoration(labelText: 'Voiture'),
                enabled: true,
              ),
            ],
          ),
        ),
      );
    }
  }
}
