class HikerUser {
  String uid;
  String displayName;
  String email;
  String? phoneNumber;
  String? backgroundUrl;
  List<String>? imageUrls;
  List<String> favoriteHikingTrails;

  HikerUser({
    required this.uid,
    required this.displayName,
    required this.email,
    this.phoneNumber,
    this.backgroundUrl,
    this.imageUrls,
    required this.favoriteHikingTrails,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'phoneNumber': phoneNumber,
      'backgroundUrl': backgroundUrl,
      'imageUrls': imageUrls,
      'favoriteHikingTrailIds': favoriteHikingTrails,
    };
  }

  factory HikerUser.fromMap(Map<String, dynamic> map) {
    return HikerUser(
      uid: map['uid'],
      displayName: map['displayName'],
      email: map['email'],
      phoneNumber: map['phoneNumber'] as String?,
      backgroundUrl: map['backgroundUrl'] as String?,
      imageUrls: map['imageUrls'] != null ? List<String>.from(map['imageUrls']) : null,
      favoriteHikingTrails: List<String>.from(map['favoriteHikingTrailIds'] ?? []),
    );
  }
}
