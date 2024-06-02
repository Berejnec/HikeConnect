import 'package:flutter_test/flutter_test.dart';
import 'package:hike_connect/models/event_participant.dart';

void main() {
  group('EventParticipant', () {
    test('should convert from Map to EventParticipant', () {
      final map = {
        'userId': 'user1',
        'displayName': 'John Doe',
        'phoneNumber': '1234567890',
        'avatarUrl': 'https://example.com/avatar.jpg',
      };

      final participant = EventParticipant.fromMap(map);

      expect(participant.userId, 'user1');
      expect(participant.displayName, 'John Doe');
      expect(participant.phoneNumber, '1234567890');
      expect(participant.avatarUrl, 'https://example.com/avatar.jpg');
    });

    test('should convert from EventParticipant to Map', () {
      final participant = EventParticipant(
        userId: 'user1',
        displayName: 'John Doe',
        phoneNumber: '1234567890',
        avatarUrl: 'https://example.com/avatar.jpg',
      );

      final map = participant.toMap();

      expect(map['userId'], 'user1');
      expect(map['displayName'], 'John Doe');
      expect(map['phoneNumber'], '1234567890');
      expect(map['avatarUrl'], 'https://example.com/avatar.jpg');
    });
  });
}
