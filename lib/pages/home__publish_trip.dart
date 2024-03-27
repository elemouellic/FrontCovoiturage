// lib/pages/home_trip.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontcovoiturage/services/authentication_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:frontcovoiturage/extensions/string_extension.dart';

class HomeTrip extends StatefulWidget {
  const HomeTrip({super.key});

  @override
  _HomeTripState createState() => _HomeTripState();
}

class _HomeTripState extends State<HomeTrip> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthenticationService();
  List<Map<String, dynamic>> _cities = [];
  int? _driverId;
  Map<String, dynamic>? _selectedStartCity;
  Map<String, dynamic>? _selectedEndCity;
  double? _kmDistance;
  DateTime _travelDate = DateTime.now();
  int? _placesOffered;

  @override
  void initState() {
    super.initState();
    _loadCities();
    _loadUser();
  }

  Future<void> _loadCities() async {
    final cities = await _authService.getCities();
    setState(() {
      _cities = cities;
    });
  }

Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    if (userId != null) {
      final fetchedUser = await _authService.getPersonne(userId);
      if (fetchedUser != null) {
        if (mounted) { // Check if the widget is still in the widget tree
          setState(() {
            _driverId = fetchedUser['id'] as int?;
          });
        }
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
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
              _selectedStartCity = selection;
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
                  hintText: 'Code postal de départ',
                ),
                onSubmitted: (String value) {
                  onFieldSubmitted();
                },
              );
            },
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
              _selectedEndCity = selection;
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
                  hintText: 'Code postal d\'arrivée',
                ),
                onSubmitted: (String value) {
                  onFieldSubmitted();
                },
              );
            },
          ),
          TextFormField(
            keyboardType: TextInputType.number,
            onChanged: (value) {
              _kmDistance = double.parse(value);
            },
            decoration: const InputDecoration(
              labelText: 'Distance en km',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer une distance';
              }
              return null;
            },
          ),
TextFormField(
  readOnly: true,
  controller: TextEditingController()
    ..text = DateFormat('yyyy-MM-dd HH:mm:ss').format(_travelDate),
  onTap: () async {
    final date = await showDatePicker(
      context: context,
      initialDate: _travelDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_travelDate),
      );
      if (time != null) {
        setState(() {
          _travelDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  },
  decoration: const InputDecoration(
    labelText: 'Date et heure du voyage',
  ),
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez sélectionner une date et une heure';
    }
    return null;
  },
),
          TextFormField(
            keyboardType: TextInputType.number,
            onChanged: (value) {
              _placesOffered = int.parse(value);
            },
            decoration: const InputDecoration(
              labelText: 'Places offertes',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer le nombre de places offertes';
              }
              return null;
            },
          ),
          ElevatedButton(
            onPressed: () {
              // if (_formKey.currentState!.validate()) {
                // Call the insertTrip method with the form values
                _authService.insertTrip(
                  _driverId!,
                  _selectedStartCity!['id'],
                  _selectedEndCity!['id'],
                  _kmDistance!, // This should be a double
                  _travelDate, // This should be a DateTime
                  _placesOffered!,
                );
              },
            // },
            child: const Text('Insérer un trajet'),
          ),
        ],
      ),
    );
  }
}
