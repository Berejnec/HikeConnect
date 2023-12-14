import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hike_connect/models/hiking_trail.dart';

class HikingTrailForm extends StatefulWidget {
  const HikingTrailForm({super.key});

  @override
  State<HikingTrailForm> createState() => _HikingTrailFormState();
}

class _HikingTrailFormState extends State<HikingTrailForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController routeNameController = TextEditingController();
  final TextEditingController administratorController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController countyController = TextEditingController();
  final TextEditingController markingController = TextEditingController();
  final TextEditingController routeDurationController = TextEditingController();
  final TextEditingController degreeOfDifficultyController = TextEditingController();
  final TextEditingController seasonalityController = TextEditingController();
  final TextEditingController equipmentLevelController = TextEditingController();
  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adauga traseu'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: routeNameController,
                decoration: const InputDecoration(labelText: 'Route Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a route name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: administratorController,
                decoration: const InputDecoration(labelText: 'Administrator'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an administrator';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Location'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a location';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: countyController,
                decoration: const InputDecoration(labelText: 'County'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a county';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: markingController,
                decoration: const InputDecoration(labelText: 'Marking'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a marking';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: routeDurationController,
                decoration: const InputDecoration(labelText: 'Route Duration'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the route duration';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: degreeOfDifficultyController,
                decoration: const InputDecoration(labelText: 'Degree of Difficulty'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the degree of difficulty';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: seasonalityController,
                decoration: const InputDecoration(labelText: 'Seasonality'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter seasonality information';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: equipmentLevelController,
                decoration: const InputDecoration(labelText: 'Equipment Level Requested'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter equipment level information';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: latitudeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Latitude'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a latitude';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: longitudeController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(labelText: 'Longitude'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a longitude';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    saveHikingTrail();
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> saveHikingTrail() async {
    HikingTrail newTrail = HikingTrail(
      uuid: '',
      dateOfIssue: DateTime.now(),
      routeName: routeNameController.text,
      administrator: administratorController.text,
      location: locationController.text,
      county: countyController.text,
      marking: markingController.text,
      routeDuration: routeDurationController.text,
      degreeOfDifficulty: degreeOfDifficultyController.text,
      seasonality: seasonalityController.text,
      equipmentLevelRequested: equipmentLevelController.text,
      locationLatLng: LatLng(
        double.parse(latitudeController.text),
        double.parse(longitudeController.text),
      ),
    );

    try {
      await FirebaseFirestore.instance.collection('hikingTrails').add(newTrail.toMap());
      print('Hiking trail added successfully');
    } catch (e) {
      print('Error adding hiking trail: $e');
    }
  }
}
