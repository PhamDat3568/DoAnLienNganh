import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    loadFields();
  }

  Future<void> loadFields() async {
    final snapshot =
    await FirebaseFirestore.instance.collection('fields').get();

    final newMarkers = snapshot.docs.map((doc) {
      final data = doc.data();

      return Marker(
        markerId: MarkerId(doc.id),
        position: LatLng(
          data['latitude'],
          data['longitude'],
        ),
        infoWindow: InfoWindow(
          title: data['name'],
          snippet: data['address'],
        ),
      );
    }).toSet();

    setState(() {
      markers = newMarkers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sân gần bạn")),

      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(21.0285, 105.8542),
          zoom: 12,
        ),
        markers: markers,
      ),
    );
  }
}