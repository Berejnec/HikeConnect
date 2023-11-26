import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hike_connect/features/auth/sign_in_screen.dart';
import 'package:hike_connect/globals/auth_global.dart' as auth;
import 'package:hike_connect/models/hiker_user.dart';
import 'package:hike_connect/theme/hike_color.dart';

final FirebaseStorage _storage = FirebaseStorage.instance;

const List<String> scopes = <String>['email'];

class HikerProfileScreen extends StatefulWidget {
  const HikerProfileScreen({Key? key}) : super(key: key);

  @override
  State<HikerProfileScreen> createState() => _HikerProfileScreenState();
}

class _HikerProfileScreenState extends State<HikerProfileScreen> {
  User? user;
  List<dynamic> users = [];

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> _signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      auth.currentUser = null;
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SignInScreen()));
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  void fetchUserDetails() {
    User? currentUser = FirebaseAuth.instance.currentUser;
    setState(() {
      user = currentUser;
    });
    if (auth.currentUser == null) {
      FirebaseFirestore.instance.collection('users').where("uid", isEqualTo: currentUser?.uid).get().then(
        (querySnapshot) {
          for (var docSnapshot in querySnapshot.docs) {
            HikerUser hikerUser = HikerUser.fromMap({
              'uid': docSnapshot.data()['uid'],
              'displayName': docSnapshot.data()['displayName'],
              'email': docSnapshot.data()['email'],
            });

            setState(() {
              print('set state current user');
              auth.currentUser = hikerUser;
            });

            print('User ID: ${hikerUser.uid}, DisplayName: ${hikerUser.displayName}, Email: ${hikerUser.email}');
          }
        },
        onError: (e) => print('Error completing: $e'),
      );
    }
  }

  Future<void> uploadImage(String imagePath, String userId) async {
    try {
      final Reference storageRef = _storage.ref().child('user_images/$userId/$imagePath');
      await storageRef.putFile(File(imagePath));
      print('Image uploaded successfully.');
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  Future<String?> getImageUrl(String imagePath, String userId) async {
    try {
      final Reference storageRef = _storage.ref().child('user_images/$userId/$imagePath');
      final String downloadURL = await storageRef.getDownloadURL();
      return downloadURL;
    } catch (e) {
      print('Error getting image URL: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            onPressed: () {
              _signOut();
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (user?.photoURL != null)
                      ClipOval(
                        child: Image.network(
                          user!.photoURL!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                    if (user?.photoURL == null) const Text('Loading photo...'),
                    const Gap(25),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(auth.currentUser?.displayName ?? 'Loading name...', style: const TextStyle(color: HikeColor.infoColor, fontSize: 24)),
                        Text(auth.currentUser?.email ?? 'Loading email...', style: const TextStyle(color: HikeColor.infoColor, fontSize: 16)),
                        if (user?.phoneNumber != null) Text(': ${user?.phoneNumber}', style: const TextStyle(color: HikeColor.infoColor, fontSize: 16)),
                      ],
                    ),
                  ],
                ),
                const Gap(25),
                const Text('Phone number: +40722862486'),
                const Text('Hiking experience: Amateur'),
                const Text('Events created: 3'),
                const Text('Connected with 5 Hikers'),
                const Text('Hikers: '),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
