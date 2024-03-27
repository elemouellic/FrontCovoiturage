import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:frontcovoiturage/services/api_service.dart';
import 'package:frontcovoiturage/extensions/string_extension.dart';

class HomeSearch extends StatefulWidget {
  const HomeSearch({Key? key}) : super(key: key);

  @override
  State<HomeSearch> createState() => _HomeSearchState();
}

class _HomeSearchState extends State<HomeSearch> {
  final _authService = AuthenticationService();
  Map<String, dynamic>? _selectedStartCity;
  Map<String, dynamic>? _selectedEndCity;
  DateTime _travelDate = DateTime.now();
  List<Map<String, dynamic>> _cities = [];
  List<Map<String, dynamic>> _trips = [];

  @override
  void initState() {
    super.initState();
    _loadCities();
  }

  Future<void> _loadCities() async {
    final cities = await _authService.getCities();
    setState(() {
      _cities = cities;
    });
  }

  void _searchTrips() async {
    if (_selectedStartCity != null && _selectedEndCity != null) {
      http.Response response = await _authService.searchTrip(
          _selectedStartCity!['id'], _selectedEndCity!['id'], _travelDate);
      if (response.statusCode == 200) {
        // La requête a réussi, vous pouvez maintenant traiter la réponse
        List<dynamic> trips = jsonDecode(response.body);
        // Affichez les trajets ici
        // Vous pouvez les afficher dans une ListView par exemple
        setState(() {
          _trips = trips.cast<Map<String, dynamic>>();
        });
      } else if (response.statusCode == 404) {
        // La requête a échoué avec une erreur 404, affichez un Snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Aucun trajet trouvé pour les critères sélectionnés.'),
          ),
        );
      } else {
        // La requête a échoué avec une autre erreur, affichez un Snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Une erreur est survenue lors de la recherche de trajets.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recherche de trajets'),
      ),
      body: Column(
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
          // Autocomplete pour la ville d'arrivée
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

// DatePicker pour la date de voyage
          TextFormField(
            readOnly: true,
            controller: TextEditingController()
              ..text = DateFormat('yyyy-MM-dd').format(_travelDate),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _travelDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) {
                setState(() {
                  _travelDate = DateTime(
                    date.year,
                    date.month,
                    date.day,
                  );
                });
              }
            },
            decoration: const InputDecoration(
              labelText: 'Date du voyage',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez sélectionner une date';
              }
              return null;
            },
          ),
          ElevatedButton(
            onPressed: _searchTrips,
            child: const Text('Rechercher des trajets'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _trips.length,
              itemBuilder: (context, index) {
                final trip = _trips[index];
                return ListTile(
                  leading: const Icon(Icons.drive_eta_rounded),
                  title: Row(
                    children: [
                      Text('${trip['start_city']}'
                          .toString()
                          .capitalizeEachWord()),
                      const Icon(Icons.arrow_forward),
                      Text('${trip['arrive_city']}'
                          .toString()
                          .capitalizeEachWord()),
                    ],
                  ),
                  subtitle: Text(
                      '${trip['traveldate']} \nConducteur :  ${trip?['driver_name']}'),
                  trailing: Text('${trip['kmdistance']} kms'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
