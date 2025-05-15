import 'dart:async';

import 'package:flutter/material.dart';

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart';
import 'package:stitchmate/core/constants/colors.dart';

class LocationService {
  final VoidCallback? onLocationUpdated;
  final bool useCurrentLocation;

  LocationService({
    this.onLocationUpdated, 
    this.useCurrentLocation = true,
  });

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
  double _distanceInKm = 0.0;
  int _calculatedPrice = 0;

  // Add these getters
  String get estimatedDistance => _estimatedDistance;
  String get estimatedDuration => _estimatedDuration;
  double get distanceInKm => _distanceInKm;
  int get calculatedPrice => _calculatedPrice;
  
  // Fetch best route from Directions API
  Future<void> getRoutePolyline(LatLng pickup, LatLng dropoff) async {
    try {
      // Calculate straight-line distance
      double distanceInMeters = Geolocator.distanceBetween(
        pickup.latitude,
        pickup.longitude,
        dropoff.latitude,
        dropoff.longitude,
      );
      
      // Convert to kilometers and format
      _distanceInKm = distanceInMeters / 1000;
      _estimatedDistance = "${_distanceInKm.toStringAsFixed(1)} km";
      
      // Calculate price at 50 per km
      _calculatedPrice = (_distanceInKm * 50).round();
      
      // Calculate estimated flight time (assuming average speed of 800 km/h for a private jet)
      double timeInHours = _distanceInKm / 800;
      int hours = timeInHours.floor();
      int minutes = ((timeInHours - hours) * 60).round();
      
      if (hours > 0) {
        _estimatedDuration = "$hours h ${minutes > 0 ? '$minutes min' : ''}";
      } else {
        _estimatedDuration = "$minutes min";
      }
      
      debugPrint("Air Distance: $_estimatedDistance, Duration: $_estimatedDuration");
      
      // Create a direct polyline between the two points
      _polylines.clear();
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('air_route'),
          points: [pickup, dropoff], // Just two points for a straight line
          color: blacktext,
          width: 3, // Slightly wider for visibility
          patterns: [
            PatternItem.dash(20), // Create a dashed line for the flight path
            PatternItem.gap(10),
          ],
        ),
      );

      // Update map view to show route
      if (_mapInitialized) {
        _mapController.animateCamera(
          CameraUpdate.newLatLngBounds(_calculateMarkerBounds(), 100),
        );
      }

      debugPrint("Air route polyline added successfully between pickup and dropoff");
      onLocationUpdated?.call();
    } catch (e) {
      debugPrint("Exception in getRoutePolyline: $e");
    }
  }

  /////////////////////////////////////////////////////////////////////////////
  Future<bool> initialize({bool? useCurrentLocation}) async {
    try {
      await _loadMapStyle();
      
      // If useCurrentLocation parameter is provided, use it; otherwise, use the class field
      final shouldUseCurrentLocation = useCurrentLocation ?? this.useCurrentLocation;
      
      // If we don't need current location, just return successfully
      if (!shouldUseCurrentLocation) {
        _isLoading = false;
        return true;
      }
      
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

    // Use the pickup location marker if it exists, otherwise use current position
    LatLng pickupLocation = _currentPosition;
    for (var marker in _markers) {
      if (marker.markerId.value == "pickup_location" || 
          marker.markerId.value == "current_location") {
        pickupLocation = marker.position;
        break;
      }
    }

    // Route ko fetch karne ke liye function call karo
    getRoutePolyline(pickupLocation, location);

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

    if (useCurrentLocation) {
      Future.delayed(const Duration(milliseconds: 300), () {
        zoomToCurrentLocation();
      });
    }
  }

  ///////////////////////////////////////////////////////////////////////////////////////////
  // Get Current Location and Add Marker
  Future<bool> getCurrentLocation() async {
    if (!useCurrentLocation) {
      // If we're not using current location, just return success without trying to get it
      _isLoading = false;
      return true;
    }
    
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
    if (!useCurrentLocation) return;
    
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
    String markerIdForPickup = useCurrentLocation ? "current_location" : "pickup_location";

    // Save dropoff marker position if it exists
    for (var marker in _markers) {
      if (marker.markerId.value == "dropoff_location") {
        dropoffPosition = marker.position;
      }
    }

    _markers.clear();

    _markers.add(
      Marker(
        markerId: MarkerId(markerIdForPickup),
        position: _currentPosition,
        icon: _markerIcon,
        infoWindow: const InfoWindow(title: "Pickup Location"),
      ),
    );

    // Add back dropoff marker if it existed
    if (dropoffPosition != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId("dropoff_location"),
          position: dropoffPosition,
          icon: _dropoffMarkerIcon,
          infoWindow: const InfoWindow(title: "Drop-off Location"),
        ),
      );
      
      // Recreate the air route when markers are updated
      getRoutePolyline(_currentPosition, dropoffPosition);
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