// lib/pages/auth__login.dart
import 'package:flutter/material.dart';
import 'package:frontcovoiturage/services/api_service.dart';

import 'home.dart';

/// Page to login
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  /// Create the state of the widget
  @override
  LoginPageState createState() => LoginPageState();
}

/// State of the LoginPage
class LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = APIService();

  void _login() async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    final success = await _authService.login(username, password);

    if (success) {
      // Navigate to the home page
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } else {
      // Show an error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid username or password.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

    /// Build the widget
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              ElevatedButton(
                onPressed: _login,
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      );
    }
  }

