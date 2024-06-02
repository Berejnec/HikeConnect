import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hike_connect/models/hike_event.dart';

void main() {
  test('HikeEvent.fromMap should create a valid HikeEvent object', () {
    // Arrange
    final map = {
      'id': 'eventId',
      'date': Timestamp.fromDate(DateTime(2023, 5, 20)),
      'hikingTrail': {
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
      },
      'participants': [
        {
          'userId': 'userId1',
          'displayName': 'User One',
          'phoneNumber': '123456789',
          'avatarUrl': 'url1',
        },
        {
          'userId': 'userId2',
          'displayName': 'User Two',
          'phoneNumber': '987654321',
          'avatarUrl': 'url2',
        },
      ],
    };

    // Act
    final hikeEvent = HikeEvent.fromMap(map);

    // Assert
    expect(hikeEvent.id, 'eventId');
    expect(hikeEvent.date, DateTime(2023, 5, 20));
    expect(hikeEvent.hikingTrail.routeName, 'Trail Name');
    expect(hikeEvent.hikingTrail.county, 'County Name');
    expect(hikeEvent.participants.length, 2);
    expect(hikeEvent.participants[0].userId, 'userId1');
    expect(hikeEvent.participants[0].displayName, 'User One');
    expect(hikeEvent.participants[0].phoneNumber, '123456789');
    expect(hikeEvent.participants[0].avatarUrl, 'url1');
  });
}
