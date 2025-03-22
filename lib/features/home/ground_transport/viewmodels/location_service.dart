import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart';

class LocationService {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  bool _isLoading = true;
  bool _mapInitialized = false;
  String _mapStyle = "";
  LatLng _currentPosition = const LatLng(33.7463, 72.8397); // Default Location

  // Getters
  bool get isLoading => _isLoading;
  Set<Marker> get markers => _markers;
  LatLng get currentPosition => _currentPosition;
  String get mapStyle => _mapStyle;

  Future<void> initialize() async {
    await _loadMapStyle();
    await getCurrentLocation();
  }

  void dispose() {
    if (_mapInitialized) {
      _mapController.dispose();
    }
  }

  // Load Custom Map Style
  Future<void> _loadMapStyle() async {
    String style = await rootBundle.loadString('assets/map_style.json');
    _mapStyle = style;
  }

  void onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _mapInitialized = true;
    
    Future.delayed(const Duration(milliseconds: 300), () {
      zoomToCurrentLocation();
    });
  }

  // Get Current Location and Add Marker
  Future<void> getCurrentLocation() async {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _isLoading = false;
        await Geolocator.requestPermission();
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _isLoading = false;
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _isLoading = false;
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );

      _currentPosition = LatLng(position.latitude, position.longitude);
      _isLoading = false;

      updateMarkers(); // 🔥 Update the markers

      if (_mapInitialized) {
        _mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: _currentPosition, zoom: 15),
          ),
        );
      }
    } catch (e) {
      _isLoading = false;
      debugPrint('Error getting location: $e');
    }
  }

  // Zoom to Current Location
  Future<void> zoomToCurrentLocation() async {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    if (!_mapInitialized) return;

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );

      _currentPosition = LatLng(position.latitude, position.longitude);
      updateMarkers(); // 🔥 Update the markers

      _mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _currentPosition,
            zoom: 15,
            tilt: 0,
            bearing: 0,
          ),
        ),
      );
    } catch (e) {
      debugPrint("Error zooming to location: $e");
    }
  }

  // 🔥 Function to Update Markers
  void updateMarkers() {
    _markers.clear();
    _markers.add(
      Marker(
        markerId: const MarkerId("current_location"),
        position: _currentPosition,
        infoWindow: const InfoWindow(title: "Your Location"),
      ),
    );

    debugPrint("Marker updated at: $_currentPosition");
  }
}
