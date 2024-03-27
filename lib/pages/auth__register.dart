// lib/pages/auth__register.dart
import 'package:flutter/material.dart';
import 'package:frontcovoiturage/pages/auth__register__profile.dart';
import 'package:frontcovoiturage/services/api_service.dart';

/// Page to register a new user
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  RegisterPageState createState() => RegisterPageState();
}

/// State of the RegisterPage
class RegisterPageState extends State<RegisterPage> {
  // Controllers for the text fields
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = APIService();

  // Error message to display
  String? _errorMessage;

  /// Register the user
void _register() async {
  final login = _loginController.text;
  final password = _passwordController.text;
  final confirmPassword = _confirmPasswordController.text;

  if (password != confirmPassword) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Les mots de passe ne correspondent pas.'),
      ),
    );
    _passwordController.clear();
    _confirmPasswordController.clear();
    return;
  }

  final result = await _authService.register(login, password);

  if (result == null) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ProfilePage()),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result),
      ),
    );
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
              controller: _loginController,
              decoration: const InputDecoration(labelText: 'Login'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            TextField(
              controller: _confirmPasswordController,
              decoration: const InputDecoration(labelText: 'Confirm Password'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: _register,
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
