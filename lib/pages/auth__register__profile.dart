// lib/pages/auth__register__profile.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontcovoiturage/services/authentication_service.dart';
import 'package:frontcovoiturage/extensions/string_extension.dart';
import 'home.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  final _firstnameController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _authService = AuthenticationService();

  List<Map<String, dynamic>> _cities = [];
  Map<String, dynamic>? _selectedCity;

  @override
  void initState() {
    super.initState();
    _loadCities();
  }

  void _loadCities() async {
    final cities = await _authService.getCities();
    setState(() {
      _cities = cities;
    });
  }

  void _insertPersonne() async {
    final firstname = _firstnameController.text;
    final name = _nameController.text;
    final phone = _phoneController.text;
    final email = _emailController.text;
    final cityId = _selectedCity?['id'];

    if (firstname.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez saisir un prénom.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez saisir un nom.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (phone.isEmpty || phone.length < 10 || phone.length > 12) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez saisir un numéro de téléphone valide.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (email.isEmpty || !email.contains('@') || !email.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez saisir un email valide.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (cityId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une ville.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final response = await _authService.insertPersonne(
        firstname, name, phone, email, cityId);

    if (response.statusCode == 201) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } else if (response.statusCode == 409) {
      final responseBody = jsonDecode(response.body);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseBody['message']),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      // Redirect to the profile page
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfilePage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _firstnameController,
              decoration: const InputDecoration(labelText: 'First Name'),
            ),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone'),
              keyboardType: TextInputType.phone,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            Autocomplete<Map<String, dynamic>>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<Map<String, dynamic>>.empty();
                }

                return _cities.where((Map<String, dynamic> city) {
                  return city['zipcode']
                      .toString()
                      .startsWith(textEditingValue.text);
                });
              },
              displayStringForOption: (Map<String, dynamic> option) =>
                  '${option['name'].toString().capitalizeEachWord()} (${option['zipcode']})',
              onSelected: (Map<String, dynamic> selection) {
                _selectedCity = selection;
              },
              fieldViewBuilder: (BuildContext context,
                  TextEditingController fieldTextEditingController,
                  FocusNode fieldFocusNode,
                  VoidCallback onFieldSubmitted) {
                return TextField(
                  controller: fieldTextEditingController,
                  focusNode: fieldFocusNode,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  decoration: const InputDecoration(
                    hintText: 'Code postal',
                  ),
                  onSubmitted: (String value) {
                    onFieldSubmitted();
                  },
                );
              },
            ),
            ElevatedButton(
              onPressed: _insertPersonne,
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
