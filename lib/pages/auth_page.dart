// lib/pages/auth_page.dart
import 'package:flutter/material.dart';
import 'package:frontcovoiturage/pages/login_page.dart';
import 'package:frontcovoiturage/pages/register_page.dart'; // Assurez-vous d'avoir une page d'inscription

/// Page to authenticate
class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  /// Build the widget
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Authentification'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Login'),
              Tab(text: 'Register'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            LoginPage(),
            RegisterPage(), // Assurez-vous d'avoir une page d'inscription
          ],
        ),
      ),
    );
  }
}