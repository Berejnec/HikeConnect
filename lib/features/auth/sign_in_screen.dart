import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hike_connect/home_screen.dart';
import 'package:hike_connect/theme/hike_color.dart';

const List<String> scopes = <String>['email'];

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/google_icon.png',
                      height: 24.0,
                      width: 24.0,
                    ),
                    const Gap(8),
                    const Text('Autentifica-te'),
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
    addUserToFirestore(auth.currentUser?.uid, auth.currentUser?.displayName, auth.currentUser?.email);
    return null;
  }

  Future<void> addUserToFirestore(String? userUid, String? displayName, String? email) async {
    final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');

    if (userUid != null) {
      await usersCollection.doc(userUid).set(
        {'displayName': displayName, 'email': email, 'uid': userUid},
      );
    }
  }
}
