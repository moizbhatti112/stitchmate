// choose_vehicle_provider.dart (ViewModel)
import 'package:flutter/material.dart';
import 'package:stitchmate/features/home/ground_transport/models/car_type.dart';

class ChooseVehicleProvider extends ChangeNotifier {
   String? selectedCar;
  List<CarTypeModel> carTypes = [
    CarTypeModel(
      path: 'assets/images/mercedes.png',
      price: '205.46',
      title: 'Business Class',
    ),
    CarTypeModel(
      path: 'assets/images/elect1.png',
      price: '215.00',
      title: 'Electric Class',
    ),
  ];

  int selectedCarIndex = 0;

  void selectCar(int index) {
    selectedCarIndex = index;
    notifyListeners();
  }
    void setSelectedCar(String car) {
    selectedCar = car;
    notifyListeners();
  }
}