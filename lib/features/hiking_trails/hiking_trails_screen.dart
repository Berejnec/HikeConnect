import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hike_connect/models/hiking_trail.dart';
import 'package:hike_connect/theme/hike_color.dart';
import 'package:hike_connect/utils/widgets/row_info.dart';
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
          hikingTrails = trails;
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Gap(8),
            Text('Trasee autorizate din Romania', style: Theme.of(context).textTheme.headlineMedium),
            const Gap(16),
            Expanded(
              child: hikingTrails.isNotEmpty
                  ? RefreshIndicator(
                      onRefresh: fetchHikingTrails,
                      child: ListView.separated(
                        padding: const EdgeInsets.only(bottom: 32.0),
                        itemCount: hikingTrails.length,
                        itemBuilder: (context, index) {
                          HikingTrail trail = hikingTrails[index];
                          return Card(
                            key: Key(trail.routeName),
                            elevation: 5.0,
                            clipBehavior: Clip.antiAlias,
                            color: HikeColor.tertiaryColor,
                            child: ExpansionTile(
                              tilePadding: const EdgeInsets.all(4.0),
                              leading: const Icon(Icons.hiking, color: HikeColor.white),
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    trail.routeName,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: HikeColor.white),
                                  ),
                                  Text(
                                    'Locatie: ${trail.location} - ${trail.county}',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: HikeColor.white),
                                  ),
                                ],
                              ),
                              backgroundColor: HikeColor.green,
                              trailing: IconButton(
                                icon: const Icon(Icons.map),
                                color: HikeColor.white,
                                onPressed: () {
                                  launchMapDirections(trail.locationLatLng.latitude, trail.locationLatLng.longitude);
                                },
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      RowInfo(info: 'Dificultate: ${trail.degreeOfDifficulty}', icon: const Icon(Icons.difference)),
                                      const Gap(8),
                                      RowInfo(info: 'Echipament: ${trail.equipmentLevelRequested}', icon: const Icon(Icons.difference)),
                                      const Gap(8),
                                      RowInfo(info: 'Marcaj: ${trail.marking}', icon: const Icon(Icons.difference)),
                                      const Gap(8),
                                      RowInfo(info: 'Sezonalitate: ${trail.seasonality}', icon: const Icon(Icons.difference)),
                                      const Gap(8),
                                      RowInfo(info: 'Durata: ${trail.routeDuration}', icon: const Icon(Icons.difference)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) => const Gap(4),
                      ),
                    )
                  : const Center(child: CircularProgressIndicator()),
            ),
          ],
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
