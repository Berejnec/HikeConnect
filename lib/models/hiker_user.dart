class HikerUser {
  String uid;
  String displayName;
  String email;

  HikerUser({required this.uid, required this.displayName, required this.email});

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
    };
  }

  factory HikerUser.fromMap(Map<String, dynamic> map) {
    return HikerUser(
      uid: map['uid'],
      displayName: map['displayName'],
      email: map['email'],
    );
  }
}
