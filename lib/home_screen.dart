import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:hike_connect/features/connections/connect_dashboard_screen.dart';
import 'package:hike_connect/features/events/events_screen.dart';
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
    const EventsScreen(),
    const MapScreen(),
    const ConnectDashboardScreen(),
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
      style: TabStyle.custom,
      backgroundColor: HikeColor.primaryColor,
      initialActiveIndex: 0,
      color: Colors.white60,
      top: -15.0,
      items: const [
        TabItem(icon: Icons.hiking, title: 'Trasee'),
        TabItem(icon: Icons.event, title: 'Evenimente'),
        TabItem(icon: Icons.map, title: 'Harta'),
        TabItem(icon: Icons.connect_without_contact_outlined, title: 'Conexiuni'),
        TabItem(icon: Icons.person, title: 'Profil'),
      ],
      onTap: changeTab,
    );
  }
}
