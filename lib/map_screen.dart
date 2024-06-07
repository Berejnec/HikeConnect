import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hike_connect/theme/hike_color.dart';
import 'package:url_launcher/url_launcher.dart';

class MapScreen extends StatefulWidget {
  final String routeName;
  final double latitude;
  final double longitude;

  const MapScreen({
    super.key,
    required this.routeName,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  Set<Marker> markers = {};
  Marker? _initialMarker;

  @override
  void initState() {
    super.initState();
    _initialMarker = addMarker(LatLng(widget.latitude, widget.longitude), widget.routeName, widget.routeName);
  }

  late final LatLng _center = const LatLng(45.46706, 24.68328);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    moveCameraToLocation(LatLng(widget.latitude, widget.longitude));
    zoomToPoint(LatLng(widget.latitude, widget.longitude), 15.0);
    showMarkerInfoWindow(_initialMarker!.markerId);
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
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: HikeColor.gradientColors,
            ),
          ),
        ),
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

  Marker addMarker(LatLng location, String markerId, String markerTitle) {
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
        showMarkerInfoWindow(MarkerId(markerId));
      },
    );

    setState(() {
      markers.add(marker);
    });

    return marker;
  }

  void showMarkerInfoWindow(MarkerId markerId) {
    mapController.showMarkerInfoWindow(markerId);
  }

  void launchMapDirections(LatLng latLng) async {
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=${latLng.latitude},${latLng.longitude}');

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
