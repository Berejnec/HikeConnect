import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;

  final LatLng _center = const LatLng(45.34056550722687, 22.90814850614202);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        markers: {Marker(markerId: const MarkerId('1'), position: _center, infoWindow: const InfoWindow(title: 'Retezat', snippet: 'Descriere scurta'))},
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 10.0,
        ),
      ),
    );
  }
}
