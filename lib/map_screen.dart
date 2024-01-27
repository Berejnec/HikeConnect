import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class MapScreen extends StatefulWidget {
  final String routeName;

  const MapScreen({super.key, required this.routeName});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  Set<Marker> markers = {};
  final String geocodingApiBaseUrl = 'https://api.opencagedata.com/geocode/v1/json?key=ee255c46e8e94da38ce279c35a8b8898&pretty=1&no_annotations=1';

  @override
  void initState() {
    super.initState();
  }

  late final LatLng _center = const LatLng(45.46706, 24.68328);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    geocodeRouteName(widget.routeName);
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
        title: const Text('Harta'),
      ),
      body: SafeArea(
        bottom: false,
        child: GoogleMap(
          onMapCreated: _onMapCreated,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          mapType: MapType.terrain,
          zoomControlsEnabled: true,
          mapToolbarEnabled: false,
          padding: const EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
          markers: markers,
          onTap: (LatLng tappedLocation) {
            zoomToTappedLocation(tappedLocation);
          },
          initialCameraPosition: CameraPosition(
            target: _center,
            zoom: 6.0,
          ),
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

  void geocodeRouteName(String routeName) async {
    try {
      final dio = Dio();
      final response = await dio.get(
        geocodingApiBaseUrl,
        queryParameters: {
          'q': '$routeName, Romania',
        },
      );

      if (response.statusCode == 200) {
        print('successful api call for ${routeName}!');
        print(response.data);
        print(response.data['results']?[0]?['geometry']);
        if (response.data?['results']?[0] != null) {
          addMarker(LatLng(response.data['results'][0]['geometry']['lat'], response.data['results'][0]['geometry']['lng']), routeName, routeName);
          zoomToPoint(LatLng(response.data['results'][0]['geometry']['lat'], response.data['results'][0]['geometry']['lng']), 13.0);
        }
      } else {
        throw Exception('Failed to geocode routeName');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to geocode routeName: ${routeName}');
    }
  }

  void addMarker(LatLng location, String markerId, String markerTitle) {
    final Marker marker = Marker(
      markerId: MarkerId(markerId),
      position: location,
      infoWindow: InfoWindow(
        title: markerTitle,
        snippet: 'Click pentru directii de navigare',
        onTap: () {
          launchMapDirections(location);
        },
      ),
      onTap: () {
        zoomToPoint(location, 15.0);
      },
    );

    setState(() {
      markers.add(marker);
    });
  }

  void launchMapDirections(LatLng latLng) async {
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=${latLng.latitude},${latLng.longitude}');

    if (await canLaunchUrl(url)) {

      print('launch!');
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
