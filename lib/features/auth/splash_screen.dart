import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hike_connect/home_screen.dart';
import 'package:hike_connect/features/auth/sign_in_screen.dart';

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
    FirebaseAuth auth = FirebaseAuth.instance;

    // Check if the user is already signed in
    User? user = auth.currentUser;

    if (user != null) {
      // User is signed in, navigate to the home screen
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    } else {
      // User is not signed in, navigate to the sign-in screen
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SignInScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
