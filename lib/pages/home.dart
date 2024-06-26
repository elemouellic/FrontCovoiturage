// lib/pages/home.dart
import 'package:flutter/material.dart';
import 'package:frontcovoiturage/pages/home__search_trip.dart';
import 'package:frontcovoiturage/pages/home__account.dart';
import 'package:frontcovoiturage/pages/home__publish_trip.dart';
import 'package:frontcovoiturage/pages/home__your_trips.dart';
import 'package:frontcovoiturage/services/api_service.dart';
import 'package:frontcovoiturage/pages/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth__register__profile.dart';
import 'home__list_trips.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isDriver = false;

  Widget currentWidget = const Center(
    child: SizedBox(
      width: 250.0,
      height: 100.0,
      child: Center(
        child: Text(
            'Bienvenue sur l\'application de covoiturage du Greta de Vannes',
            softWrap: true,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20.0,
            )),
      ),
    ),
  );

  // Create an instance of the AuthenticationService
  final authService = APIService();

  // Attribute to store the username
  String? username = "...";

  @override
  void initState() {
    super.initState();
    loadUser();
  }

Future<void> loadUser() async {
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getInt('userId');
  if (userId != null) {
    final user = await authService.getPersonne(userId);
    if (user == null) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfilePage()),
        );
      }
    } else {
      if (mounted) {
        setState(() {
          username = user['firstname'];
          isDriver = user['car'] != null;
        });
      }
    }
  }
}  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: username == '...'
            ? const CircularProgressIndicator()
            : Text("Bienvenue $username"),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AuthPage()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.bus_alert),
              title: const Text('Liste des trajets'),
              onTap: () {
                setState(() {
                  currentWidget = const AllTripsPage();
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.directions_car),
              title: const Text('Rechercher un trajet'),
              onTap: () {
                setState(() {
                  currentWidget = const HomeSearch();
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Vos trajets'),
              onTap: () {
                setState(() {
                  currentWidget = const UserTripsPage();
                });
                Navigator.pop(context);
              },
            ),
            if (isDriver) ...[
              ListTile(
                leading: const Icon(Icons.list_alt_sharp),
                title: const Text('Publier un trajet'),
                onTap: () {
                  setState(() {
                    currentWidget = const HomeTrip();
                  });
                  Navigator.pop(context);
                },
              ),
            ],
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Mon compte'),
              onTap: () {
                setState(() {
                  currentWidget = HomeAccount();
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: currentWidget,
    );
  }
}
