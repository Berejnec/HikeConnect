import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hike_connect/features/auth/auth_cubit.dart';
import 'package:hike_connect/features/events/chat/chat_room_screen.dart';
import 'package:hike_connect/models/event_participant.dart';
import 'package:hike_connect/models/hike_event.dart';
import 'package:hike_connect/models/hiker_user.dart';
import 'package:hike_connect/theme/hike_color.dart';
import 'package:hike_connect/utils/widgets/icon_text_row.dart';
import 'package:intl/intl.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsScreen> {
  final sunsetSunriseApiBaseUrl = 'https://api.sunrisesunset.io/json';
  final weatherApiBaseUrl = 'https://api.open-meteo.com/v1/forecast';

  @override
  void initState() {
    super.initState();
  }

  Future<Map<String, dynamic>> fetchWeatherData(LatLng latLng, DateTime date) async {
    try {
      final dio = Dio();
      final response = await dio.get(
        weatherApiBaseUrl,
        queryParameters: {
          'latitude': '${latLng.latitude}',
          'longitude': '${latLng.longitude}',
          'start_date': DateFormat('yyyy-MM-dd').format(date),
          'end_date': DateFormat('yyyy-MM-dd').format(date),
        },
      );
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to load weather');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to load weather');
    }
  }

  Future<Map<String, dynamic>> fetchSunriseSunsetData(double lat, double lng, DateTime date) async {
    try {
      final dio = Dio();
      final response = await dio.get(
        sunsetSunriseApiBaseUrl,
        queryParameters: {
          'lat': lat,
          'lng': lng,
          'date': DateFormat('yyyy-MM-dd').format(date),
        },
      );

      if (response.statusCode == 200) {
        return response.data['results'];
      } else {
        throw Exception('Failed to load sunrise and sunset data');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to load sunrise and sunset data');
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.grey[300],
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
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
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Evenimente ',
              style: TextStyle(
                fontWeight: FontWeight.lerp(FontWeight.w500, FontWeight.w600, 0.5),
              ),
            ),
            Text(
              'HikeConnect',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.lerp(FontWeight.w500, FontWeight.w600, 0.5),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Flexible(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('events').orderBy('date').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  List<HikeEvent> events = snapshot.data!.docs
                      .map((doc) => HikeEvent.fromMap(doc.data() as Map<String, dynamic>))
                      .where(
                        (event) => event.date.isAfter(DateTime.now().subtract(const Duration(days: 1))),
                      )
                      .toList();

                  if (events.isEmpty) {
                    return const Center(
                      child: Text(
                        'Niciun eveniment momentan.',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: events.length,
                    padding: const EdgeInsets.only(bottom: 32.0),
                    itemBuilder: (context, index) {
                      HikeEvent event = events[index];

                      bool isParticipant =
                          event.participants.any((participant) => participant.userId == context.read<AuthCubit>().getHikerUser()?.uid);

                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      event.hikingTrail.routeName,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                      softWrap: true,
                                    ),
                                  ),
                                ],
                              ),
                              const Gap(8),
                              Text(
                                'Data: ${DateFormat('yMMMMd', 'ro').format(event.date)}',
                                style: TextStyle(color: Colors.grey[700], fontSize: 16.0),
                              ),
                              const Gap(4),
                              Text(
                                'Judet: ${event.hikingTrail.county}',
                                style: TextStyle(color: Colors.grey[700], fontSize: 16.0),
                              ),
                              const Gap(8),
                              if (isParticipant)
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => ChatRoomScreen(eventId: event.id)),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(backgroundColor: HikeColor.infoLightColor),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.chat,
                                        color: Colors.black,
                                      ),
                                      Gap(8.0),
                                      Text(
                                        'Discuta si organizeaza',
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ],
                                  ),
                                ),
                              Row(
                                children: [
                                  Expanded(
                                    flex: isParticipant ? 6 : 4,
                                    child: FilledButton(
                                      onPressed: () async {
                                        await _showSunriseSunsetModal(event);
                                      },
                                      style: FilledButton.styleFrom(
                                        backgroundColor: HikeColor.green,
                                      ),
                                      child: const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.info, color: Colors.black),
                                          Gap(8.0),
                                          Text(
                                            'Detalii',
                                            style: TextStyle(color: Colors.black),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const Gap(8.0),
                                  Expanded(
                                    flex: isParticipant ? 4 : 6,
                                    child: FilledButton(
                                      onPressed: () {
                                        isParticipant
                                            ? withdrawEvent(event.id, context.read<AuthCubit>().getHikerUser()!, context)
                                            : joinEvent(event.id, context.read<AuthCubit>().getHikerUser()!);
                                      },
                                      style: FilledButton.styleFrom(
                                        backgroundColor: isParticipant ? HikeColor.errorColor : HikeColor.primaryColor,
                                      ),
                                      child: Text(
                                        isParticipant ? 'Retragere' : 'Participa',
                                        style: const TextStyle(fontSize: 16, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (event.participants.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                const Text('Participanti:', style: TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Column(
                                  children: event.participants.map((participant) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundImage: NetworkImage(participant.avatarUrl),
                                            radius: 16,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(participant.displayName),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) => const Gap(0),
                  ).animate().shimmer(duration: 200.ms);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> joinEvent(String eventId, HikerUser currentUser) async {
    try {
      CollectionReference eventsCollection = FirebaseFirestore.instance.collection('events');

      DocumentSnapshot eventDoc = await eventsCollection.doc(eventId).get();

      if (eventDoc.exists) {
        HikeEvent existingEvent = HikeEvent.fromMap(eventDoc.data() as Map<String, dynamic>);

        if (!existingEvent.participants.any((participant) => participant.userId == currentUser.uid)) {
          EventParticipant participant = EventParticipant(
            userId: currentUser.uid,
            displayName: currentUser.displayName,
            phoneNumber: currentUser.phoneNumber ?? 'No phone number',
            avatarUrl: FirebaseAuth.instance.currentUser?.photoURL ?? 'No photo',
          );

          existingEvent.participants.add(participant);

          await eventsCollection.doc(eventId).update(existingEvent.toMap());
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Te-ai alaturat evenimentului!'),
              duration: Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.only(bottom: 16.0),
            ),
          );
        }
      }
    } catch (e) {
      print('Error joining event: $e');
    }
  }

  Future<void> _showSunriseSunsetModal(HikeEvent event) async {
    try {
      Map<String, dynamic> sunriseSunsetData = await fetchSunriseSunsetData(
        event.hikingTrail.locationLatLng?.latitude ?? 45.0,
        event.hikingTrail.locationLatLng?.longitude ?? 25.0,
        event.date,
      );

      if (!mounted) return;

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (BuildContext context) {
          return _SunriseSunsetModalContent(event: event, sunriseSunsetData: sunriseSunsetData);
        },
      );
    } catch (e) {
      print('Error fetching sunrise and sunset data: $e');
    }
  }

  Future<void> withdrawEvent(String eventId, HikerUser currentUser, BuildContext context) async {
    try {
      CollectionReference eventsCollection = FirebaseFirestore.instance.collection('events');

      DocumentSnapshot eventDoc = await eventsCollection.doc(eventId).get();

      if (eventDoc.exists) {
        HikeEvent existingEvent = HikeEvent.fromMap(eventDoc.data() as Map<String, dynamic>);
        if (!mounted) return;
        if (existingEvent.participants.any((participant) => participant.userId == currentUser.uid)) {
          bool confirmed = await showWithdrawConfirmationDialog(context) ?? false;

          if (confirmed) {
            existingEvent.participants.removeWhere((participant) => participant.userId == currentUser.uid);

            await eventsCollection.doc(eventId).update(existingEvent.toMap());
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Te-ai retras din eveniment cu succes!'),
                duration: Duration(seconds: 3),
                behavior: SnackBarBehavior.floating,
                margin: EdgeInsets.only(bottom: 16.0),
              ),
            );
          }
        }
      }
    } catch (e) {
      print('Error withdrawing from event: $e');
    }
  }

  Future<bool?> showWithdrawConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Retragere din eveniment'),
          content: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: const Text('Esti sigur ca doresti sa te retragi din acest eveniment?'),
          ),
          insetPadding: const EdgeInsets.all(10.0),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Inchide'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Retrage-ma'),
            ),
          ],
        );
      },
    );
  }
}

class _SunriseSunsetModalContent extends StatefulWidget {
  final HikeEvent event;
  final Map<String, dynamic> sunriseSunsetData;

  const _SunriseSunsetModalContent({
    Key? key,
    required this.event,
    required this.sunriseSunsetData,
  }) : super(key: key);

  @override
  State<_SunriseSunsetModalContent> createState() => _SunriseSunsetModalContentState();
}

class _SunriseSunsetModalContentState extends State<_SunriseSunsetModalContent> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.66,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Informatii despre ziua evenimentului',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
                const Gap(16),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black),
                    children: [
                      const TextSpan(text: 'Traseu: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
                      TextSpan(text: widget.event.hikingTrail.routeName, style: const TextStyle(fontSize: 16.0)),
                    ],
                  ),
                ),
                const Gap(8),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black),
                    children: [
                      const TextSpan(text: 'Data: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
                      TextSpan(text: DateFormat('yMMMMd', 'ro').format(widget.event.date), style: const TextStyle(fontSize: 16.0)),
                    ],
                  ),
                ),
                const Gap(24),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    IconTextRow(
                      icon: Icons.sunny,
                      text: 'Rasarit: ${widget.sunriseSunsetData['sunrise']}',
                    ),
                    const Gap(4),
                    IconTextRow(
                      icon: Icons.nightlight_round_rounded,
                      text: 'Apus: ${widget.sunriseSunsetData['sunset']}',
                    ),
                    const Gap(4),
                    IconTextRow(
                      icon: Icons.timer,
                      text: 'Durata zilei: ${widget.sunriseSunsetData['day_length']}',
                    ),
                    const Gap(4),
                    IconTextRow(
                      icon: Icons.camera_alt,
                      text: 'Golden hour (ora perfecta pentru poze): ${widget.sunriseSunsetData['golden_hour']}',
                    ),
                  ],
                ),
              ],
            ),
            const Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Powered by SunriseSunset.io',
                  style: TextStyle(fontSize: 10.0),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
