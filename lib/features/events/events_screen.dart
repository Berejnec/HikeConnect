import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hike_connect/features/auth/auth_cubit.dart';
import 'package:hike_connect/features/emergency/emergency_tabs_screen.dart';
import 'package:hike_connect/features/events/chat/chat_messages.dart';
import 'package:hike_connect/features/events/chat/chat_room_screen.dart';
import 'package:hike_connect/models/event_participant.dart';
import 'package:hike_connect/models/hike_event.dart';
import 'package:hike_connect/models/hiker_user.dart';
import 'package:hike_connect/theme/hike_color.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

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
        title: const Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('Evenimente '),
            Text(
              'HikeConnect',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        centerTitle: false,
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
              icon: const Icon(Icons.emergency))
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Gap(8),
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

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        event.hikingTrail.routeName,
                                        style: const TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        if (isParticipant) ...[
                                          IconButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => ChatRoomScreen(eventId: event.id), // Pass event ID to ChatRoomScreen
                                                ),
                                              );
                                            },
                                            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                                            constraints: const BoxConstraints(),
                                            style: const ButtonStyle(
                                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            ),
                                            icon: const Icon(Icons.chat),
                                          ),
                                        ],
                                        IconButton(
                                          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                                          constraints: const BoxConstraints(),
                                          style: const ButtonStyle(
                                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          ),
                                          onPressed: () async {
                                            await _showSunriseSunsetModal(event);
                                          },
                                          icon: const Icon(Icons.info),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Text('Data: ${DateFormat('yMMMMd', 'ro').format(event.date)}'),
                                const Gap(4),
                                if (event.participants.isNotEmpty) ...[
                                  Text('Participanti:', style: Theme.of(context).textTheme.titleSmall),
                                  for (EventParticipant participant in event.participants) ...[
                                    const Gap(4),
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundImage: NetworkImage(participant.avatarUrl),
                                          radius: 16.0,
                                        ),
                                        const Gap(8),
                                        Text(participant.displayName.split(' ')[0]),
                                        const Gap(8),
                                        if (isParticipant && participant.userId != context.read<AuthCubit>().getHikerUser()?.uid) ...[
                                          IconButton(
                                            color: HikeColor.infoDarkColor,
                                            padding: const EdgeInsets.all(8.0),
                                            constraints: const BoxConstraints(),
                                            style: const ButtonStyle(
                                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            ),
                                            onPressed: () async {
                                              var whatsappUrl = Uri.parse("whatsapp://send?phone=${participant.phoneNumber}"
                                                  "&text=${Uri.encodeComponent("HikeConnect: M-am alaturat evenimentului ${event.hikingTrail.routeName} din data de ${DateFormat('yMMMMd', 'ro').format(event.date)} !")}");
                                              try {
                                                if (await canLaunchUrl(whatsappUrl)) {
                                                  launchUrl(whatsappUrl);
                                                } else {
                                                  if (!mounted) return;
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(
                                                      dismissDirection: DismissDirection.horizontal,
                                                      behavior: SnackBarBehavior.floating,
                                                      margin: EdgeInsets.only(bottom: 16.0),
                                                      backgroundColor: HikeColor.infoColor,
                                                      content:
                                                          Text("Este necesar sa aveti aplicatia WhatsApp instalata pentru a putea trimite un mesaj!"),
                                                    ),
                                                  );
                                                }
                                              } catch (e) {
                                                debugPrint(e.toString());
                                              }
                                            },
                                            icon: const Icon(FontAwesomeIcons.whatsapp, size: 20.0),
                                          ),
                                        ] else if (isParticipant && participant.userId == context.read<AuthCubit>().getHikerUser()?.uid) ...[
                                          const Gap(4),
                                          const Text('(Dvs.)'),
                                          IconButton(
                                            onPressed: () {
                                              withdrawEvent(event.id, context.read<AuthCubit>().getHikerUser()!, context);
                                            },
                                            icon: const Icon(
                                              Icons.person_remove,
                                              size: 20,
                                            ),
                                            color: HikeColor.secondaryColor,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ],
                                if (!isParticipant) ...[
                                  const Gap(8),
                                  FilledButton.tonal(
                                    onPressed: () {
                                      joinEvent(event.id, context.read<AuthCubit>().getHikerUser()!);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Te-ai alaturat evenimentului cu succes!'),
                                          duration: Duration(seconds: 5),
                                          behavior: SnackBarBehavior.floating,
                                          margin: EdgeInsets.only(bottom: 16.0),
                                        ),
                                      );
                                    },
                                    style: FilledButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
                                    ),
                                    child: const Text('Participa'),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) => const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 2.0),
                      child: Divider(),
                    ),
                  ).animate().fade(duration: 200.ms);
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
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const Gap(16),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black),
                    children: [
                      const TextSpan(text: 'Traseu: ', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: widget.event.hikingTrail.routeName),
                    ],
                  ),
                ),
                const Gap(8),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black),
                    children: [
                      const TextSpan(text: 'Data: ', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: DateFormat('yMMMMd', 'ro').format(widget.event.date)),
                    ],
                  ),
                ),
                const Gap(16),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.sunny),
                        const Gap(4),
                        Text('Rasarit: ${widget.sunriseSunsetData['sunrise']}'),
                      ],
                    ),
                    const Gap(4),
                    Row(
                      children: [
                        const Icon(Icons.nightlight_round_rounded),
                        const Gap(4),
                        Text('Apus: ${widget.sunriseSunsetData['sunset']}'),
                      ],
                    ),
                    const Gap(4),
                    Row(
                      children: [
                        const Icon(Icons.timer),
                        const Gap(4),
                        Text('Durata zilei: ${widget.sunriseSunsetData['day_length']}'),
                      ],
                    ),
                    const Gap(4),
                    Row(
                      children: [
                        const Icon(Icons.camera_alt),
                        const Gap(4),
                        Text('Golden hour (ora perfecta pentru poze): ${widget.sunriseSunsetData['golden_hour']}'),
                      ],
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
