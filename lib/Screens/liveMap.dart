import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_database/firebase_database.dart';

class LiveLocationMapScreen extends StatefulWidget {
  final String userId;

  LiveLocationMapScreen({required this.userId});

  @override
  _LiveLocationMapScreenState createState() => _LiveLocationMapScreenState();
}

class _LiveLocationMapScreenState extends State<LiveLocationMapScreen> {
  late GoogleMapController _mapController;
  Marker? _userMarker;
  DatabaseReference? _locationRef;
  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    _locationRef = FirebaseDatabase.instance.ref('users/${widget.userId}');
    listenToLocationUpdates();
  }

  void listenToLocationUpdates() {
    _locationRef?.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null &&
          data.containsKey('latitude') &&
          data.containsKey('longitude')) {
        final updatedLocation = LatLng(data['latitude'], data['longitude']);
        setState(() {
          _currentLocation = updatedLocation;
          _userMarker = Marker(
            markerId: MarkerId(widget.userId),
            position: updatedLocation,
            infoWindow: InfoWindow(
              title: widget.userId,
              snippet: 'Live Location',
            ),
          );

          // Animate the camera to the updated location
          _mapController.animateCamera(CameraUpdate.newLatLng(updatedLocation));
        });
      }
    });
  }

  @override
  void dispose() {
    _locationRef?.onValue.drain();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Live Location of ${widget.userId}'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _currentLocation ?? LatLng(0.0, 0.0), // Default position
          zoom: 15,
        ),
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;

          // Move the camera to the current location after the map is created
          if (_currentLocation != null) {
            _mapController
                .animateCamera(CameraUpdate.newLatLng(_currentLocation!));
          }
        },
        markers: _userMarker != null ? {_userMarker!} : {},
      ),
    );
  }
}
