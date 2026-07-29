import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';

class MapService {
  late GoogleMapController _controller;
  Set<Marker> _markers = {};
  
  Set<Marker> get markers => _markers;

  void onMapCreated(GoogleMapController controller) {
    _controller = controller;
  }

  // Add luxury car marker for drivers
  void updateDriverMarker(String id, double lat, double lng) {
    _markers.removeWhere((m) => m.markerId.value == id);
    _markers.add(
      Marker(
        markerId: MarkerId(id),
        position: LatLng(lat, lng),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        infoWindow: const InfoWindow(title: 'Your Driver'),
      ),
    );
  }

  // Smooth camera move
  void animateToLocation(double lat, double lng) {
    _controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, lng), zoom: 15),
      ),
    );
  }
  
  // Custom Map Style (Luxury Dark/Night mode similar to Uber)
  static String luxuryMapStyle = '''
  [
    {
      "elementType": "geometry",
      "stylers": [{"color": "#242f3e"}]
    },
    {
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#746855"}]
    }
    // ... more styles
  ]
  ''';
}
