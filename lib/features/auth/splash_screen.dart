import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hike_connect/features/auth/auth_cubit.dart';
import 'package:hike_connect/features/auth/sign_in_screen.dart';
import 'package:hike_connect/home_screen.dart';
import 'package:hike_connect/models/hiker_user.dart';
import 'package:hike_connect/theme/hike_color.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkUserAuthentication();
  }

  Future<void> checkUserAuthentication() async {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user == null) {
        await _handleSignedOutUser();
      } else {
        await _handleSignedInUser(user);
      }
    });
  }

  Future<void> _handleSignedOutUser() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    if (!mounted) return;
    context.read<AuthCubit>().setUser(null, null);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SignInScreen()));
  }

  Future<void> _handleSignedInUser(User user) async {
    HikerUser? hikerUser = await fetchHikerUser(user.uid);
    if (!mounted) return;
    context.read<AuthCubit>().setUser(user, hikerUser);
    await addUserToFirestore(user.uid, user.displayName, user.email, user.photoURL);
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  Future<void> addUserToFirestore(String? userUid, String? displayName, String? email, String? avatarUrl) async {
    final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');

    if (userUid != null) {
      await usersCollection.doc(userUid).set(
        {'displayName': displayName, 'email': email, 'uid': userUid, 'avatarUrl': avatarUrl},
        SetOptions(merge: true),
      );

      HikerUser? hikerUser = await fetchHikerUser(userUid);

      if (!mounted) return;
      context.read<AuthCubit>().setUser(FirebaseAuth.instance.currentUser, hikerUser);

      if (hikerUser != null) {
        CollectionReference imagesCollection = FirebaseFirestore.instance.collection('users').doc(userUid).collection('images');

        try {
          QuerySnapshot imagesQuerySnapshot = await imagesCollection.get();
          List<String> imageUrls =
              imagesQuerySnapshot.docs.map((docSnapshot) => (docSnapshot.data() as Map<String, dynamic>)['imageUrl'] as String).toList();
          if (!mounted) return;
          context.read<AuthCubit>().setHikerUser(hikerUser.copyWith(imageUrls: imageUrls));
        } catch (e) {
          print('Error retrieving images: $e');
        }
      }
    }
  }

  Future<HikerUser?> fetchHikerUser(String? userUid) async {
    if (userUid == null) return null;

    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(userUid).get();

      if (userSnapshot.exists) {
        HikerUser hikerUser = HikerUser.fromMap(userSnapshot.data() as Map<String, dynamic>);
        if (!mounted) return null;
        context.read<AuthCubit>().setHikerUser(hikerUser);

        return hikerUser;
      }
    } catch (e) {
      print('Error fetching HikerUser: $e');
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: HikeColor.gradientColors,
            ),
          ),
          child: SafeArea(
            child: Center(
              child: Image.asset(
                'assets/logo.png',
                width: 120,
                height: 120,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
