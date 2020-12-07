import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dogspots/src/spot.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class SpotsMap extends StatefulWidget {
  @override
  _SpotsMapState createState() => _SpotsMapState();
}

var greenCheck = Icon(Icons.check, color: Colors.green);
var redCross = Icon(Icons.clear, color: Colors.red);

Function showDetails = (BuildContext context, Spot spot) => () {
      showBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return Container(
              height: 200,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 25.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(spot.name),
                      if (spot.description != null) Text(spot.description),
                      Row(children: [
                        spot.isFenced ? greenCheck : redCross,
                        Text('eingezäunt')
                      ]),
                      ElevatedButton(
                        child: const Text('Close BottomSheet'),
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  ),
                ),
              ),
            );
          });
    };

class _SpotsMapState extends State<SpotsMap> {
  Set<Marker> _markers = {};
  Marker _customMarker;
  LatLng initialLocation;
  BitmapDescriptor _addMarkerIcon;

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

  void loadAddMarker() {
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(), 'assets/marker_add_3x.png')
        .then((icon) => _addMarkerIcon = icon);
  }

  @override
  void initState() {
    getUserLocation().then((location) {
      setState(() {
        initialLocation = location;
      });
    });
    loadAddMarker();
    super.initState();
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    print('==>==>=>=>onMapCreated');
    final snapshot = await spots.get();
    final markers = snapshot.docs
        .map((doc) => Spot.fromJson(doc.data()))
        .map((spot) => Marker(
              markerId: MarkerId(spot.name),
              position: LatLng(spot.pos.latitude, spot.pos.longitude),
              onTap: showDetails(context, spot),
            ));

    setState(() {
      _markers = markers.toSet();
    });
  }

  void _addMarker(LatLng position) {
    print('==>==>=>=>' + position.toString());
    print('<-------------------' + _addMarkerIcon.toString());
    final newMarker = Marker(
        markerId: MarkerId('NewDogSpot'),
        position: position,
        icon: _addMarkerIcon);
    setState(() {
      _customMarker = newMarker;
      _markers = _markers.union({_customMarker});
    });
  }

  @override
  Widget build(BuildContext context) {
    return initialLocation == null
        ? Center(child: Text('Lade Karte...'))
        : GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: initialLocation,
              zoom: 16,
            ),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            onTap: _addMarker,
          );
  }

  @override
  void dispose() {
    spots.firestore.terminate();
    super.dispose();
  }
}
