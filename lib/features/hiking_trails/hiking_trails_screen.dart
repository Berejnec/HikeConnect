import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hike_connect/features/events/create_hike_event_form.dart';
import 'package:hike_connect/features/hiking_trails/hiking_trail_form.dart';
import 'package:hike_connect/globals/auth_global.dart' as auth;
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
            Row(
              children: [
                Expanded(child: Text('Trasee autorizate din Romania', style: Theme.of(context).textTheme.headlineMedium)),
                IconButton(
                  icon: const Icon(Icons.file_open_rounded),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HikingTrailForm()),
                    );
                  },
                ),
              ],
            ),
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
                                      const Gap(16),
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              addToFavorites(trail.routeName);
                                            },
                                            icon: Icon(Icons.star, color: isFavorite(trail.routeName) ? Colors.yellowAccent : HikeColor.white),
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              _showAddEventDialog(context, trail);
                                            },
                                            icon: const Icon(Icons.event),
                                          ),
                                        ],
                                      ),
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

  bool isFavorite(String trailName) {
    return auth.currentUser != null && auth.currentUser!.favoriteHikingTrails.contains(trailName);
  }

  void addToFavorites(String trailName) async {
    if (auth.currentUser != null && !auth.currentUser!.favoriteHikingTrails.contains(trailName)) {
      setState(() {
        auth.currentUser!.favoriteHikingTrails.add(trailName);
      });

      await updateFavoritesInFirestore(trailName);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Traseu adaugat la favorite!'),
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Traseul este deja adaugat la favorite'),
          duration: Duration(seconds: 3),
          margin: EdgeInsets.only(bottom: 16.0),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> updateFavoritesInFirestore(String trailId) async {
    try {
      CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');

      DocumentReference userDoc = usersCollection.doc(auth.currentUser?.uid ?? '');

      await userDoc.update({
        'favoriteHikingTrails': FieldValue.arrayUnion([trailId]),
      });

      print('Favorites updated successfully');
    } catch (e) {
      print('Error updating favorites: $e');
    }
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

  void _showAddEventDialog(BuildContext context, HikingTrail trail) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Creeaza eveniment pentru traseul ${trail.routeName}'),
          content: CreateHikeEventForm(trail: trail),
        );
      },
    );
  }
}
