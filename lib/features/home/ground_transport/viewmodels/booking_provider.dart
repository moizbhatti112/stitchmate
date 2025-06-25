import 'package:flutter/material.dart';

class BookingProvider extends ChangeNotifier {
  String _pickupLocation = '';
  String _dropoffLocation = '';
  String _date = '';
  String _time = '';
  String _duration = '';

  // Getters
  String get pickupLocation => _pickupLocation;
  String get dropoffLocation => _dropoffLocation;
  String get date => _date;
  String get time => _time;
  String get duration => _duration;

  // Setters
  void setPickupLocation(String location) {
    _pickupLocation = location;
    notifyListeners();
  }

  void setDropoffLocation(String location) {
    _dropoffLocation = location;
    notifyListeners();
  }

  void setDate(String date) {
    _date = date;
    notifyListeners();
  }

  void setTime(String time) {
    _time = time;
    notifyListeners();
  }

  void setDuration(String duration) {
    _duration = duration;
    notifyListeners();
  }

  // Helper to check if this is an hourly booking
  bool get isHourlyBooking => _duration.isNotEmpty;

  // Clear all data
  void clearBookingData() {
    _pickupLocation = '';
    _dropoffLocation = '';
    _date = '';
    _time = '';
    _duration = '';
    notifyListeners();
  }
}
