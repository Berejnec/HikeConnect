import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hike_connect/globals/auth_global.dart' as auth;
import 'package:hike_connect/home_screen.dart';
import 'package:hike_connect/models/hiker_user.dart';
import 'package:hike_connect/theme/hike_color.dart';

const List<String> scopes = <String>['email'];

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  User? currentUser = FirebaseAuth.instance.currentUser;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Container(
      color: HikeColor.bgLoginColor,
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/ic_launcher.png'),
            Center(
              child: Text(
                'HikeConnect',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: HikeColor.primaryColor),
                textAlign: TextAlign.center,
              ),
            ),
            const Gap(24),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  await signInWithGoogle();
                  if (mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
                    );
                  }
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(FontAwesomeIcons.google),
                    Gap(8),
                    Text('Autentifica-te'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<UserCredential?> signInWithGoogle() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await auth.signInWithCredential(credential);
    await addUserToFirestore(auth.currentUser?.uid, auth.currentUser?.displayName, auth.currentUser?.email);
    return null;
  }

  Future<void> addUserToFirestore(String? userUid, String? displayName, String? email) async {
    final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');

    if (userUid != null) {
      await usersCollection.doc(userUid).set(
        {'displayName': displayName, 'email': email, 'uid': userUid},
        SetOptions(merge: true),
      );
      if (auth.currentUser == null) {
        print('Fetching data for user');
        await FirebaseFirestore.instance.collection('users').where("uid", isEqualTo: currentUser?.uid).get().then(
          (querySnapshot) async {
            for (var docSnapshot in querySnapshot.docs) {
              HikerUser hikerUser = HikerUser.fromMap({
                'uid': docSnapshot.data()['uid'],
                'displayName': docSnapshot.data()['displayName'],
                'email': docSnapshot.data()['email'],
                'phoneNumber': docSnapshot.data()['phoneNumber'],
                'backgroundUrl': docSnapshot.data()['backgroundUrl'],
                'favoriteHikingTrails': docSnapshot.data()['favoriteHikingTrails'],
              });

              setState(() {
                auth.currentUser = hikerUser;
                auth.currentUser?.favoriteHikingTrails = [...docSnapshot.data()['favoriteHikingTrails']];
              });

              print(
                'User ID: ${hikerUser.uid}, DisplayName: ${hikerUser.displayName}, Email: ${hikerUser.email}, Phone number: ${hikerUser.phoneNumber}'
                'backgroundUrl: ${hikerUser.backgroundUrl}, fav trails length: ${hikerUser.favoriteHikingTrails.length}, images length: ${hikerUser.imageUrls?.length}',
              );
            }

            CollectionReference imagesCollection = FirebaseFirestore.instance.collection('users').doc(currentUser?.uid).collection('images');

            try {
              QuerySnapshot imagesQuerySnapshot = await imagesCollection.get();

              List<String> imageUrls = imagesQuerySnapshot.docs.map((docSnapshot) => (docSnapshot.data() as Map<String, dynamic>)['imageUrl'] as String).toList();

              setState(() {
                auth.currentUser?.imageUrls = imageUrls;
                print(auth.currentUser?.imageUrls?.length);
              });
            } catch (e) {
              print('Error retrieving images: $e');
            }
          },
          onError: (e) => print('Error completing: $e'),
        );
      }
    }
  }
}
