import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String? id;
  final String content;
  final String hikeId;
  final List<String> imageUrls;
  final int likes;
  final Timestamp timestamp;
  final String userId;

  Post({
    this.id,
    required this.content,
    required this.hikeId,
    required this.imageUrls,
    required this.likes,
    required this.timestamp,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'hikeId': hikeId,
      'imageUrls': imageUrls,
      'likes': likes,
      'timestamp': timestamp,
      'userId': userId,
      'id': id,
    };
  }

  factory Post.fromMap(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return Post(
      id: snapshot.id,
      content: data['content'] ?? '',
      hikeId: data['hikeId'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      likes: data['likes'] ?? 0,
      timestamp: data['timestamp'] ?? Timestamp.now(),
      userId: data['userId'] ?? '',
    );
  }

  Post copyWith({
    String? id,
    String? content,
    String? hikeId,
    List<String>? imageUrls,
    int? likes,
    Timestamp? timestamp,
    String? userId,
  }) {
    return Post(
      id: id ?? this.id,
      content: content ?? this.content,
      hikeId: hikeId ?? this.hikeId,
      imageUrls: imageUrls ?? this.imageUrls,
      likes: likes ?? this.likes,
      timestamp: timestamp ?? this.timestamp,
      userId: userId ?? this.userId,
    );
  }
}
