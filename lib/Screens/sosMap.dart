import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SosMapScreen extends StatelessWidget {
  final List<Map<String, dynamic>> sosAlerts;

  SosMapScreen({required this.sosAlerts});

  @override
  Widget build(BuildContext context) {
    final Set<Marker> markers = sosAlerts
        .map((alert) => Marker(
              markerId: MarkerId(alert['id']),
              position: LatLng(alert['latitude'], alert['longitude']),
              infoWindow: InfoWindow(
                title: 'Lat: ${alert['latitude']}, Lng: ${alert['longitude']}',
                snippet: alert['message'] ?? 'No message provided',
              ),
            ))
        .toSet();

    return Scaffold(
      appBar: AppBar(
        title: Text('SOS Map View'),
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
