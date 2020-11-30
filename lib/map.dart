import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SpotsMap extends StatefulWidget {
  @override
  _SpotsMapState createState() => _SpotsMapState();
}

class _SpotsMapState extends State<SpotsMap> {
  Set<Marker> _markers = {};

  final spots = FirebaseFirestore.instance.collection('spots');

  Future<void> _onMapCreated(GoogleMapController controller) async {
    final snapshot = await spots.get();
    final markers = snapshot.docs.map((doc) {
      GeoPoint pos = doc['pos'];
      String name = doc['name'];
      return Marker(
        markerId: MarkerId(name),
        position: LatLng(pos.latitude, pos.longitude),
        infoWindow: InfoWindow(
          title: name,
          snippet: 'Something something dark side',
        ),
      );
    });
    setState(() {
      _markers = markers.toSet();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: CameraPosition(
        target: const LatLng(0, 0),
        zoom: 2,
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
