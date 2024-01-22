import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

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
    readExcel();
  }

  void readExcel() async {
    ByteData data = await DefaultAssetBundle.of(context).load('assets/trasee_turistice_oficial.xlsx');
    var bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    var excel = Excel.decodeBytes(bytes);

    for (var table in excel.tables.keys) {
      print(table); //sheet Name
      print(excel.tables[table]?.maxColumns);
      print(excel.tables[table]?.maxRows);
      for (var row in excel.tables[table]?.rows ?? []) {
        print('$row');
        for (var cell in row) {
          final value = cell?.value;
          print(value);
        }
      }
    }
  }

  void loadHikingTrailsData() async {
    // String data = await DefaultAssetBundle.of(context).loadString('assets/trails_data.txt');
    //
    // List<String> lines = data.split('\n');
    //
    // List<LatLng> coordinates = [];
    //
    // for (String line in lines) {
    //   if (line.isNotEmpty) {
    //     List<String> coords = line.split(', ');
    //     double lat = double.parse(coords[0]);
    //     double lng = double.parse(coords[1]);
    //     LatLng coordinate = LatLng(lat, lng);
    //     coordinates.add(coordinate);
    //   }
    // }
    //
    // setState(() {
    //   polylines.add(Polyline(
    //     polylineId: const PolylineId('123'),
    //     color: Colors.blue,
    //     points: coordinates,
    //     width: 5,
    //   ));
    // });
  }

  late final LatLng _center = const LatLng(45.46706, 24.68328);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (widget.location != null) {
      zoomToTappedLocation(widget.location!);
    }
    // loadHikingTrailsData();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.grey[300], // Set the status bar color to white
      statusBarIconBrightness: Brightness.dark, // Set the status bar icons to dark
      // systemNavigationBarColor: HikeColor.primaryColor, // Set the navigation bar color to white
      systemNavigationBarIconBrightness: Brightness.dark, // Set the navigation bar icons to dark
    ));

    return Scaffold(
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        mapType: MapType.terrain,
        polylines: polylines,
        zoomControlsEnabled: true,
        onTap: (LatLng tappedLocation) {
          zoomToTappedLocation(tappedLocation);
        },
        // todo replace hard-coded markers with fetching
        markers: {
          Marker(
            markerId: const MarkerId('1'),
            position: const LatLng(46.99748, 25.925763),
            onTap: () {
              zoomToTappedLocation(const LatLng(46.99748, 25.925763));
            },
            infoWindow: InfoWindow(
              title: 'Durau',
              onTap: () async {
                print('on tap Calcescu');
                // todo redirect to maps for all markers
                final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=46.99748, 25.925763');

                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                } else {
                  throw 'Could not launch $url';
                }
              },
            ),
          ),
          Marker(
            markerId: const MarkerId('2'),
            position: const LatLng(45.349276999999994, 23.65254969999999),
            onTap: () {
              zoomToTappedLocation(const LatLng(45.349276999999994, 23.65254969999999));
            },
            infoWindow: const InfoWindow(title: 'Lacul Calcescu'),
          ),
          Marker(
            markerId: const MarkerId('3'),
            position: const LatLng(45.46706, 24.68328),
            onTap: () {
              zoomToTappedLocation(const LatLng(45.46706, 24.68328));
            },
            infoWindow: const InfoWindow(title: 'Valea Valsanului'),
          ),
          Marker(
            markerId: const MarkerId('4'),
            position: const LatLng(47.239074, 25.329229),
            onTap: () {
              zoomToTappedLocation(const LatLng(47.239074, 25.329229));
            },
            infoWindow: const InfoWindow(title: 'Neagra Sarului'),
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
          zoom: 6.0,
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
