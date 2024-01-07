import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hike_connect/globals/auth_global.dart' as auth;
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
  final weatherApiBaseUrl = 'https://api.weatherapi.com/v1/forecast.json?';

  @override
  void initState() {
    super.initState();
    fetchWeatherData(const LatLng(45.0, 25.0));
  }

  Future<Map<String, dynamic>> fetchWeatherData(LatLng latLng) async {
    try {
      final dio = Dio();
      final response = await dio.get(
        weatherApiBaseUrl,
        queryParameters: {
          'key': 'bb6f222f2a7d4166b1c112651232412',
          'q': '${latLng.latitude},${latLng.longitude}',
          'days': '1',
        },
      );
      if (response.statusCode == 200) {
        print(response.data);
        return response.data;
      } else {
        throw Exception('Failed to load weather');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to load weather');
    }
  }

  Future<Map<String, dynamic>> fetchSunriseSunsetData(double lat, double lng) async {
    try {
      final dio = Dio();
      final response = await dio.get(
        sunsetSunriseApiBaseUrl,
        queryParameters: {
          'lat': lat,
          'lng': lng,
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Evenimente'),
      ),
      body: StreamBuilder<QuerySnapshot>(
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

          return ListView.separated(
            itemCount: events.length,
            padding: const EdgeInsets.only(bottom: 32.0),
            itemBuilder: (context, index) {
              HikeEvent event = events[index];

              bool isParticipant = event.participants.any((participant) => participant.userId == auth.currentUser!.uid);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FutureBuilder(
                    future: fetchWeatherData(event.hikingTrail.locationLatLng),
                    builder: (context, weatherDataSnapshot) {
                      if (weatherDataSnapshot.hasError) {
                        return Text('Error: ${weatherDataSnapshot.error}');
                      } else {
                        Map<String, dynamic>? weatherData = weatherDataSnapshot.data;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              title: Text(event.hikingTrail.routeName),
                              subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text('Data: ${DateFormat.yMMMd().format(event.date)}'),
                                if (weatherData != null) ...[
                                  const Gap(8),
                                  Row(
                                    children: [
                                      const Icon(FontAwesomeIcons.temperatureFull),
                                      Text('Temperatura: ${weatherData['current']['temp_c']} Celsius'),
                                    ],
                                  ),
                                ],
                              ]),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                  FutureBuilder(
                    future: fetchSunriseSunsetData(event.hikingTrail.locationLatLng.latitude, event.hikingTrail.locationLatLng.longitude),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        Map<String, dynamic>? sunriseSunsetData = snapshot.data;

                        return Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (sunriseSunsetData != null) ...[
                                Row(
                                  children: [
                                    const Icon(Icons.sunny),
                                    Text('Rasarit: ${sunriseSunsetData['sunrise']}'),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.nightlight_round_rounded),
                                    Text('Apus: ${sunriseSunsetData['sunset']}'),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.timer),
                                    Text('Durata zilei: ${sunriseSunsetData['day_length']}'),
                                  ],
                                )
                              ],
                              if (event.participants.isNotEmpty) ...[
                                const Gap(8),
                                Text('Participanti:', style: Theme.of(context).textTheme.titleSmall),
                                for (EventParticipant participant in event.participants) ...[
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundImage: NetworkImage(participant.avatarUrl),
                                        radius: 16.0,
                                      ),
                                      const Gap(8),
                                      Text(participant.displayName.split(' ')[0]),
                                      if (isParticipant && participant.userId != auth.currentUser!.uid) ...[
                                        IconButton(
                                          color: HikeColor.infoDarkColor,
                                          padding: const EdgeInsets.all(4.0),
                                          onPressed: () async {
                                            var whatsappUrl = Uri.parse("whatsapp://send?phone=${participant.phoneNumber}"
                                                "&text=${Uri.encodeComponent("HikeConnect: M-am alaturat evenimentului ${event.hikingTrail.routeName} din data de ${DateFormat.yMMMd().format(event.date)} !")}");
                                            try {
                                              if (await canLaunchUrl(whatsappUrl)) {
                                                launchUrl(whatsappUrl);
                                              } else {
                                                if (!mounted) return;
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    dismissDirection: DismissDirection.horizontal,
                                                    behavior: SnackBarBehavior.floating,
                                                    content: Text("WhatsApp is required to be installed in order to send a message!"),
                                                  ),
                                                );
                                              }
                                            } catch (e) {
                                              debugPrint(e.toString());
                                            }
                                          },
                                          icon: const Icon(FontAwesomeIcons.whatsapp, size: 20.0),
                                        ),
                                      ] else if (isParticipant && participant.userId == auth.currentUser!.uid) ...[
                                        const Gap(8),
                                        const Text('(Dvs.)'),
                                      ],
                                    ],
                                  ),
                                ],
                              ],
                              if (isParticipant) ...[
                                const Gap(8),
                                const Text('V-ati alaturat acestui eveniment.'),
                              ] else ...[
                                const Gap(8),
                                FilledButton.tonal(
                                  onPressed: () {
                                    joinEvent(event.id, auth.currentUser!);
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                      content: Text('Te-ai alaturat evenimentului cu succes!'),
                                      duration: Duration(seconds: 5),
                                      behavior: SnackBarBehavior.floating,
                                    ));
                                  },
                                  style: FilledButton.styleFrom(),
                                  child: const Text('Participa'),
                                ),
                              ],
                            ],
                          ),
                        );
                      }
                    },
                  )
                ],
              );
            },
            separatorBuilder: (BuildContext context, int index) => const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
              child: Divider(),
            ),
          );
        },
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
}
