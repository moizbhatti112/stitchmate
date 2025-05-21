import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart';
import 'package:stitchmate/core/constants/api_key.dart';
import 'package:stitchmate/core/constants/colors.dart';
import 'package:stitchmate/features/home/ground_transport/models/direction_model.dart';
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
  LatLng _currentPosition = const LatLng(130, 120); // Default Location
  final Set<Polyline> _polylines = {};
  Set<Polyline> get polylines => _polylines;
  // Getters
  bool get isLoading => _isLoading;
  Set<Marker> get markers => _markers;
  LatLng get currentPosition => _currentPosition;
  String get mapStyle => _mapStyle;
String _estimatedDistance = "";
String _estimatedDuration = "";
int _calculatedPrice = 0;
// Add these getters
String get estimatedDistance => _estimatedDistance;
String get estimatedDuration => _estimatedDuration;
int get calculatedPrice => _calculatedPrice;
  // Fetch best route from Directions API
////////////////////////////////////////////////////////////////////////////////////////
 int calculatePrice() {
    // If no distance is available yet, return 0
    if (_estimatedDistance.isEmpty) return 0;
    
    // Extract the distance value from the string (e.g., "5.2 km" -> 5.2)
    // First, handle if there's no unit
    if (!_estimatedDistance.contains("km")) {
      debugPrint("Distance format not recognized: $_estimatedDistance");
      return 0;
    }
    
    String distanceStr = _estimatedDistance.split(' ')[0];
    double distanceKm;
    
    try {
      distanceKm = double.parse(distanceStr);
    } catch (e) {
      debugPrint("Error parsing distance value: $e");
      return 0;
    }
    
    // Calculate price at Rs 25 per km
    // Round up to the nearest integer
    int basePrice = (distanceKm * 50).ceil();
    
    // Ensure minimum price is 25 rupees
    return basePrice < 50 ? 50 : basePrice;
  }
  ///////////////////////////////////////////////////////////////////////////////////////////////
Future<void> getRoutePolyline(LatLng pickup, LatLng dropoff) async {
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
      
      // Parse the response into our model
      final directionsResponse = DirectionsResponse.fromJson(data);
      
      if (directionsResponse.status == 'OK' && directionsResponse.routes.isNotEmpty) {
        final route = directionsResponse.routes[0];
        final leg = route.legs[0];
        
        // Extract information using our models
        _estimatedDistance = leg.distance.text;
        _estimatedDuration = leg.duration.text;

          _calculatedPrice = calculatePrice();
        debugPrint("Distance: $_estimatedDistance, Duration: $_estimatedDuration");
        
        final String encodedPolyline = route.overviewPolyline.points;
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
Future<bool> initialize() async {
  try {
    await _loadMapStyle();
    
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled
      _isLoading = false;
      return false;
    }

    // First, check current permission status
    var permission = await Geolocator.checkPermission();
    
    // If permission is denied, request it immediately
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _isLoading = false;
        return false;
      }
    }
    
    // If permission is permanently denied, we can't request again
    // but we should return false to show the proper UI
    if (permission == LocationPermission.deniedForever) {
      _isLoading = false;
      return false;
    }
    
    // Permission is granted, get the current location
    bool locationObtained = await getCurrentLocation();
    return locationObtained;
  } catch (e) {
    debugPrint("Error initializing location service: $e");
    return false;
  }
}

  void dispose() {
    if (_mapInitialized) {
      _mapController.dispose();
    }
  }

  // Method to set the custom marker icon
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
Future<bool> getCurrentLocation() async {
  const locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 10,
    timeLimit: Duration(seconds: 10),
  );

  try {
    final position = await Geolocator.getCurrentPosition(
      locationSettings: locationSettings,
    );

    _currentPosition = LatLng(position.latitude, position.longitude);
    _isLoading = false;

    updateMarkers();

    if (_mapInitialized) {
      _mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _currentPosition, zoom: 15),
        ),
      );
      onLocationUpdated?.call();
    }
    return true;
  } catch (e) {
    // If high accuracy times out, try with lower accuracy
    if (e is TimeoutException) {
      try {
        const locationSett = LocationSettings(
          accuracy: LocationAccuracy.medium,
          distanceFilter: 10,
          timeLimit: Duration(seconds: 5),
        );
        Position position = await Geolocator.getCurrentPosition(
          locationSettings: locationSett,
        );

        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoading = false;
        updateMarkers();
        return true;
      } catch (fallbackError) {
        debugPrint("Location fallback error: $fallbackError");
        _isLoading = false;
        return false;
      }
    } else {
      debugPrint("Location error: $e");
      _isLoading = false;
      return false;
    }
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
  // Method to update map with selected location
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
