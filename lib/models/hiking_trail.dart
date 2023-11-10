import 'package:cloud_firestore/cloud_firestore.dart';

class HikingTrail {
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

  HikingTrail({
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
  });

  Map<String, dynamic> toMap() {
    return {
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
    };
  }

  factory HikingTrail.fromMap(Map<String, dynamic> map) {
    return HikingTrail(
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
    );
  }
}
