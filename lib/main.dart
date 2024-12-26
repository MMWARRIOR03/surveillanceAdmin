import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:surveillance_admin/Screens/homePage.dart';
import 'package:surveillance_admin/Screens/loginPage.dart';
import 'package:surveillance_admin/Screens/sosView.dart';
import 'package:surveillance_admin/Screens/locHistory.dart';
import 'package:surveillance_admin/Screens/locView.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User app',
      initialRoute: '/home',
      routes: {
        '/': (context) => loginPage(),
        '/home': (context) => homePage(),
        '/locView': (context) => LiveLocationViewerPage(),
        '/sos': (context) => SosViewerPage(),
        '/locHis': (context) => LocationHistoryScreen(),
      },
    );
  }
}
