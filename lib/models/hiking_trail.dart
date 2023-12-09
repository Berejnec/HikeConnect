import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HikingTrail {
  String? uuid;
  DateTime dateOfIssue;
  String routeName;
  String administrator;
  String location;
  String county;
  String marking;
  String routeDuration;
  String degreeOfDifficulty;
  String seasonality;
  String equipmentLevelRequested;
  LatLng locationLatLng;

  HikingTrail({
    required this.uuid,
    required this.dateOfIssue,
    required this.routeName,
    required this.administrator,
    required this.location,
    required this.county,
    required this.marking,
    required this.routeDuration,
    required this.degreeOfDifficulty,
    required this.seasonality,
    required this.equipmentLevelRequested,
    required this.locationLatLng,
  });

  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'dateOfIssue': dateOfIssue,
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
        'latitude': locationLatLng.latitude.toDouble(),
        'longitude': locationLatLng.longitude.toDouble(),
      },
    };
  }

  factory HikingTrail.fromMap(Map<String, dynamic> map) {
    return HikingTrail(
      uuid: map['uuid'],
      dateOfIssue: (map['dateOfIssue'] as Timestamp).toDate(),
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
        (map['locationLatLng']['latitude'] as num).toDouble(),
        (map['locationLatLng']['longitude'] as num).toDouble(),
      ),
    );
  }
}
