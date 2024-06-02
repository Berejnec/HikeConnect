import 'package:flutter_test/flutter_test.dart';
import 'package:hike_connect/models/hiking_trail.dart';

void main() {
  test('HikingTrail.fromMap should create a valid HikingTrail object', () {
    // Arrange
    final map = {
      'id': 'trailId',
      'routeName': 'Trail Name',
      'administrator': 'Administrator Name',
      'location': 'Location Name',
      'county': 'County Name',
      'marking': 'Marking',
      'routeDuration': '2 hours',
      'degreeOfDifficulty': 'Medium',
      'seasonality': 'All year',
      'equipmentLevelRequested': 'Basic',
      'locationLatLng': {
        'latitude': 45.0,
        'longitude': 25.0,
      },
    };

    // Act
    final hikingTrail = HikingTrail.fromMap(map);

    // Assert
    expect(hikingTrail.id, 'trailId');
    expect(hikingTrail.routeName, 'Trail Name');
    expect(hikingTrail.administrator, 'Administrator Name');
    expect(hikingTrail.location, 'Location Name');
    expect(hikingTrail.county, 'County Name');
    expect(hikingTrail.marking, 'Marking');
    expect(hikingTrail.routeDuration, '2 hours');
    expect(hikingTrail.degreeOfDifficulty, 'Medium');
    expect(hikingTrail.seasonality, 'All year');
    expect(hikingTrail.equipmentLevelRequested, 'Basic');
    expect(hikingTrail.locationLatLng?.latitude, 45.0);
    expect(hikingTrail.locationLatLng?.longitude, 25.0);
  });
}
