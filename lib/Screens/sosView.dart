// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
//
// class sosView extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Admin App with SOS Alerts',
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: AdminHomeScreen(),
//     );
//   }
// }
//
// class AdminHomeScreen extends StatefulWidget {
//   @override
//   _AdminHomeScreenState createState() => _AdminHomeScreenState();
// }
//
// class _AdminHomeScreenState extends State<AdminHomeScreen> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   GoogleMapController? _mapController;
//   Set<Marker> _markers = {};
//
//   @override
//   void initState() {
//     super.initState();
//     _listenToSOSAlerts();
//   }
//
//   void _listenToSOSAlerts() {
//     _firestore.collection('sos_alerts').snapshots().listen((snapshot) {
//       print("Snapshot received with ${snapshot.docs.length} documents.");
//       Set<Marker> newMarkers = {};
//       for (var doc in snapshot.docs) {
//         final data = doc.data();
//         final location = data['location'];
//         if (location != null &&
//             location['latitude'] != null &&
//             location['longitude'] != null) {
//           final latitude = location['latitude'];
//           final longitude = location['longitude'];
//           final message = data['message'] ?? "SOS Alert";
//           final timestamp = data['timestamp'] != null
//               ? (data['timestamp'] as Timestamp).toDate().toString()
//               : "Unknown Time";
//
//           print("Adding marker at $latitude, $longitude");
//
//           newMarkers.add(
//             Marker(
//               markerId: MarkerId(doc.id),
//               position: LatLng(latitude, longitude),
//               infoWindow: InfoWindow(
//                 title: message,
//                 snippet: "Sent at: $timestamp , "
//                     "Sent by: ${data['userId'] ?? 'Unknown User'}",
//               ),
//             ),
//           );
//         }
//       }
//       setState(() {
//         _markers = newMarkers;
//       });
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: BackButton(
//             onPressed: () => Navigator.popAndPushNamed(context, '/home')),
//         title: Text("Admin App - SOS Alerts"),
//       ),
//       body: GoogleMap(
//         initialCameraPosition: CameraPosition(
//           target: LatLng(23.075189235871118,
//               76.85992966770755), // Default location: vit bhopal
//           zoom: 15,
//         ),
//         markers: _markers,
//         onMapCreated: (GoogleMapController controller) {
//           _mapController = controller;
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:surveillance_admin/Screens/sosMap.dart';

class SosViewerPage extends StatefulWidget {
  @override
  _SosViewerPageState createState() => _SosViewerPageState();
}

class _SosViewerPageState extends State<SosViewerPage> {
  String? selectedUserId;
  List<Map<String, dynamic>> sosAlerts = [];
  Map<String, bool> selectedAlerts = {};
  List<Map<String, dynamic>> users = [];
  bool isLoading = false;
  List<String> _availableUsers = [];

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('sos_alerts').get();
      List<String> users = snapshot.docs.map((doc) => doc.id).toList();
      setState(() {
        _availableUsers = users;
        print("Fetched users: $users");
      });
    } catch (e) {
      print("Error fetching users: $e");
    }
  }

  Future<void> fetchSosAlerts() async {
    if (selectedUserId == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('sos_alerts')
          .doc(selectedUserId)
          .collection('alerts')
          .orderBy('timestamp', descending: true)
          .get();

      setState(() {
        sosAlerts = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id,
            'latitude': data['latitude'],
            'longitude': data['longitude'],
            'timestamp': data['timestamp'],
            'message': data['message'] ?? 'No message provided',
          };
        }).toList();
        selectedAlerts = {for (var alert in sosAlerts) alert['id']: false};
        print("Fetched SOS alerts: $sosAlerts");
      });
    } catch (e) {
      print("Error fetching SOS alerts: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void navigateToMapScreen() {
    final selected = sosAlerts
        .where((alert) => selectedAlerts[alert['id']] ?? false)
        .toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SosMapScreen(
          sosAlerts: selected,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SOS Viewer'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<String>(
              value: selectedUserId,
              onChanged: (value) {
                setState(() {
                  selectedUserId = value;
                  sosAlerts = [];
                });
                fetchSosAlerts();
              },
              items: _availableUsers.map((String userId) {
                return DropdownMenuItem<String>(
                  value: userId,
                  child: Text(userId),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Select User',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          if (isLoading)
            Center(child: CircularProgressIndicator())
          else if (sosAlerts.isEmpty && selectedUserId != null)
            Center(child: Text('No SOS alerts found for this user.'))
          else if (selectedUserId == null)
            Center(
                child: Text('Please select a user to view their SOS alerts.'))
          else
            Expanded(
              child: ListView.builder(
                itemCount: sosAlerts.length,
                itemBuilder: (context, index) {
                  final alert = sosAlerts[index];
                  return CheckboxListTile(
                    title: Text(
                        'Lat: ${alert['latitude']}, Lng: ${alert['longitude']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (alert['message'] != null)
                          Text('Message: ${alert['message']}'),
                        if (alert['timestamp'] != null)
                          Text(
                              'Time: ${(alert['timestamp'] as Timestamp).toDate()}'),
                      ],
                    ),
                    value: selectedAlerts[alert['id']] ?? false,
                    onChanged: (value) {
                      setState(() {
                        selectedAlerts[alert['id']] = value ?? false;
                      });
                    },
                  );
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: selectedAlerts.containsValue(true)
                  ? navigateToMapScreen
                  : null,
              child: Text('Plot Selected on Map'),
            ),
          ),
        ],
      ),
    );
  }
}
