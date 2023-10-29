import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'hikes_screen.dart';
import 'social_screen.dart';
import 'map_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentIndex = 1;

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
      initialActiveIndex: 1,
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
