class EventParticipant {
  final String userId;
  final String displayName;
  final String phoneNumber;
  final String avatarUrl;

  EventParticipant({
    required this.userId,
    required this.displayName,
    required this.phoneNumber,
    required this.avatarUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'avatarUrl': avatarUrl,
    };
  }

  factory EventParticipant.fromMap(Map<String, dynamic> map) {
    return EventParticipant(
      userId: map['userId'],
      displayName: map['displayName'],
      phoneNumber: map['phoneNumber'],
      avatarUrl: map['avatarUrl'],
    );
  }
}
