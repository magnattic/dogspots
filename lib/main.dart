import 'package:dogspots/map.dart';
import 'package:dogspots/src/spot.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

void setPermissions() async {
  var statuses = await [
    Permission.location,
  ].request();
  print(statuses[Permission.location]);
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setPermissions();

  runApp(DogSpotsApp());
}

class DogSpotsApp extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return Text('Something went wrong!',
              textDirection: TextDirection.ltr);
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
              home: Scaffold(
            appBar: AppBar(
              title: const Text('DogSpots in deiner Nähe'),
              backgroundColor: Colors.red[700],
            ),
            body: SpotsMap(),
          ));
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return Text('Loading firebase...', textDirection: TextDirection.ltr);
      },
    );
  }
}
