import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hike_connect/models/event_participant.dart';
import 'package:hike_connect/models/hiking_trail.dart';

class HikeEvent {
  final String id;
  EventParticipant? owner;
  HikingTrail hikingTrail;
  DateTime date;
  List<EventParticipant> participants;
  final String description;

  HikeEvent({
    this.id = '',
    this.owner,
    required this.hikingTrail,
    required this.date,
    this.participants = const [],
    this.description = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'owner': owner?.toMap(),
      'hikingTrail': hikingTrail.toMap(),
      'date': date.toUtc(),
      'participants': participants.map((participant) => participant.toMap()).toList(),
      'description': description,
    };
  }

  factory HikeEvent.fromMap(Map<String, dynamic> map) {
    return HikeEvent(
      id: map['id'],
      owner: map['owner'] != null ? EventParticipant.fromMap(map['owner']) : null,
      hikingTrail: HikingTrail.fromMap(map['hikingTrail']),
      date: (map['date'] as Timestamp).toDate(),
      participants: List<EventParticipant>.from(
        map['participants']?.map((x) => EventParticipant.fromMap(x)) ?? [],
      ),
      description: map['description'] ?? '',
    );
  }
}
