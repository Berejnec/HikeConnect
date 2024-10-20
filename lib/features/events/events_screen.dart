import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:hike_connect/features/auth/user_cubit.dart';
import 'package:hike_connect/features/events/chat/chat_room_screen.dart';
import 'package:hike_connect/models/event_participant.dart';
import 'package:hike_connect/models/hike_event.dart';
import 'package:hike_connect/models/hiker_user.dart';
import 'package:hike_connect/theme/hike_color.dart';
import 'package:intl/intl.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 180.0,
            backgroundColor: Colors.transparent.withOpacity(0.8),
            flexibleSpace: FlexibleSpaceBar(
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Evenimente ',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                  Text(
                    'HikeConnect',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 18.0,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.lerp(FontWeight.w500, FontWeight.w600, 0.5),
                        color: Colors.white),
                  ),
                ],
              ),
              titlePadding: const EdgeInsets.all(16.0),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/back_ios.png',
                    fit: BoxFit.cover,
                  ),
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                    child: Container(
                      color: Colors.black.withOpacity(0.3),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return _buildEventList(context);
              },
              childCount: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventList(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
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
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: events.length,
          padding: const EdgeInsets.only(bottom: 32.0),
          itemBuilder: (context, index) {
            HikeEvent event = events[index];

            bool isParticipant = event.participants.any((participant) => participant.userId == context.read<UserCubit>().getHikerUser()?.uid);

            return Card(
              elevation: 4,
              color: Colors.grey[100],
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: InkWell(
                onTap: () {
                  _showEventDetailsModal(context, event);
                },
                borderRadius: BorderRadius.circular(8.0),
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
                      if (event.owner != null)
                        Text(
                          'Creat de: ${event.owner?.displayName}',
                          style: TextStyle(color: Colors.grey[700], fontSize: 16.0),
                        ),
                      const Gap(4),
                      if (event.description.isNotEmpty) ...[
                        Text(
                          'Descriere: ${event.description}',
                          style: TextStyle(color: Colors.grey[700], fontSize: 16.0),
                        ),
                        const Gap(4)
                      ],
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
                              onPressed: () {
                                _showEventDetailsModal(context, event);
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
                                    ? withdrawEvent(event.id, context.read<UserCubit>().getHikerUser()!, context)
                                    : joinEvent(event.id, context.read<UserCubit>().getHikerUser()!);
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
                                    backgroundImage: CachedNetworkImageProvider(participant.avatarUrl),
                                    radius: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                      participant.displayName + (participant.userId == context.read<UserCubit>().getHikerUser()?.uid ? " (Tu)" : "")),
                                  const Gap(8),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
          separatorBuilder: (BuildContext context, int index) => const Gap(0),
        ).animate().shimmer(duration: 200.ms);
      },
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

  void _showEventDetailsModal(BuildContext context, HikeEvent event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      enableDrag: true,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.90,
            minChildSize: 0.25,
            maxChildSize: 1.0,
            builder: (BuildContext context, ScrollController scrollController) {
              return SingleChildScrollView(
                controller: scrollController,
                child: _SunriseSunsetModalContent(event: event),
              );
            },
          ),
        );
      },
    );
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

  const _SunriseSunsetModalContent({
    Key? key,
    required this.event,
  }) : super(key: key);

  @override
  State<_SunriseSunsetModalContent> createState() => _SunriseSunsetModalContentState();
}

class _SunriseSunsetModalContentState extends State<_SunriseSunsetModalContent> {
  Map<String, dynamic>? sunriseSunsetData;
  double? weatherData;
  List<dynamic>? weatherForecastData;
  bool isLoading = true;
  final sunsetSunriseApiBaseUrl = 'https://api.sunrisesunset.io/json';
  final weatherApiBaseUrl = 'https://api.weatherapi.com/v1/forecast.json?';

  @override
  void initState() {
    super.initState();
    _fetchSunriseSunsetData(widget.event);
    _fetchWeatherData(widget.event);
  }

  void _fetchSunriseSunsetData(HikeEvent event) async {
    try {
      final dio = Dio();
      final response = await dio.get(
        sunsetSunriseApiBaseUrl,
        queryParameters: {
          'lat': event.hikingTrail.locationLatLng?.latitude ?? 45.0,
          'lng': event.hikingTrail.locationLatLng?.longitude ?? 25.0,
          'date': DateFormat('yyyy-MM-dd').format(event.date),
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          sunriseSunsetData = response.data['results'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load sunrise and sunset data');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _fetchWeatherData(HikeEvent event) async {
    try {
      isLoading = true;
      final dio = Dio();
      final response = await dio.get(
        weatherApiBaseUrl,
        queryParameters: {
          'key': 'bb6f222f2a7d4166b1c112651232412',
          'q':
              '${event.hikingTrail.locationLatLng?.latitude != 0 ? event.hikingTrail.locationLatLng?.latitude : 45.0},${event.hikingTrail.locationLatLng?.longitude != 0 ? event.hikingTrail.locationLatLng?.longitude : 25.0}',
          'days': '3',
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          weatherData = response.data['current']['temp_c'];
          weatherForecastData = response.data['forecast']['forecastday'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load weather');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 12.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Informatii despre ziua evenimentului',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const Gap(16),
                        InfoRow(
                          label: 'Traseu',
                          value: widget.event.hikingTrail.routeName,
                        ),
                        const Gap(8),
                        InfoRow(
                          label: 'Data',
                          value: DateFormat('yMMMMd', 'ro').format(widget.event.date),
                        ),
                        const Gap(24),
                        Text(
                          'Răsărit și Apus',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20.0, fontWeight: FontWeight.bold),
                        ),
                        const Gap(8),
                        InfoRow(
                          icon: Icons.sunny,
                          label: 'Răsărit',
                          value: '${sunriseSunsetData?['sunrise']}',
                        ),
                        InfoRow(
                          icon: Icons.nightlight_round_rounded,
                          label: 'Apus',
                          value: '${sunriseSunsetData?['sunset']}',
                        ),
                        InfoRow(
                          icon: Icons.timer,
                          label: 'Durata zilei',
                          value: '${sunriseSunsetData?['day_length']}',
                        ),
                        InfoRow(
                          icon: Icons.camera_alt,
                          label: 'Golden hour (ora perfecta pentru poze)',
                          value: '${sunriseSunsetData?['golden_hour']}',
                        ),
                        const Gap(24),
                        Text(
                          'Vremea curentă',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20.0, fontWeight: FontWeight.bold),
                        ),
                        const Gap(8),
                        InfoRow(
                          icon: Icons.thermostat,
                          label: 'Temperatura curentă',
                          value: '$weatherData °C',
                        ),
                        const Gap(16),
                        if (weatherForecastData != null) ...[
                          Text(
                            'Prognoza meteo pentru următoarele 3 zile',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20.0, fontWeight: FontWeight.bold),
                          ),
                          const Gap(8),
                          for (var forecast in weatherForecastData!)
                            WeatherForecastCard(
                              date: forecast['date'],
                              maxTemp: forecast['day']['maxtemp_c'],
                              minTemp: forecast['day']['mintemp_c'],
                              condition: forecast['day']['condition']['text'],
                              iconUrl: 'https:${forecast['day']['condition']['icon']}',
                            ),
                        ],
                      ],
                    ),
                    const Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Powered by SunriseSunset.io & weatherapi.com',
                          style: TextStyle(fontSize: 10.0),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final IconData? icon;
  final String label;
  final String value;

  const InfoRow({
    Key? key,
    this.icon,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) Icon(icon, size: 20.0, color: HikeColor.primaryColor),
        if (icon != null) const Gap(8),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}

class WeatherForecastCard extends StatelessWidget {
  final String date;
  final double maxTemp;
  final double minTemp;
  final String condition;
  final String iconUrl;

  const WeatherForecastCard({
    Key? key,
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.condition,
    required this.iconUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('EEEE, MMM d', 'ro').format(DateTime.parse(date)),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.network(iconUrl, width: 32.0, height: 32.0),
                    const Gap(4),
                    Text('$minTemp°C - $maxTemp°C', style: Theme.of(context).textTheme.bodyLarge),
                  ],
                ),
                Text(condition, style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
