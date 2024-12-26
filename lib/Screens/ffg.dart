import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class locView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Admin Location Viewer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: UserLocationMap(),
    );
  }
}

class UserLocationMap extends StatefulWidget {
  @override
  _UserLocationMapState createState() => _UserLocationMapState();
}

class _UserLocationMapState extends State<UserLocationMap> {
  late DatabaseReference _dbRef;
  Map<String, dynamic> _userLocations = {};
  Map<String, Marker> _markers = {};
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _dbRef = FirebaseDatabase.instance.ref("users");

    // Listen to changes in user locations
    _dbRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        setState(() {
          _userLocations = Map<String, dynamic>.from(data);
          _updateMarkers();
        });
      }
    });
  }

  void _updateMarkers() {
    Map<String, Marker> newMarkers = {};
    _userLocations.forEach((userId, locationData) {
      final loc = Map<String, dynamic>.from(locationData);
      newMarkers[userId] = Marker(
        markerId: MarkerId(userId),
        position: LatLng(loc['latitude'], loc['longitude']),
        infoWindow: InfoWindow(
          title: userId,
          snippet: "Lat: ${loc['latitude']}, Lng: ${loc['longitude']}",
        ),
      );
    });
    _markers = newMarkers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Live User Locations'),
        leading: BackButton(
            onPressed: () => Navigator.popAndPushNamed(context, '/home')),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target:
              LatLng(23.0755709208438, 76.85996097684153), // Centered at India
          zoom: 5,
        ),
        markers: Set<Marker>.of(_markers.values),
        onMapCreated: (controller) {
          _mapController = controller;
        },
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
