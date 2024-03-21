// lib/pages/register_page.dart
import 'package:flutter/material.dart';
import 'package:frontcovoiturage/pages/profile_page.dart';
import 'package:frontcovoiturage/services/authentication_service.dart';


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
  final _authService = AuthenticationService();

  // Error message to display
  String? _errorMessage;

  /// Register the user
  void _register() async {
    final login = _loginController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (password != confirmPassword) {
      setState(() {
        _errorMessage = 'Password and confirm password do not match.';
        _passwordController.clear();
        _confirmPasswordController.clear();
      });
      return;
    }

    final result = await _authService.register(login, password);

    if (result == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProfilePage()),
      );
    } else {
      setState(() {
        _errorMessage = result;
      });
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
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
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
