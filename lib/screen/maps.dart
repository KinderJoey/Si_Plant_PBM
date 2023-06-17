import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {
  static String routeName = "/maps";

  final double latitude;
  final double longitude;

  MapScreen({
    required this.latitude,
    required this.longitude,
  });

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapController mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Maps',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Color(0xFF98FFA2),
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
      ),
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          center: LatLng(widget.latitude, widget.longitude),
          zoom: 15.0,
        ),
        layers: [
          TileLayerOptions(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayerOptions(
            markers: [
              Marker(
                width: 30.0,
                height: 30.0,
                point: LatLng(widget.latitude, widget.longitude),
                builder: (ctx) => Container(
                  child: Icon(
                    Icons.location_on,
                    size: 40.0,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
