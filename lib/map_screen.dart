import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  final LatLng? location;

  const MapScreen({super.key, this.location});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;

  Set<Polyline> polylines = {};

  @override
  void initState() {
    super.initState();
  }

  void loadHikingTrailsData() async {
    String data = await DefaultAssetBundle.of(context).loadString('assets/trails_data.txt');

    List<String> lines = data.split('\n');

    List<LatLng> coordinates = [];

    for (String line in lines) {
      if (line.isNotEmpty) {
        List<String> coords = line.split(', ');
        double lat = double.parse(coords[0]);
        double lng = double.parse(coords[1]);
        LatLng coordinate = LatLng(lat, lng);
        coordinates.add(coordinate);
      }
    }

    setState(() {
      polylines.add(Polyline(
        polylineId: const PolylineId('123'),
        color: Colors.blue,
        points: coordinates,
        width: 5,
      ));
    });
  }

  late LatLng _center = const LatLng(46.99748, 25.925763);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (widget.location != null) {
      zoomToTappedLocation(widget.location!);
    }
    loadHikingTrailsData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Harta'),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        mapType: MapType.terrain,
        polylines: polylines,
        onTap: (LatLng tappedLocation) {
          zoomToTappedLocation(tappedLocation);
        },
        markers: {
          Marker(
            markerId: const MarkerId('1'),
            position: _center,
            onTap: () {
              zoomToTappedLocation(_center);
            },
            infoWindow: const InfoWindow(title: 'Retezat', snippet: 'Descriere scurta'),
          ),
          if (widget.location != null)
            Marker(
              markerId: const MarkerId('1'),
              position: widget.location!,
              onTap: () {
                zoomToTappedLocation(widget.location!);
              },
              infoWindow: const InfoWindow(title: 'Cabana Pietrele', snippet: 'Descriere inceput traseu Retezat'),
            ),
        },
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 12.0,
        ),
      ),
    );
  }

  void moveCameraToLocation(LatLng location) {
    mapController.animateCamera(CameraUpdate.newLatLng(location));
  }

  void zoomToPoint(LatLng location, double zoomLevel) {
    mapController.animateCamera(
      CameraUpdate.newLatLngZoom(location, zoomLevel),
    );
  }

  void zoomToTappedLocation(LatLng tappedLocation) {
    double zoomLevel = 13.0;
    zoomToPoint(tappedLocation, zoomLevel);
  }
}
