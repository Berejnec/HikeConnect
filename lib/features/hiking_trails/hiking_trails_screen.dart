import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hike_connect/models/hiking_trail.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:shimmer/shimmer.dart';
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
    List<HikingTrail> trails = await getAllHikingTrails();
    if (!mounted) return;
    setState(() {
      hikingTrails = trails + trails + trails;
    });
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
              ? ListView.builder(
                  itemCount: hikingTrails.length,
                  itemBuilder: (context, index) {
                    HikingTrail trail = hikingTrails[index];
                    return Card(
                      child: ListTile(
                        title: Text(trail.routeName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                // MapsLauncher.launchCoordinates(45.4216444, 22.7976946);
                                launchMapDirections(45.4216444, 22.7976946);
                              },
                              icon: const Icon(Icons.map),
                              label: const Text('Directii'),
                            ),
                            Text('Location: ${trail.location}'),
                            Text('County: ${trail.county}'),
                            Text('Marking: ${trail.marking}'),
                            Text('Echipament necesar: ${trail.equipmentLevelRequested}'),
                            Text('Durata: ${trail.routeDuration}'),
                            Text('Sezonalitate: ${trail.seasonality}'),
                          ],
                        ),
                      ),
                    );
                  },
                )
              : Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  enabled: true,
                  child: Card(
                    child: ListTile(
                      title: Text('asddasdasdadsaasd'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              MapsLauncher.launchCoordinates(45.4216444, 22.7976946);
                              // launchMapDirections(45.4216444, 22.7976946);
                            },
                            icon: const Icon(Icons.map),
                            label: const Text('Directii'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
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
