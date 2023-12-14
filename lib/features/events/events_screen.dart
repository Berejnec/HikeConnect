import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:hike_connect/models/event_participant.dart';
import 'package:hike_connect/models/hike_event.dart';
import 'package:hike_connect/models/hiker_user.dart';
import 'package:hike_connect/globals/auth_global.dart' as auth;
import 'package:hike_connect/theme/hike_color.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Evenimente'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('events').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          List<HikeEvent> events = snapshot.data!.docs.map((doc) {
            return HikeEvent.fromMap(doc.data() as Map<String, dynamic>);
          }).toList();

          return ListView.separated(
            itemCount: events.length,
            itemBuilder: (context, index) {
              HikeEvent event = events[index];

              bool isParticipant = event.participants.any((participant) => participant.userId == auth.currentUser!.uid);

              return ListTile(
                title: Text(event.hikingTrail.routeName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Data: ${DateFormat.yMMMd().format(event.date)}'),
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
                            Text(participant.displayName),
                            IconButton(
                              color: HikeColor.infoDarkColor,
                              padding: const EdgeInsets.all(12.0),
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
                                        content: Text("WhatsApp is required to be installed in order to send message!"),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  debugPrint(e.toString());
                                }
                              },
                              icon: const Icon(FontAwesomeIcons.whatsapp),
                            ),
                          ],
                        ),
                      ],
                    ],
                    if (isParticipant) ...[
                      const Gap(8),
                      const Text('V-ati alaturat acestui eveniment.'),
                    ] else ...[
                      const Gap(8),
                      ElevatedButton(
                        onPressed: () {
                          joinEvent(event.id, auth.currentUser!);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text('Te-ai alaturat evenimentului cu succes!'),
                            duration: Duration(seconds: 5),
                            behavior: SnackBarBehavior.floating,
                          ));
                        },
                        child: const Text('Join'),
                      ),
                    ],
                  ],
                ),
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
