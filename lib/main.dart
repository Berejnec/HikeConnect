import 'dart:async';

import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hike_connect/hikes_screen.dart';
import 'package:hike_connect/theme/hike_color.dart';
import 'package:hike_connect/theme/hike_connect_theme.dart';

import 'firebase_options.dart';
import 'map_screen.dart';
import 'social_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: HikeConnectTheme.getPrimaryTheme(),
      home: const SignInDemo(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentIndex = 0;

  final List<Widget> screens = [
    const HikesScreen(),
    const MapScreen(),
    const SocialScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: buildConvexAppBar(),
    );
  }

  void changeTab(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  ConvexAppBar buildConvexAppBar() {
    return ConvexAppBar(
      style: TabStyle.fixedCircle,
      backgroundColor: const Color(0xFF127C0E),
      initialActiveIndex: 0,
      color: Colors.white60,
      items: const [
        TabItem(icon: Icons.hiking, title: 'Trasee'),
        TabItem(icon: Icons.map, title: 'Map'),
        TabItem(icon: Icons.people, title: 'Social'),
      ],
      onTap: changeTab,
    );
  }
}

const List<String> scopes = <String>[
  'email',
  'https://www.googleapis.com/auth/contacts.readonly',
];

GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: scopes,
);

class SignInDemo extends StatefulWidget {
  const SignInDemo({super.key});

  @override
  State createState() => _SignInDemoState();
}

class _SignInDemoState extends State<SignInDemo> {
  GoogleSignInAccount? _currentUser;
  bool _isAuthorized = false;

  @override
  void initState() {
    super.initState();

    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) async {
      bool isAuthorized = account != null;

      if (kIsWeb && account != null) {
        isAuthorized = await _googleSignIn.canAccessScopes(scopes);
      }

      setState(() {
        _currentUser = account;
        _isAuthorized = isAuthorized;
      });

      if (isAuthorized) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MyHomePage(),
          ),
        );
      }
    });

    _googleSignIn.signInSilently();
  }

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn().then(
            (value) => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const MyHomePage(),
              ),
            ),
          );
    } catch (error) {
      print(error);
    }
  }

  Future<void> _handleAuthorizeScopes() async {
    final bool isAuthorized = await _googleSignIn.requestScopes(scopes);
    setState(() {
      _isAuthorized = isAuthorized;
    });
    if (isAuthorized) {}
  }

  Future<void> _handleSignOut() => _googleSignIn.disconnect();

  void _enterApp() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const MyHomePage(),
      ),
    );
  }

  Widget _buildBody() {
    final GoogleSignInAccount? user = _currentUser;
    if (user != null) {
      return Scaffold(
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Sunteti autentificat!'),
              FilledButton(
                onPressed: _enterApp,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(HikeColor.primaryColor),
                ),
                child: const Text('Intra in aplicatie'),
              ),
            ],
          ),
        ),
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const Text('Nu sunteti autentificat.'),
          ElevatedButton(
            onPressed: _handleSignIn,
            child: const Text('Autentifica-te'),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Autentificare Google'),
      ),
      body: ConstrainedBox(
        constraints: const BoxConstraints.expand(),
        child: _buildBody(),
      ),
    );
  }
}
