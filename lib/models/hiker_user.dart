class HikerUser {
  String uid;
  String displayName;
  String email;
  String? phoneNumber;
  String? avatarUrl;
  String? backgroundUrl;
  List<String>? imageUrls;
  List<String> favoriteHikingTrails;

  HikerUser({
    required this.uid,
    required this.displayName,
    required this.email,
    this.phoneNumber,
    this.avatarUrl,
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
      'avatarUrl': avatarUrl,
      'backgroundUrl': backgroundUrl,
      'imageUrls': imageUrls,
      'favoriteHikingTrails': favoriteHikingTrails,
    };
  }

  factory HikerUser.fromMap(Map<String, dynamic> map) {
    return HikerUser(
      uid: map['uid'],
      displayName: map['displayName'],
      email: map['email'],
      phoneNumber: map['phoneNumber'] as String?,
      avatarUrl: map['avatarUrl'] as String?,
      backgroundUrl: map['backgroundUrl'] as String?,
      imageUrls: map['imageUrls'] != null ? List<String>.from(map['imageUrls']) : null,
      favoriteHikingTrails: List<String>.from(map['favoriteHikingTrails'] ?? []),
    );
  }

  HikerUser copyWith({
    String? uid,
    String? displayName,
    String? email,
    String? phoneNumber,
    String? avatarUrl,
    String? backgroundUrl,
    List<String>? imageUrls,
    List<String>? favoriteHikingTrails,
  }) {
    return HikerUser(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      backgroundUrl: backgroundUrl ?? this.backgroundUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      favoriteHikingTrails: favoriteHikingTrails ?? this.favoriteHikingTrails,
    );
  }

  void printDetails() {
    print('UID: $uid');
    print('DisplayName: $displayName');
    print('Email: $email');
    print('PhoneNumber: $phoneNumber');
    print('AvatarUrl: $avatarUrl');
    print('BackgroundUrl: $backgroundUrl');
    print('ImageUrls: $imageUrls');
    print('FavoriteHikingTrails: $favoriteHikingTrails');
  }
}
