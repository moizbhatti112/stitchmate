import 'package:flutter/material.dart';

class BookingProvider extends ChangeNotifier {
  String? pickupLocation;
  String? dropoffLocation;
  String? date;
  String? time;
  String? selectedCar;

  void setPickupLocation(String location) {
    pickupLocation = location;
    notifyListeners();
  }

  void setDropoffLocation(String location) {
    dropoffLocation = location;
    notifyListeners();
  }

  void setDate(String selectedDate) {
    date = selectedDate;
    notifyListeners();
  }

  void setTime(String selectedTime) {
    time = selectedTime;
    notifyListeners();
  }

  void setSelectedCar(String car) {
    selectedCar = car;
    notifyListeners();
  }
}
