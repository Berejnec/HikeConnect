import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hike_connect/features/auth/user_cubit.dart';
import 'package:hike_connect/home_screen.dart';
import 'package:hike_connect/models/hiker_user.dart';
import 'package:hike_connect/theme/hike_color.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBody(),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: HikeColor.gradientColors,
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Image.asset('assets/logo.png', width: 240, height: 240),
                const Gap(16.0),
                Center(
                  child: Text(
                    'HikeConnect',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: const Color(0xFF0B613D),
                          fontWeight: FontWeight.bold,
                          fontSize: 42,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            const Gap(60),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  setState(() {
                    _isLoading = true;
                  });
                  bool signedIn = await signInWithGoogle();
                  if (signedIn) {
                    if (mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                      );
                    }
                  } else {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(FontAwesomeIcons.google),
                      Gap(12),
                      Text(
                        'Autentifica-te',
                        style: TextStyle(fontSize: 24),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> signInWithGoogle() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser == null) {
      return false;
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await auth.signInWithCredential(credential);

    final currentUser = auth.currentUser;

    HikerUser? hikerUser = await fetchHikerUser(currentUser?.uid);

    if (!mounted) return false;
    context.read<UserCubit>().setUser(currentUser, hikerUser);
    await addUserToFirestore(auth.currentUser?.uid, auth.currentUser?.displayName, auth.currentUser?.email, auth.currentUser?.photoURL);
    return true;
  }

  Future<HikerUser?> fetchHikerUser(String? userUid) async {
    if (userUid == null) return null;

    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(userUid).get();

      if (userSnapshot.exists) {
        HikerUser hikerUser = HikerUser.fromMap(userSnapshot.data() as Map<String, dynamic>);
        if (!mounted) return null;
        context.read<UserCubit>().setHikerUser(hikerUser);

        return hikerUser;
      }
    } catch (e) {
      print('Error fetching HikerUser: $e');
    }

    return null;
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
      context.read<UserCubit>().setUser(FirebaseAuth.instance.currentUser, hikerUser);

      if (hikerUser != null) {
        CollectionReference imagesCollection = FirebaseFirestore.instance.collection('users').doc(userUid).collection('images');

        try {
          QuerySnapshot imagesQuerySnapshot = await imagesCollection.get();
          List<String> imageUrls =
              imagesQuerySnapshot.docs.map((docSnapshot) => (docSnapshot.data() as Map<String, dynamic>)['imageUrl'] as String).toList();
          if (!mounted) return;
          context.read<UserCubit>().setHikerUser(hikerUser.copyWith(imageUrls: imageUrls));
        } catch (e) {
          print('Error retrieving images: $e');
        }
      }
    }
  }
}
