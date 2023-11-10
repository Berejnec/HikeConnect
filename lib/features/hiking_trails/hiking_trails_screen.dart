import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hike_connect/models/hiking_trail.dart';

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
    List<HikingTrail> trails = await getAllHikingTrails();
    setState(() {
      hikingTrails = trails;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trasee'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView.builder(
            itemCount: hikingTrails.length,
            itemBuilder: (context, index) {
              HikingTrail trail = hikingTrails[index];
              return Card(
                child: ListTile(
                  title: Text(trail.routeName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Location: ${trail.location}'),
                      Text('County: ${trail.county}'),
                      Text('Marking: ${trail.marking}'),
                      Text('Echipament necesar: ${trail.equipmentLevelRequested}'),
                      Text('Durata: ${trail.routeDuration}'),
                      Text('Sezonalitate: ${trail.seasonality}'),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<List<HikingTrail>> getAllHikingTrails() async {
    CollectionReference hikingTrailsCollection = FirebaseFirestore.instance.collection('hikingTrails');

    QuerySnapshot querySnapshot = await hikingTrailsCollection.get();

    List<HikingTrail> hikingTrails = querySnapshot.docs.map((DocumentSnapshot document) {
      return HikingTrail.fromMap(document.data() as Map<String, dynamic>);
    }).toList();

    return hikingTrails;
  }
}
