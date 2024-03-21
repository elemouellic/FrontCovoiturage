// lib/pages/profile_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontcovoiturage/services/authentication_service.dart';
import 'package:frontcovoiturage/extensions/string_extension.dart';
import 'home_page.dart';

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

    if (cityId == null) {
      // Show an error message
      return;
    }

    final success = await _authService.insertPersonne(
        firstname, name, phone, email, cityId);

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      // Show an error message
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
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
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
