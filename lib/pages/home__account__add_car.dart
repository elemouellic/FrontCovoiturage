import 'dart:convert';

import 'package:flutter/material.dart';

import '../services/api_service.dart';

class AddCarWidget extends StatefulWidget {
  final AuthenticationService authService;
  final Function onCarAdded;
  final int studentId;

  const AddCarWidget(
      {Key? key,
      required this.authService,
      required this.onCarAdded,
      required this.studentId})
      : super(key: key);

  @override
  _AddCarWidgetState createState() => _AddCarWidgetState();
}

class _AddCarWidgetState extends State<AddCarWidget> {
  final List<TextEditingController> controllers =
      List.generate(3, (index) => TextEditingController());
  String? selectedCarBrands;
  List<String> carBrands = [];

  void addCar() {
    if (controllers.every((controller) => controller.text.isNotEmpty) &&
        selectedCarBrands != null) {
      final model = controllers[0].text;
      final matriculation = controllers[1].text;
      final places = int.parse(controllers[2].text);
      final brand = selectedCarBrands;

      widget.authService
          .insertCar(model, matriculation, places, brand!, widget.studentId)
          .then((response) {
        if (response.statusCode == 200) {
          widget.onCarAdded();
          setState(() {
            controllers.forEach((controller) => controller.clear());
            selectedCarBrands = null;
          });
          Navigator.of(context).pop(); // Close the dialog
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content:
                  Text('Error while inserting the car: ${response.body}')));
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCarBrands();
  }

  void fetchCarBrands() {
    widget.authService.getBrands().then((response) {
      if (response.statusCode == 200) {
        final List<dynamic> brands = jsonDecode(response.body);
        setState(() {
          carBrands = brands.map((e) => e['brand'] as String).toList();
          carBrands.remove('Autre');
          carBrands.sort();
          carBrands.add('Autre');
        });
      }
    });
  }

@override
Widget build(BuildContext context) {
  return ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 350, maxHeight: 400),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween, // Add this
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: controllers[0],
                decoration: const InputDecoration(labelText: 'Modèle'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: controllers[1],
                decoration: const InputDecoration(labelText: 'Immatriculation'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: controllers[2],
                decoration: const InputDecoration(labelText: 'Nombre de places'),
                keyboardType: TextInputType.number,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButtonFormField<String>(
                value: selectedCarBrands,
                decoration: const InputDecoration(labelText: 'Marque'),
                items: carBrands.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCarBrands = newValue;
                  });
                },
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child:
        ElevatedButton(
          onPressed: addCar,
          child: const Text('Ajouter voiture'),
        ),
      ),
      ],
    ),
  );
}}
