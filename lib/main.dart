import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hike_connect/sign_in_screen.dart';
import 'package:hike_connect/theme/hike_connect_theme.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const HikeConnectApp());
}

class HikeConnectApp extends StatelessWidget {
  const HikeConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: HikeConnectTheme.getPrimaryTheme(),
      home: const SignInScreen(),
    );
  }
}
