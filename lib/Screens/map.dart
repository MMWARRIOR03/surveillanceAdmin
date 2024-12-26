import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatelessWidget {
  final List<Map<String, dynamic>> locations;

  MapScreen({required this.locations});

  @override
  Widget build(BuildContext context) {
    final Set<Marker> markers = locations
        .map((loc) => Marker(
              markerId: MarkerId(loc['id']),
              position: LatLng(loc['latitude'], loc['longitude']),
              infoWindow: InfoWindow(
                title: 'Lat: ${loc['latitude']}, Lng: ${loc['longitude']}',
                snippet: loc['timestamp'] != null
                    ? 'Time: ${(loc['timestamp'] as Timestamp).toDate()}'
                    : null,
              ),
            ))
        .toSet();

    return Scaffold(
      appBar: AppBar(
        title: Text('Map View'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: markers.isNotEmpty
              ? markers.first.position
              : LatLng(0, 0), // Default if no markers
          zoom: 14,
        ),
        markers: markers,
      ),
    );
  }
}
