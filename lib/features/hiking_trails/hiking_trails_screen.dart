import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hike_connect/models/hiking_trail.dart';
import 'package:hike_connect/theme/hike_color.dart';
import 'package:url_launcher/url_launcher.dart';

class HikesScreen extends StatefulWidget {
  const HikesScreen({super.key});

  @override
  State<HikesScreen> createState() => _HikesScreenState();
}

class _HikesScreenState extends State<HikesScreen> {
  List<HikingTrail> hikingTrails = [];

  @override
  void initState() {
    super.initState();
    fetchHikingTrails();
  }

  Future<void> fetchHikingTrails() async {
    try {
      List<HikingTrail> trails = await getAllHikingTrails();
      if (mounted) {
        setState(() {
          hikingTrails = trails + trails + trails + trails + trails + trails + trails + trails + trails;
        });
      }
    } catch (e) {
      print('Error fetching hiking trails: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trasee'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: hikingTrails.isNotEmpty
              ? ListView.separated(
                  itemCount: hikingTrails.length,
                  itemBuilder: (context, index) {
                    HikingTrail trail = hikingTrails[index];
                    return Card(
                      elevation: 2.0,
                      child: ListTile(
                        title: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(Icons.hiking),
                            const Gap(8),
                            Flexible(
                              child: Text(
                                trail.routeName,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        horizontalTitleGap: 0.0,
                        trailing: IconButton(
                          icon: const Icon(Icons.map),
                          color: HikeColor.primaryColor,
                          onPressed: () {
                            launchMapDirections(45.4216444, 22.7976946);
                          },
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Gap(8),
                            Row(
                              children: [
                                const Icon(Icons.location_pin),
                                const Gap(8),
                                Expanded(
                                  child: Text(
                                    'Locatie: ${trail.location} - ${trail.county}',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) => const Gap(8),
                )
              : const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  Future<List<HikingTrail>> getAllHikingTrails() async {
    CollectionReference hikingTrailsCollection = FirebaseFirestore.instance.collection('hikingTrails');

    QuerySnapshot querySnapshot = await hikingTrailsCollection.get();

    List<HikingTrail> hikingTrails = querySnapshot.docs.map((DocumentSnapshot document) {
      return HikingTrail.fromMap(document.data() as Map<String, dynamic>);
    }).toList();

    return hikingTrails;
  }

  void launchMapDirections(double destinationLatitude, double destinationLongitude) async {
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$destinationLatitude,$destinationLongitude');

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
