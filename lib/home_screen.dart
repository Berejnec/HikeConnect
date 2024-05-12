import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hike_connect/app_navigation_cubit.dart';
import 'package:hike_connect/features/events/events_screen.dart';
import 'package:hike_connect/features/hiker_profile/hiker_profile_screen.dart';
import 'package:hike_connect/features/hiking_trails/hikes_screen.dart';
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
    const HikerProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScreenCubit, AppScreen>(
      builder: (context, selectedScreen) {
        return SelectionArea(
          child: Scaffold(
            body: _buildScreen(selectedScreen),
            bottomNavigationBar: _buildBottomNavigationBar(context),
          ),
        );
      },
    );
  }

  Widget _buildScreen(AppScreen selectedScreen) {
    switch (selectedScreen) {
      case AppScreen.hikes:
        return const HikesScreen();
      case AppScreen.events:
        return const EventsScreen();
      case AppScreen.profile:
        return const HikerProfileScreen();
    }
  }

  void changeTab(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return ConvexAppBar(
      style: TabStyle.reactCircle,
      backgroundColor: HikeColor.primaryColor,
      color: Colors.white60,
      top: -15.0,
      items: const [
        TabItem(icon: Icons.hiking, title: 'Trasee'),
        TabItem(icon: Icons.event, title: 'Evenimente'),
        TabItem(icon: Icons.person, title: 'Profil'),
      ],
      initialActiveIndex: context.read<ScreenCubit>().state.index,
      onTap: (index) {
        context.read<ScreenCubit>().setScreen(AppScreen.values[index]);
      },
    );
  }
}
