import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:hike_connect/features/emergency/emergency_info.dart';
import 'package:hike_connect/theme/hike_color.dart';

class EmergencyTabsScreen extends StatelessWidget {
  const EmergencyTabsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.grey[300],
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    return DefaultTabController(
      length: 3,
      child: SelectionArea(
        child: Scaffold(
          appBar: AppBar(
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: HikeColor.gradientColors,
                ),
              ),
            ),
            bottom: const TabBar(
              tabs: [
                Tab(
                  icon: Icon(
                    Icons.emergency,
                    color: Colors.white,
                  ),
                  child: Text(
                    'Urgenta',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                Tab(
                  icon: Icon(Icons.food_bank_outlined, color: Colors.white),
                  child: Text(
                    'Alimentatia',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                Tab(
                  icon: Icon(Icons.animation, color: Colors.white),
                  child: Text(
                    'Accident montan',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            title: const Text(
              'Informatii esentiale - Salvamont Romania',
              // style: TextStyle(color: Colors.black),
            ),
          ),
          body: TabBarView(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Apelul de urgenta', style: Theme.of(context).textTheme.headlineMedium),
                      const Gap(32),
                      Text(EmergencyInfo.getEmergencyPageText()),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Alimentatia si hidratarea', style: Theme.of(context).textTheme.headlineMedium),
                      const Gap(32),
                      Text(EmergencyInfo.getFoodPageText()),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Martor la accident montan', style: Theme.of(context).textTheme.headlineMedium),
                      const Gap(32),
                      Text(EmergencyInfo.getInjuryPageText()),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
