// lib/pages/auth.dart
import 'package:flutter/material.dart';
import 'package:frontcovoiturage/pages/auth__login.dart';
import 'package:frontcovoiturage/pages/auth__register.dart';

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
            RegisterPage(),
          ],
        ),
      ),
    );
  }
}