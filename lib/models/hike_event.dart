import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hike_connect/models/event_participant.dart';
import 'package:hike_connect/models/hiking_trail.dart';

class HikeEvent {
  String id;
  HikingTrail hikingTrail;
  DateTime date;
  List<EventParticipant> participants;

  HikeEvent({
    required this.id,
    required this.hikingTrail,
    required this.date,
    this.participants = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'hikingTrail': hikingTrail.toMap(),
      'date': date.toUtc(),
      'participants': participants.map((participant) => participant.toMap()).toList(),
    };
  }

  factory HikeEvent.fromMap(Map<String, dynamic> map) {
    return HikeEvent(
      id: map['id'],
      hikingTrail: HikingTrail.fromMap(map['hikingTrail']),
      date: (map['date'] as Timestamp).toDate(),
      participants: List<EventParticipant>.from(
        map['participants']?.map((x) => EventParticipant.fromMap(x)) ?? [],
      ),
    );
  }
}
