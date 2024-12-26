//
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'dart:async';
//
// class AdminApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Admin Tracker',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: AdminLocationViewer(),
//     );
//   }
// }
//
// class AdminLocationViewer extends StatefulWidget {
//   @override
//   _AdminLocationViewerState createState() => _AdminLocationViewerState();
// }
//
// class _AdminLocationViewerState extends State<AdminLocationViewer> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   GoogleMapController? _mapController;
//   Set<Marker> _markers = {};
//   String? _selectedUserId; // Selected user from the dropdown
//   List<String> _availableUsers = []; // List of available users
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchAvailableUsers();
//     testFirestoreConnection();
//   }
//
//   void testFirestoreConnection() async {
//     try {
//       QuerySnapshot snapshot =
//           await FirebaseFirestore.instance.collection('location_history').get();
//       if (snapshot.docs.isNotEmpty) {
//         print("Documents found in location_history:");
//         snapshot.docs.forEach((doc) {
//           print("User ID: ${doc.id}");
//         });
//       } else {
//         print("No documents found in location_history.");
//       }
//     } catch (e) {
//       print("Error connecting to Firestore: $e");
//     }
//   }
//
//   // Fetch all user IDs from Firestore's 'location_history' collection
//   Future<void> _fetchAvailableUsers() async {
//     try {
//       QuerySnapshot snapshot =
//           await _firestore.collection('location_history').get();
//       if (snapshot.docs.isNotEmpty) {
//         List<String> users = snapshot.docs.map((doc) => doc.id).toList();
//         print("Fetched users: $users");
//         setState(() {
//           _availableUsers = users;
//         });
//       } else {
//         print("No users found in the location_history collection.");
//       }
//     } catch (e) {
//       print("Error fetching users: $e");
//     }
//   }
//
//   // void _fetchLocationHistory(String userId) {
//   //   _firestore
//   //       .collection('location_history')
//   //       .doc(userId)
//   //       .collection('locations')
//   //       .orderBy('timestamp')
//   //       .snapshots()
//   //       .listen((snapshot) {
//   //     Set<Marker> newMarkers = {};
//   //     for (var doc in snapshot.docs) {
//   //       final data = doc.data();
//   //       final latitude = data['latitude'];
//   //       final longitude = data['longitude'];
//   //       final timestamp = data['timestamp'] != null
//   //           ? (data['timestamp'] as Timestamp).toDate().toString()
//   //           : "Unknown Time";
//   //       print("$longitude,$latitude,$timestamp");
//   //       newMarkers.add(
//   //         Marker(
//   //           markerId: MarkerId(doc.id),
//   //           position: LatLng(latitude, longitude),
//   //           infoWindow: InfoWindow(
//   //             title: "Location at:",
//   //             snippet: timestamp,
//   //           ),
//   //         ),
//   //       );
//   //     }
//   //     setState(() {
//   //       _markers = newMarkers;
//   //     });
//   //
//   //     if (newMarkers.isNotEmpty) {
//   //       // Move camera to the latest location
//   //       final latestMarker = newMarkers.last;
//   //       _mapController?.animateCamera(
//   //         CameraUpdate.newLatLng(latestMarker.position),
//   //       );
//   //     }
//   //   });
//   // }
//   // Fetch location history for the selected user
//   Future<void> fetchLocations(String userId) async {
//     try {
//       QuerySnapshot snapshot = await FirebaseFirestore.instance
//           .collection('location_history')
//           .doc(userId)
//           .collection('locations')
//           .get();
//
//       if (snapshot.docs.isNotEmpty) {
//         print("Fetched locations for user $userId:");
//         Set<Marker> newMarkers = {};
//         for (var doc in snapshot.docs) {
//           final lat = doc['latitude'];
//           final lng = doc['longitude'];
//           final timestamp = doc['timestamp'] != null
//               ? (doc['timestamp'] as Timestamp).toDate().toString()
//               : "Unknown Time";
//           print("Location: $lat, $lng");
//
//           newMarkers.add(
//             Marker(
//               markerId: MarkerId(doc.id),
//               position: LatLng(lat, lng),
//               infoWindow:
//                   InfoWindow(title: 'Time Stamp', snippet: "$timestamp"),
//             ),
//           );
//         }
//         setState(() {
//           _markers = newMarkers;
//         });
//       } else {
//         print("No locations found for user $userId.");
//       }
//     } catch (e) {
//       print("Error fetching locations: $e");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Location history'),
//         leading: BackButton(
//             onPressed: () => Navigator.popAndPushNamed(context, '/home')),
//       ),
//       body: Column(
//         children: [
//           // Dropdown for selecting user
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: _availableUsers.isNotEmpty
//                 ? DropdownButton<String>(
//                     isExpanded: true,
//                     hint: Text("Select User"),
//                     value: _selectedUserId,
//                     items: _availableUsers.map((String userId) {
//                       return DropdownMenuItem<String>(
//                         value: userId,
//                         child: Text(userId),
//                       );
//                     }).toList(),
//                     onChanged: (newValue) {
//                       setState(() {
//                         _selectedUserId = newValue;
//                         if (_selectedUserId != null) {
//                           fetchLocations(_selectedUserId!);
//                         }
//                       });
//                     },
//                   )
//                 : Center(child: Text("No users available")),
//           ),
//           Expanded(
//             child: GoogleMap(
//               initialCameraPosition: CameraPosition(
//                 target: LatLng(23.075189235871118,
//                     76.85992966770755), // Default: vit bhopal
//                 zoom: 10,
//               ),
//               markers: _markers,
//               onMapCreated: (GoogleMapController controller) {
//                 _mapController = controller;
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:surveillance_admin/Screens/map.dart';
import 'dart:async';

class LocationHistoryScreen extends StatefulWidget {
  @override
  _LocationHistoryScreenState createState() => _LocationHistoryScreenState();
}

class _LocationHistoryScreenState extends State<LocationHistoryScreen> {
  String? selectedUserId;
  List<Map<String, dynamic>> locations = [];
  Map<String, bool> selectedLocations = {};
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
          await FirebaseFirestore.instance.collection('location_history').get();
      List<String> users = snapshot.docs.map((doc) => doc.id).toList();
      setState(() {
        _availableUsers = users;
        print("Fetched users: $users");
      });
    } catch (e) {
      print("Error fetching users: $e");
    }
  }

  Future<void> fetchLocations() async {
    if (selectedUserId == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('location_history')
          .doc(selectedUserId)
          .collection('locations')
          .orderBy('timestamp', descending: true)
          .get();

      setState(() {
        locations = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id,
            'latitude': data['latitude'],
            'longitude': data['longitude'],
            'timestamp': data['timestamp'],
          };
        }).toList();
        selectedLocations = {for (var loc in locations) loc['id']: false};
      });
    } catch (e) {
      print("Error fetching locations: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void navigateToMapScreen() {
    final selected = locations
        .where((loc) => selectedLocations[loc['id']] ?? false)
        .toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapScreen(
          locations: selected,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Location History'),
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
                  locations = [];
                });
                fetchLocations();
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
          else if (locations.isEmpty && selectedUserId != null)
            Center(child: Text('No locations found for this user.'))
          else if (selectedUserId == null)
            Center(child: Text('Please select a user to view their locations.'))
          else
            Expanded(
              child: ListView.builder(
                itemCount: locations.length,
                itemBuilder: (context, index) {
                  final location = locations[index];
                  return CheckboxListTile(
                    title: Text(
                        'Lat: ${location['latitude']}, Lng: ${location['longitude']}'),
                    subtitle: location['timestamp'] != null
                        ? Text(
                            'Timestamp: ${(location['timestamp'] as Timestamp).toDate()}')
                        : null,
                    value: selectedLocations[location['id']] ?? false,
                    onChanged: (value) {
                      setState(() {
                        selectedLocations[location['id']] = value ?? false;
                      });
                    },
                  );
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: selectedLocations.containsValue(true)
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
