import 'package:flutter_test/flutter_test.dart';
import 'package:hike_connect/models/hiker_user.dart';

void main() {
  group('HikerUser', () {
    test('should convert from Map to HikerUser', () {
      final map = {
        'uid': 'user1',
        'displayName': 'John Doe',
        'email': 'john.doe@example.com',
        'phoneNumber': '1234567890',
        'avatarUrl': 'https://example.com/avatar.jpg',
        'backgroundUrl': 'https://example.com/background.jpg',
        'imageUrls': ['https://example.com/image1.jpg', 'https://example.com/image2.jpg'],
        'favoriteHikingTrails': ['Trail 1', 'Trail 2'],
      };

      final user = HikerUser.fromMap(map);

      expect(user.uid, 'user1');
      expect(user.displayName, 'John Doe');
      expect(user.email, 'john.doe@example.com');
      expect(user.phoneNumber, '1234567890');
      expect(user.avatarUrl, 'https://example.com/avatar.jpg');
      expect(user.backgroundUrl, 'https://example.com/background.jpg');
      expect(user.imageUrls, ['https://example.com/image1.jpg', 'https://example.com/image2.jpg']);
      expect(user.favoriteHikingTrails, ['Trail 1', 'Trail 2']);
    });

    test('should convert from HikerUser to Map', () {
      final user = HikerUser(
        uid: 'user1',
        displayName: 'John Doe',
        email: 'john.doe@example.com',
        phoneNumber: '1234567890',
        avatarUrl: 'https://example.com/avatar.jpg',
        backgroundUrl: 'https://example.com/background.jpg',
        imageUrls: ['https://example.com/image1.jpg', 'https://example.com/image2.jpg'],
        favoriteHikingTrails: ['Trail 1', 'Trail 2'],
      );

      final map = user.toMap();

      expect(map['uid'], 'user1');
      expect(map['displayName'], 'John Doe');
      expect(map['email'], 'john.doe@example.com');
      expect(map['phoneNumber'], '1234567890');
      expect(map['avatarUrl'], 'https://example.com/avatar.jpg');
      expect(map['backgroundUrl'], 'https://example.com/background.jpg');
      expect(map['imageUrls'], ['https://example.com/image1.jpg', 'https://example.com/image2.jpg']);
      expect(map['favoriteHikingTrails'], ['Trail 1', 'Trail 2']);
    });
  });
}
