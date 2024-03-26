import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:frontcovoiturage/services/authentication_service.dart';
import 'package:frontcovoiturage/extensions/string_extension.dart';

class UpdateProfileWidget extends StatefulWidget {
  final AuthenticationService authService;
  final Function onProfileUpdated;
  final int userId;
  final int ?carId;

  const UpdateProfileWidget({
    Key? key,
    required this.authService,
    required this.onProfileUpdated,
    required this.userId,
    this.carId,
  }) : super(key: key);

  @override
  _UpdateProfileWidgetState createState() => _UpdateProfileWidgetState();
}

class _UpdateProfileWidgetState extends State<UpdateProfileWidget> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cityIdController = TextEditingController();

  List<Map<String, dynamic>> _cities = [];
  Map<String, dynamic>? _selectedCity;

  @override
  void initState() {
    super.initState();
    _loadCities();
  }

  void _loadCities() async {
    final cities = await widget.authService.getCities();
    setState(() {
      _cities = cities;
    });
  }

  void updateUserProfile() {
    final firstName = _firstNameController.text;
    final lastName = _lastNameController.text;
    final email = _emailController.text;
    final phone = _phoneController.text;
    final cityId = int.parse(_cityIdController.text); // Convert cityId to int

    widget.authService
        .updatePersonne(
            widget.userId, firstName, lastName, email, phone, cityId)
        .then((response) {
      if (response.statusCode == 200) {
        widget.onProfileUpdated();
        Navigator.of(context).pop(); // Close the dialog
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text('Error while updating the profile: ${response.body}')));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 350, maxHeight: 450),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(labelText: 'Prénom'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(labelText: 'Nom'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Téléphone'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Autocomplete<Map<String, dynamic>>(
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
                    _cityIdController.text = selection['id'].toString();
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
              ),
            ],
          ),
          ElevatedButton(
            onPressed: updateUserProfile,
            child: const Text('Mettre à jour profil'),
          ),
        ],
      ),
    );
  }
}
