import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'https://www.googleapis.com/auth/contacts.readonly'],
    clientId: '376999450516-3ra5528m3p16nhvfn6q6a5eegb10ia86.apps.googleusercontent.com',
    serverClientId: '');

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  GoogleSignIn? _currentUser;

  @override
  void initState() {
    _googleSignIn.onCurrentUserChanged.listen((account) {
      setState(() {
        _currentUser = account as GoogleSignIn;
      });
      if (_currentUser != null) {
        print('user already authenticated');
      }
    });
    _googleSignIn.signInSilently();
    super.initState();
  }

  Future<void> handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print('eroare sign in' + error.toString());
    }
  }

  Future<void> handleSignOut() => _googleSignIn.disconnect();

  Widget buildBody() {
    GoogleSignInAccount? user = _currentUser?.currentUser;
    if (user != null) {
      return Column(
        children: [
          const SizedBox(height: 90),
          GoogleUserCircleAvatar(identity: user),
          const SizedBox(height: 20),
          Center(
            child: Text(
              user.displayName ?? '',
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              user.email,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: handleSignOut,
            child: const Text('Sign Out'),
          )
        ],
      );
    } else {
      return Column(
        children: [
          const Center(
            child: Icon(Icons.login),
          ),
          const SizedBox(height: 40),
          Center(
            child: Container(
              width: 250,
              child: ElevatedButton(
                onPressed: handleSignIn,
                child: const Text('Sign In'),
              ),
            ),
          )
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: buildBody(),
      ),
    );
  }
}
