import 'package:google_maps_flutter/google_maps_flutter.dart';

class HikingTrail {
  String? id;
  String routeName;
  String administrator;
  String location;
  String county;
  String marking;
  String routeDuration;
  String degreeOfDifficulty;
  String seasonality;
  String equipmentLevelRequested;
  LatLng? locationLatLng;

  HikingTrail({
    required this.id,
    required this.routeName,
    required this.administrator,
    required this.location,
    required this.county,
    required this.marking,
    required this.routeDuration,
    required this.degreeOfDifficulty,
    required this.seasonality,
    required this.equipmentLevelRequested,
    this.locationLatLng,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'routeName': routeName,
      'administrator': administrator,
      'location': location,
      'county': county,
      'marking': marking,
      'routeDuration': routeDuration,
      'degreeOfDifficulty': degreeOfDifficulty,
      'seasonality': seasonality,
      'equipmentLevelRequested': equipmentLevelRequested,
      'locationLatLng': {
        'latitude': locationLatLng?.latitude.toDouble() ?? 45.0,
        'longitude': locationLatLng?.longitude.toDouble() ?? 25.0,
      },
    };
  }

  factory HikingTrail.fromMap(Map<String, dynamic> map) {
    return HikingTrail(
      id: map['id'],
      routeName: map['routeName'],
      administrator: map['administrator'],
      location: map['location'],
      county: map['county'],
      marking: map['marking'],
      routeDuration: map['routeDuration'],
      degreeOfDifficulty: map['degreeOfDifficulty'],
      seasonality: map['seasonality'],
      equipmentLevelRequested: map['equipmentLevelRequested'],
      locationLatLng: LatLng(
        (map['locationLatLng']?['latitude'] as num?)?.toDouble() ?? 0.0,
        (map['locationLatLng']?['longitude'] as num?)?.toDouble() ?? 0.0,
      ),
    );
  }
}
