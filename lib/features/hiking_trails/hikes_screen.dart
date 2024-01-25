import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:hike_connect/features/auth/auth_cubit.dart';
import 'package:hike_connect/features/emergency/emergency_tabs_screen.dart';
import 'package:hike_connect/features/events/create_hike_event_form.dart';
import 'package:hike_connect/features/posts/posts_screen.dart';
import 'package:hike_connect/map_screen.dart';
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
  String selectedDifficulty = 'Toate';
  String selectedCounty = 'Toate';
  List<String> counties = [
    'Mureş',
    'Caraș - Severin',
    'Covasna',
    'Hunedoara',
    'Sibiu',
    'Bihor',
    'Maramureș',
    'Alba',
    'Harghita',
    'Suceava',
    'Arad',
    'Bistrița - Năsăud',
    'Vâlcea',
    'Cluj',
    'Mehedinți',
    'Brașov',
    'Neamț',
    'Satu - Mare',
    'Argeş',
    'Prahova',
    'Bacău',
    'Satu Mare'
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.grey[300],
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    return BlocBuilder<AuthCubit, AuthState>(builder: (BuildContext context, AuthState authState) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Trasee autorizate din Romania'),
          centerTitle: false,
          backgroundColor: HikeColor.secondaryColor,
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EmergencyTabsScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.emergency),
            )
          ],
        ),
        backgroundColor: Colors.grey[100],
        body: SafeArea(
          child: StreamBuilder<QuerySnapshot>(
            stream: buildQuery().snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error loading hiking trails ${snapshot.error}'));
              }

              List<HikingTrail> hikingTrails = snapshot.data!.docs.map((doc) => HikingTrail.fromMap(doc.data() as Map<String, dynamic>)).toList();

              print('${snapshot.data?.size}');
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Grad de dificultate:',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            getDifficultyIcon(selectedDifficulty),
                            const Gap(8),
                            Text(
                              selectedDifficulty,
                              style: TextStyle(color: getDifficultyTextColor(selectedDifficulty), fontSize: 18),
                            ),
                          ],
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.arrow_downward),
                          onSelected: (String value) {
                            setState(() {
                              selectedDifficulty = value;
                            });
                          },
                          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'Toate',
                              child: Text('Toate'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'Mic',
                              child: Text('Mic'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'Mediu',
                              child: Text('Mediu'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'Mare',
                              child: Text('Mare'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: const Text(
                            'Judet: ',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton(
                                value: selectedCounty,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedCounty = newValue ?? 'Toate';
                                  });
                                },
                                items: getCountyDropdownItems(),
                                isExpanded: true,
                                isDense: false,
                                icon: const Icon(Icons.arrow_downward),
                                iconEnabledColor: Colors.black,
                                hint: const Text('Alege judetul'),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 8.0),
                    Expanded(
                      child: hikingTrails.isNotEmpty
                          ? ListView.separated(
                              padding: const EdgeInsets.only(bottom: 32.0),
                              itemCount: hikingTrails.length,
                              itemBuilder: (context, index) {
                                HikingTrail trail = hikingTrails[index];
                                return Card(
                                  key: Key(trail.routeName),
                                  elevation: 2.0,
                                  clipBehavior: Clip.antiAlias,
                                  color: HikeColor.fourthColor,
                                  child: ExpansionTile(
                                    tilePadding: const EdgeInsets.all(4.0),
                                    leading: const Icon(Icons.hiking, color: Colors.black),
                                    maintainState: true,
                                    title: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          trail.routeName,
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: Colors.black),
                                        ),
                                        Text(
                                          'Locatie: ${trail.location} - ${trail.county}',
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.black),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: HikeColor.green,
                                    trailing: IconButton(
                                      icon: const Icon(Icons.map, color: Colors.black),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => MapScreen(routeName: trail.routeName.split('-').first.trim()),
                                          ),
                                        );
                                        // launchMapDirections(trail.locationLatLng.latitude, trail.locationLatLng.longitude);
                                      },
                                    ),
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          children: [
                                            const Gap(8),
                                            RowInfo(
                                              info: 'Grad de dificultate: ${trail.degreeOfDifficulty}',
                                              icon: getDifficultyIcon(trail.degreeOfDifficulty),
                                            ),
                                            const Gap(8),
                                            RowInfo(
                                                info: 'Echipament: ${trail.equipmentLevelRequested}',
                                                icon: const Icon(Icons.shield_rounded, size: 24)),
                                            const Gap(8),
                                            RowInfo(
                                              info: 'Marcaj: ${trail.marking}',
                                              icon: getMarkingIcon(trail.marking),
                                            ),
                                            const Gap(8),
                                            RowInfo(
                                                info: 'Sezonalitate: ${trail.seasonality}', icon: const Icon(Icons.hotel_class_outlined, size: 18)),
                                            const Gap(8),
                                            RowInfo(info: 'Durata estimata: ${trail.routeDuration}', icon: const Icon(Icons.timer, size: 18)),
                                            const Gap(16),
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                IconButton(
                                                  onPressed: () {
                                                    toggleFavorite(trail.routeName);
                                                  },
                                                  icon: Icon(Icons.bookmark,
                                                      color: isFavorite(trail.routeName) ? Colors.yellowAccent : HikeColor.white),
                                                ),
                                                IconButton(
                                                  onPressed: () {
                                                    _showAddEventDialog(context, trail);
                                                  },
                                                  icon: const Icon(Icons.event),
                                                ),
                                                IconButton(
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => PostsScreen(hikeId: trail.id ?? ''),
                                                      ),
                                                    );
                                                  },
                                                  icon: const Icon(Icons.post_add),
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
                              separatorBuilder: (BuildContext context, int index) => const Gap(4)).animate().fadeIn(duration: 200.ms)
                          : const Center(
                              child: Text(
                                'Niciun traseu disponibil.',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
    });
  }

  bool isFavorite(String trailName) {
    return context.read<AuthCubit>().getHikerUser() != null && context.read<AuthCubit>().getHikerUser()!.favoriteHikingTrails.contains(trailName);
  }

  void toggleFavorite(String trailName) async {
    if (context.read<AuthCubit>().getHikerUser() != null) {
      if (context.read<AuthCubit>().getHikerUser()!.favoriteHikingTrails.contains(trailName)) {
        await removeFromFavoritesInFirestore(trailName);
        showSnackBar('Traseu eliminat de la favorite!');
      } else {
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

      DocumentReference userDoc = usersCollection.doc(context.read<AuthCubit>().getHikerUser()?.uid ?? '');

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

      DocumentReference userDoc = usersCollection.doc(context.read<AuthCubit>().getHikerUser()?.uid ?? '');

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

  Widget getMarkingIcon(String marking) {
    String imagePath;

    switch (marking) {
      case 'bandă albastră':
        imagePath = 'assets/banda_albastra.png';
        break;
      case 'bandă galbenă':
        imagePath = 'assets/banda_galbena.png';
        break;
      case 'bandă roșie':
        imagePath = 'assets/banda_rosie.png';
        break;
      case 'cruce albastră':
        imagePath = 'assets/cruce_albastra.png';
        break;
      case 'cruce galbenă':
        imagePath = 'assets/cruce_galbena.png';
        break;
      case 'cruce roșie':
        imagePath = 'assets/cruce_rosie.png';
        break;
      case 'punct albastru':
        imagePath = 'assets/punct_albastru.png';
        break;
      case 'punct galben':
        imagePath = 'assets/punct_galben.png';
        break;
      case 'punct roșu':
        imagePath = 'assets/punct_rosu.png';
        break;
      case 'triunghi albastru':
        imagePath = 'assets/triunghi_albastru.png';
        break;
      case 'triunghi galben':
        imagePath = 'assets/triunghi_galben.png';
        break;
      case 'triunghi roșu':
        imagePath = 'assets/triunghi_rosu.png';
        break;
      default:
        imagePath = 'assets/ic_launcher.png';
    }

    return Image.asset(imagePath, height: 24, width: 24);
  }

  Widget getDifficultyIcon(String difficulty) {
    IconData icon;
    Color color;

    switch (difficulty.toLowerCase()) {
      case 'mic':
        icon = Icons.star_outline;
        color = Colors.green;
        break;
      case 'mediu':
        icon = Icons.star_half;
        color = HikeColor.infoColor;
        break;
      case 'mare':
        icon = Icons.star;
        color = Colors.red;
        break;
      default:
        icon = Icons.stars_rounded;
        color = HikeColor.infoDarkColor;
    }

    return Icon(icon, color: color);
  }

  void updateHikingTrails() async {
    // final QuerySnapshot<Map<String, dynamic>> trailsSnapshot = await FirebaseFirestore.instance.collection('hikingTrails').get();
    //
    // WriteBatch batch = FirebaseFirestore.instance.batch();
    //
    // for (var trailDoc in trailsSnapshot.docs) {
    //   final String trailId = trailDoc.id;
    //
    //   final Map<String, dynamic> updatedData = {
    //     'id': trailId,
    //   };
    //
    //   final DocumentReference trailRef = FirebaseFirestore.instance.collection('hikingTrails').doc(trailId);
    //
    //   batch.set(trailRef, updatedData, SetOptions(merge: true));
    // }
    //
    // await batch.commit();
    // print('updated ids successfully!');
  }

  Color getDifficultyTextColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'mic':
        return Colors.green;
      case 'mediu':
        return HikeColor.infoColor;
      case 'mare':
        return Colors.red;
      default:
        return HikeColor.infoDarkColor;
    }
  }

  Query buildQuery() {
    Query query = selectedDifficulty == 'Toate'
        ? FirebaseFirestore.instance.collection('hikingTrails').orderBy('routeName')
        : FirebaseFirestore.instance
            .collection('hikingTrails')
            .orderBy('routeName')
            .where('degreeOfDifficulty', isEqualTo: selectedDifficulty.toLowerCase());

    String searchQuery = '';

    if (selectedCounty != 'Toate') {
      query = query.where('county', isEqualTo: selectedCounty);
    }

    if (searchQuery.isNotEmpty) {
      query = query.where('location', isEqualTo: searchQuery);
    }

    return query;
  }

  List<DropdownMenuItem<String>> getCountyDropdownItems() {
    counties.sort();

    List<DropdownMenuItem<String>> items = [];
    items.add(const DropdownMenuItem<String>(
      value: 'Toate',
      child: Text('Toate judetele'),
    ));

    for (String county in counties) {
      items.add(DropdownMenuItem<String>(
        value: county,
        child: Text(county),
      ));
    }

    return items;
  }
}
