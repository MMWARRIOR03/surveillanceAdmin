//
//
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
//
// class locView extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Admin Location Viewer',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: UserLocationMap(),
//     );
//   }
// }
//
// class UserLocationMap extends StatefulWidget {
//   @override
//   _UserLocationMapState createState() => _UserLocationMapState();
// }
//
// class _UserLocationMapState extends State<UserLocationMap> {
//   late DatabaseReference _dbRef;
//   Map<String, dynamic> _userLocations = {};
//   Map<String, Marker> _markers = {};
//   GoogleMapController? _mapController;
//
//   @override
//   void initState() {
//     super.initState();
//     _dbRef = FirebaseDatabase.instance.ref("users");
//
//     // Listen to changes in user locations
//     _dbRef.onValue.listen((DatabaseEvent event) {
//       final data = event.snapshot.value as Map<dynamic, dynamic>?;
//       if (data != null) {
//         setState(() {
//           _userLocations = Map<String, dynamic>.from(data);
//           _updateMarkers();
//         });
//       }
//     });
//   }
//
//   void _updateMarkers() {
//     Map<String, Marker> newMarkers = {};
//     _userLocations.forEach((userId, locationData) {
//       final loc = Map<String, dynamic>.from(locationData);
//       newMarkers[userId] = Marker(
//         markerId: MarkerId(userId),
//         position: LatLng(loc['latitude'], loc['longitude']),
//         infoWindow: InfoWindow(
//           title: userId,
//           snippet: "Lat: ${loc['latitude']}, Lng: ${loc['longitude']}",
//         ),
//       );
//     });
//     _markers = newMarkers;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Live User Locations'),
//         leading: BackButton(
//             onPressed: () => Navigator.popAndPushNamed(context, '/home')),
//       ),
//       body: GoogleMap(
//         initialCameraPosition: CameraPosition(
//           target:
//               LatLng(23.0755709208438, 76.85996097684153), // Centered at India
//           zoom: 5,
//         ),
//         markers: Set<Marker>.of(_markers.values),
//         onMapCreated: (controller) {
//           _mapController = controller;
//         },
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _mapController?.dispose();
//     super.dispose();
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:surveillance_admin/Screens/liveMap.dart';
//
// class LiveLocationViewerPage extends StatefulWidget {
//   @override
//   _LiveLocationViewerPageState createState() => _LiveLocationViewerPageState();
// }
//
// class _LiveLocationViewerPageState extends State<LiveLocationViewerPage> {
//   List<Map<String, dynamic>> users = [];
//   List<Map<String, dynamic>> filteredUsers = [];
//   bool isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     fetchUsers();
//   }
//
//   Future<void> fetchUsers() async {
//     try {
//       DatabaseReference usersRef = FirebaseDatabase.instance.ref('users');
//       final snapshot = await usersRef.get();
//
//       if (snapshot.exists) {
//         final data = snapshot.value as Map<dynamic, dynamic>;
//
//         final fetchedUsers = data.entries.map((entry) {
//           return {
//             'userId': entry.key,
//             'latitude': entry.value['latitude'],
//             'longitude': entry.value['longitude'],
//             'timestamp': entry.value['timestamp'],
//           };
//         }).toList();
//
//         setState(() {
//           users = fetchedUsers;
//           filteredUsers = fetchedUsers;
//           isLoading = false;
//         });
//       } else {
//         setState(() {
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       print("Error fetching users: $e");
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }
//
//   void searchUsers(String query) {
//     setState(() {
//       filteredUsers = users
//           .where((user) =>
//               user['userId'].toLowerCase().contains(query.toLowerCase()))
//           .toList();
//     });
//   }
//
//   void navigateToLiveLocation(String userId, LatLng userLocation) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => LiveLocationMapScreen(
//           userId: userId,
//           userLocation: userLocation,
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Live Location Viewer'),
//       ),
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           : Column(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: TextField(
//                     onChanged: searchUsers,
//                     decoration: InputDecoration(
//                       labelText: 'Search Users',
//                       border: OutlineInputBorder(),
//                       suffixIcon: Icon(Icons.search),
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   child: ListView.builder(
//                     itemCount: filteredUsers.length,
//                     itemBuilder: (context, index) {
//                       final user = filteredUsers[index];
//                       final userLocation = LatLng(
//                         user['latitude'],
//                         user['longitude'],
//                       );
//
//                       return ListTile(
//                         title: Text('User ID: ${user['userId']}'),
//                         subtitle: Text(
//                             'Lat: ${user['latitude']}, Lng: ${user['longitude']}'),
//                         trailing: Icon(Icons.location_on),
//                         onTap: () {
//                           navigateToLiveLocation(user['userId'], userLocation);
//                         },
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:surveillance_admin/Screens/liveMap.dart';

class LiveLocationViewerPage extends StatefulWidget {
  @override
  _LiveLocationViewerPageState createState() => _LiveLocationViewerPageState();
}

class _LiveLocationViewerPageState extends State<LiveLocationViewerPage> {
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> filteredUsers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      DatabaseReference usersRef = FirebaseDatabase.instance.ref('users');
      final snapshot = await usersRef.get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;

        final fetchedUsers = data.entries.map((entry) {
          return {
            'userId': entry.key,
            'latitude': entry.value['latitude'],
            'longitude': entry.value['longitude'],
            'timestamp': entry.value['timestamp'],
          };
        }).toList();

        setState(() {
          users = fetchedUsers;
          filteredUsers = fetchedUsers;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching users: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void searchUsers(String query) {
    setState(() {
      filteredUsers = users
          .where((user) =>
              user['userId'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void navigateToLiveLocation(String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LiveLocationMapScreen(userId: userId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Live Location Viewer'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    onChanged: searchUsers,
                    decoration: InputDecoration(
                      labelText: 'Search Users',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];

                      return ListTile(
                        title: Text('User ID: ${user['userId']}'),
                        subtitle: Text(
                            'Lat: ${user['latitude']}, Lng: ${user['longitude']}'),
                        trailing: Icon(Icons.location_on),
                        onTap: () {
                          navigateToLiveLocation(user['userId']);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
