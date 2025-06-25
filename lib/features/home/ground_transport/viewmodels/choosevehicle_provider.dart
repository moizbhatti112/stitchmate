import 'package:flutter/material.dart';
import 'package:stitchmate/features/admin_panel/models/vehicle_model.dart';
import 'package:stitchmate/features/admin_panel/viewmodels/vehicle_service.dart';

class CarType {
  final String title;
  final String path;
  final String? price; // Made price optional
  final String? imageUrl; // Added for Supabase image URL
  final String? description; // Added for Supabase description
  final int? id; // Added for Supabase ID

  CarType({
    required this.title,
    required this.path,
    this.price, // Made price optional
    this.imageUrl,
    this.description,
    this.id,
  });
}

class ChooseVehicleProvider extends ChangeNotifier {
  final VehicleService _vehicleService = VehicleService();
  int selectedCarIndex = 0;
  String selectedCar = '';
  bool isLoading = false;
  String? errorMessage;

  // Default car types (will be replaced with data from Supabase)
  List<CarType> carTypes = [
    CarType(title: 'Luxury', path: 'assets/images/mercedes.png', price: '120'),
    CarType(title: 'Economy', path: 'assets/images/electric.png', price: '80'),
    CarType(title: 'SUV', path: 'assets/images/car.png', price: '150'),
  ];

  // List to store Supabase vehicle data
  List<Vehicle> supabaseVehicles = [];

  ChooseVehicleProvider() {
    // Load vehicles when provider is initialized
    loadVehicles();
  }

  // Fetch vehicles from Supabase
  Future<void> loadVehicles() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // Get cars from Supabase
      final cars = await _vehicleService.getCars();

      if (cars.isNotEmpty) {
        // Convert Vehicle objects to CarType objects
        carTypes =
            cars
                .map(
                  (car) => CarType(
                    id: car.id,
                    title: car.name,
                    path:
                        'assets/images/mercedes.png', // Default image as fallback
                    price: car.price.toString(), // Handle null price
                    imageUrl: car.imageUrl,
                    description: car.description,
                  ),
                )
                .toList();

        // Store the original vehicles for reference
        supabaseVehicles = cars;
      }
    } catch (e) {
      errorMessage = 'Failed to load vehicles: $e';
      debugPrint(errorMessage);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Method to refresh the vehicle list - will be called when navigating to the screen
  Future<void> refreshVehicles() async {
    // Reset selected index to avoid issues with changing data set
    selectedCarIndex = 0;
    // Call loadVehicles to fetch fresh data
    await loadVehicles();
  }

  void selectCar(int index) {
    selectedCarIndex = index;
    notifyListeners();
  }

  // Get vehicle details by index
  Vehicle? getSelectedVehicleDetails() {
    if (supabaseVehicles.isEmpty ||
        selectedCarIndex >= supabaseVehicles.length) {
      return null;
    }
    return supabaseVehicles[selectedCarIndex];
  }
}
