// lib/main.dart
import 'package:flutter/material.dart';
import 'package:frontcovoiturage/pages/auth.dart';
import 'package:frontcovoiturage/pages/home.dart';
import 'package:frontcovoiturage/services/authentication_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthenticationService();

    return MaterialApp(
      title: 'Covoiturage Greta de Vannes',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Check if the user is authenticated
      home: FutureBuilder<String?>(
        future: authService.getToken(),
        builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else {
            if (snapshot.data == null) {
              return const AuthPage();
            } else {
              return const HomePage();
            }
          }
        },
      ),
    );
  }
}