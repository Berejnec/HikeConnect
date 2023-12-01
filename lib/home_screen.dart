import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:hike_connect/features/hiker_profile/hiker_profile_screen.dart';
import 'package:hike_connect/features/hiking_trails/hiking_trails_screen.dart';
import 'package:hike_connect/map_screen.dart';
import 'package:hike_connect/theme/hike_color.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  final List<Widget> screens = [
    const HikesScreen(),
    const MapScreen(),
    const HikerProfileScreen(),
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
      backgroundColor: HikeColor.primaryColor,
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
