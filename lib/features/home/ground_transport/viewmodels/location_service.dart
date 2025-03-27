import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart';
import 'package:gyde/core/constants/api_key.dart';
import 'package:gyde/core/constants/colors.dart';
import 'package:http/http.dart' as http;

class LocationService {

  final VoidCallback? onLocationUpdated;

  LocationService({this.onLocationUpdated});

  BitmapDescriptor _markerIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor _dropoffMarkerIcon = BitmapDescriptor.defaultMarker;

  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  bool _isLoading = true;
  bool _mapInitialized = false;
  String _mapStyle = "";
  LatLng _currentPosition = const LatLng(33.7463, 72.8397); // Default Location
  final Set<Polyline> _polylines = {};
  Set<Polyline> get polylines => _polylines;
  // Getters
  bool get isLoading => _isLoading;
  Set<Marker> get markers => _markers;
  LatLng get currentPosition => _currentPosition;
  String get mapStyle => _mapStyle;
 
  // Fetch best route from Directions API

  Future<void> getRoutePolyline(LatLng pickup, LatLng dropoff) async {
    debugPrint("Fetching route between coordinates...");
    debugPrint("Pickup: ${pickup.latitude}, ${pickup.longitude}");
    debugPrint("Dropoff: ${dropoff.latitude}, ${dropoff.longitude}");

    String url =
        "https://maps.googleapis.com/maps/api/directions/json?"
        "origin=${pickup.latitude},${pickup.longitude}"
        "&destination=${dropoff.latitude},${dropoff.longitude}"
        "&key=$googleApiKey";

    try {
      final response = await http.get(Uri.parse(url));
      debugPrint("Response Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['status'] == 'OK' &&
            data['routes'] != null &&
            data['routes'].isNotEmpty) {
          final String encodedPolyline =
              data['routes'][0]['overview_polyline']['points'];
          final List<LatLng> decodedPoints = _decodePolyline(encodedPolyline);

          _polylines.clear();
          _polylines.add(
            Polyline(
              polylineId: const PolylineId('route'),
              points: decodedPoints,
              color: blacktext,
              width: 2,
            ),
          );

          // Update map view to show route
          if (_mapInitialized) {
            _mapController.animateCamera(
              CameraUpdate.newLatLngBounds(_calculateMarkerBounds(), 100),
            );
          }

          debugPrint(
            "Polyline added successfully with ${decodedPoints.length} points",
          );
           onLocationUpdated?.call();
        } else {
          debugPrint("No route found or status is not OK");
          debugPrint("API Response: ${json.encode(data)}");
        }
      } else {
        debugPrint("Error fetching route: ${response.statusCode}");
        debugPrint("Response body: ${response.body}");
      }
    } catch (e) {
      debugPrint("Exception in getRoutePolyline: $e");
    }
  }

  //////////////////////////////////////////////////////////////////////////////////////
  // Decode polyline points
  List<LatLng> _decodePolyline(String polyline) {
    List<LatLng> points = [];
    List<int> codes = polyline.codeUnits;
    int index = 0, lat = 0, lng = 0;

    while (index < codes.length) {
      int shift = 0, result = 0;
      int byte;
      do {
        byte = codes[index++] - 63;
        result |= (byte & 0x1F) << shift;
        shift += 5;
      } while (byte >= 0x20);
      int deltaLat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += deltaLat;

      shift = 0;
      result = 0;
      do {
        byte = codes[index++] - 63;
        result |= (byte & 0x1F) << shift;
        shift += 5;
      } while (byte >= 0x20);
      int deltaLng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += deltaLng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  /////////////////////////////////////////////////////////////////////////////
  Future<void> initialize() async {
    await _loadMapStyle();
    await getCurrentLocation();
  }

  void dispose() {
    if (_mapInitialized) {
      _mapController.dispose();
    }
  }

  // Add this method to set the custom marker icon
  void setCustomMarkerIcon(BitmapDescriptor icon) {
    _markerIcon = icon;
    // Re-create markers with the new icon
    updateMarkers();
  }

///////////////////////////////////////////////////////////////////////////////////////////

  void addDropoffMarker(LatLng location, BitmapDescriptor icon) {
    _markers.removeWhere(
      (marker) => marker.markerId.value == "dropoff_location",
    );

    _dropoffMarkerIcon = icon;

    _markers.add(
      Marker(
        markerId: const MarkerId("dropoff_location"),
        position: location,
        icon: _dropoffMarkerIcon,
        infoWindow: const InfoWindow(title: "Drop-off Location"),
      ),
    );

    // Route ko fetch karne ke liye function call karo
    getRoutePolyline(_currentPosition, location);

    if (_mapInitialized) {
      _fitMarkersBounds();
    }
  }

  // Method to fit map bounds to show all markers
  void _fitMarkersBounds() {
    if (_markers.length > 1) {
      final bounds = _calculateMarkerBounds();
      _mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
    }
  }
///////////////////////////////////////////////////////////////////////////////////////////
  // Calculate bounds that include all markers
  LatLngBounds _calculateMarkerBounds() {
    double minLat = double.infinity;
    double maxLat = -double.infinity;
    double minLng = double.infinity;
    double maxLng = -double.infinity;

    for (var marker in _markers) {
      final lat = marker.position.latitude;
      final lng = marker.position.longitude;

      minLat = min(minLat, lat);
      maxLat = max(maxLat, lat);
      minLng = min(minLng, lng);
      maxLng = max(maxLng, lng);
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  // Helper methods for min and max
  double min(double a, double b) => a < b ? a : b;
  double max(double a, double b) => a > b ? a : b;
  // Load Custom Map Style
///////////////////////////////////////////////////////////////////////////////////////////
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
///////////////////////////////////////////////////////////////////////////////////////////
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
         onLocationUpdated?.call();
          updateMarkers();
      }
    } catch (e) {
      _isLoading = false;
      debugPrint('Error getting location: $e');
    }
  }
///////////////////////////////////////////////////////////////////////////////////////////
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
       onLocationUpdated?.call();
    } catch (e) {
      debugPrint("Error zooming to location: $e");
    }
  }
///////////////////////////////////////////////////////////////////////////////////////////
  // 🔥 Function to Update Markers
  void updateMarkers() {
    LatLng? dropoffPosition;

    // Agar dropoff marker mojood hai, uska position save kar lo
    for (var marker in _markers) {
      if (marker.markerId.value == "dropoff_location") {
        dropoffPosition = marker.position;
      }
    }

    _markers.clear();

    _markers.add(
      Marker(
        markerId: const MarkerId("current_location"),
        position: _currentPosition,
        icon: _markerIcon,
        infoWindow: const InfoWindow(title: "Your Location"),
      ),
    );

    // Dropoff marker ko wapis add kar do agar pehle set ho chuka tha
    if (dropoffPosition != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId("dropoff_location"),
          position: dropoffPosition,
          icon: _dropoffMarkerIcon,
          infoWindow: const InfoWindow(title: "Drop-off Location"),
        ),
      );
    }
  }
///////////////////////////////////////////////////////////////////////////////////////////
  // New method to update map with selected location
  void updateSelectedLocation(LatLng location) {
    _currentPosition = location;
    updateMarkers();

    if (_mapInitialized) {
      _mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: location, zoom: 15, tilt: 0, bearing: 0),
        ),
      );
    }
  }
}
