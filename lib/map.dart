import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class SpotsMap extends StatefulWidget {
  @override
  _SpotsMapState createState() => _SpotsMapState();
}

var showDetails = (context, name, description) => () {
      showBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return Container(
              height: 200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(name),
                    Text(description),
                    ElevatedButton(
                      child: const Text('Close BottomSheet'),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ),
              ),
            );
          });
    };

class _SpotsMapState extends State<SpotsMap> {
  Set<Marker> _markers = {};
  LatLng initialLocation;

  final spots = FirebaseFirestore.instance.collection('spots');

  Future<LatLng> getUserLocation() async {
    LocationData currentLocation;
    final location = Location();
    await location.serviceEnabled();
    try {
      currentLocation = await location.getLocation();
      final lat = currentLocation.latitude;
      final lng = currentLocation.longitude;
      final center = LatLng(lat, lng);
      print('Current location: ${center.toJson()}');
      return center;
    } on Exception catch (e) {
      print('Could not get current location ${e.toString()}');
      currentLocation = null;
      return null;
    }
  }

  @override
  void initState() {
    getUserLocation().then((location) {
      setState(() {
        initialLocation = location;
      });
    });
    super.initState();
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    final snapshot = await spots.get();
    final markers = snapshot.docs.map((doc) {
      GeoPoint pos = doc['pos'];
      String name = doc['name'];
      String description =
          doc.data().containsKey('description') ? doc['description'] : null;
      return Marker(
        markerId: MarkerId(name),
        position: LatLng(pos.latitude, pos.longitude),
        onTap: showDetails(context, name, description),
      );
    });
    setState(() {
      _markers = markers.toSet();
    });
  }

  @override
  Widget build(BuildContext context) {
    return initialLocation == null
        ? Text('Lade Karte...')
        : GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: initialLocation,
              zoom: 16,
            ),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          );
  }

  @override
  void dispose() {
    spots.firestore.terminate();
    super.dispose();
  }
}
