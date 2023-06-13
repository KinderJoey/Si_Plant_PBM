import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class LocationPage extends StatefulWidget {
  static String routeName = "/location";
  @override
  _LocationPage createState() => _LocationPage();
}

class _LocationPage extends State<LocationPage> {
  late GoogleMapController mapController;
  LatLng currentPosition = LatLng(0, 0);

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        currentPosition = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      print('Error getting location: $e');
      // Handle error
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    mapController.animateCamera(CameraUpdate.newLatLng(currentPosition));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map'),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: currentPosition,
          zoom: 15,
        ),
        markers: Set<Marker>.from([
          Marker(
            markerId: MarkerId('currentPosition'),
            position: currentPosition,
          ),
        ]),
      ),
    );
  }
}
