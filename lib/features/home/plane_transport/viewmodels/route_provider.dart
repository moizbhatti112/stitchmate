import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlaneRouteProvider extends ChangeNotifier {
  LatLng? _pickupLocation;
  LatLng? _dropoffLocation;

  LatLng? get pickupLocation => _pickupLocation;
  LatLng? get dropoffLocation => _dropoffLocation;

  void setPickupLocation(LatLng location) {
    _pickupLocation = location;
    notifyListeners();
  }

  void setDropoffLocation(LatLng location) {
    _dropoffLocation = location;
    notifyListeners();
  }
}
