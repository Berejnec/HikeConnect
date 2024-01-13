import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:hike_connect/features/auth/auth_cubit.dart';
import 'package:hike_connect/features/events/create_hike_event_form.dart';
import 'package:hike_connect/features/hiking_trails/hike_form.dart';
import 'package:hike_connect/globals/auth_global.dart' as auth;
import 'package:hike_connect/models/hiker_user.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trasee'),
        actions: [
          // IconButton.outlined(
          //   onPressed: () {},
          //   icon: const Icon(Icons.sos_outlined),
          //   highlightColor: Colors.red.shade400,
          //   color: Colors.red.shade200,
          // ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('hikingTrails').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading hiking trails'));
          }

          List<HikingTrail> hikingTrails = snapshot.data!.docs.map((doc) => HikingTrail.fromMap(doc.data() as Map<String, dynamic>)).toList();

          return Padding(
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
                          MaterialPageRoute(builder: (context) => const HikeForm()),
                        );
                      },
                    ),
                  ],
                ),
                const Gap(16),
                Expanded(
                  child: hikingTrails.isNotEmpty
                      ? RefreshIndicator(
                          onRefresh: () async {
                            // Handle refreshing the data (if needed)
                          },
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
                                  maintainState: true,
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
                                          RowInfo(
                                              info: 'Dificultate: ${trail.degreeOfDifficulty}',
                                              icon: const Icon(Icons.rocket_launch_outlined, size: 18)),
                                          const Gap(8),
                                          RowInfo(
                                              info: 'Echipament: ${trail.equipmentLevelRequested}', icon: const Icon(Icons.shield_rounded, size: 18)),
                                          const Gap(8),
                                          RowInfo(info: 'Marcaj: ${trail.marking}', icon: const Icon(Icons.track_changes_outlined, size: 18)),
                                          const Gap(8),
                                          RowInfo(info: 'Sezonalitate: ${trail.seasonality}', icon: const Icon(Icons.hotel_class_outlined, size: 18)),
                                          const Gap(8),
                                          RowInfo(info: 'Durata: ${trail.routeDuration}', icon: const Icon(Icons.timer, size: 18)),
                                          const Gap(16),
                                          Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              IconButton(
                                                onPressed: () {
                                                  toggleFavorite(trail.routeName);
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
          );
        },
      ),
    );
  }

  bool isFavorite(String trailName) {
    return auth.currentUser != null && auth.currentUser!.favoriteHikingTrails.contains(trailName);
  }

  void toggleFavorite(String trailName) async {
    if (auth.currentUser != null) {
      if (auth.currentUser!.favoriteHikingTrails.contains(trailName)) {
        setState(() {
          auth.currentUser!.favoriteHikingTrails.remove(trailName);
        });

        await removeFromFavoritesInFirestore(trailName);
        showSnackBar('Traseu eliminat de la favorite!');
      } else {
        setState(() {
          auth.currentUser!.favoriteHikingTrails.add(trailName);
        });

        await updateFavoritesInFirestore(trailName);
        showSnackBar('Traseu adaugat la favorite!');
      }
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 16.0),
      ),
    );
  }

  Future<void> removeFromFavoritesInFirestore(String trailName) async {
    try {
      CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');

      DocumentReference userDoc = usersCollection.doc(auth.currentUser?.uid ?? '');

      await userDoc.update({
        'favoriteHikingTrails': FieldValue.arrayRemove([trailName]),
      });

      if (!mounted) return;

      HikerUser? updatedHikerUser = context.read<AuthCubit>().getHikerUser()?.copyWith(
            favoriteHikingTrails: (context.read<AuthCubit>().getHikerUser()?.favoriteHikingTrails ?? [])..remove(trailName),
          );

      context.read<AuthCubit>().setHikerUser(updatedHikerUser);
    } catch (e) {
      print('Error updating favorites: $e');
    }
  }

  Future<void> updateFavoritesInFirestore(String trailName) async {
    try {
      CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');

      DocumentReference userDoc = usersCollection.doc(auth.currentUser?.uid ?? '');

      await userDoc.update({
        'favoriteHikingTrails': FieldValue.arrayUnion([trailName]),
      });

      if (!mounted) return;

      HikerUser? updatedHikerUser = context.read<AuthCubit>().getHikerUser()?.copyWith(
            favoriteHikingTrails: (context.read<AuthCubit>().getHikerUser()?.favoriteHikingTrails ?? [])..add(trailName),
          );

      context.read<AuthCubit>().setHikerUser(updatedHikerUser);
      print('Favorites updated successfully');
    } catch (e) {
      print('Error updating favorites: $e');
    }
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
          title: Row(
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    text: 'Creeaza eveniment pentru traseul\n',
                    style: DefaultTextStyle.of(context).style,
                    children: [
                      TextSpan(text: trail.routeName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          scrollable: true,
          content: CreateHikeEventForm(trail: trail),
        );
      },
    );
  }
}
