import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hike_connect/models/post.dart';

void main() {
  group('Post', () {
    test('should convert from Post to Map', () {
      final post = Post(
        id: 'post1',
        content: 'Great hike!',
        hikeId: 'hike1',
        imageUrls: ['https://example.com/image1.jpg', 'https://example.com/image2.jpg'],
        likes: 10,
        timestamp: Timestamp.fromDate(DateTime(2023, 1, 1)),
        userId: 'user1',
      );

      final map = post.toMap();

      expect(map['id'], 'post1');
      expect(map['content'], 'Great hike!');
      expect(map['hikeId'], 'hike1');
      expect(map['imageUrls'], ['https://example.com/image1.jpg', 'https://example.com/image2.jpg']);
      expect(map['likes'], 10);
      expect(map['timestamp'], Timestamp.fromDate(DateTime(2023, 1, 1)));
      expect(map['userId'], 'user1');
    });
  });
}
