// This is the fixed version of chooseplane_provider.dart
import 'package:flutter/material.dart';
import 'package:stitchmate/features/home/plane_transport/models/plane_type.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChoosePlaneProvider extends ChangeNotifier {
  String? selectedPlane;
  List<PlaneTypeModel> planeTypes = [
    PlaneTypeModel(
      path: 'assets/images/plane1.png',
      price: '205.46',
      title: 'Business Class',
    ),
    PlaneTypeModel(
      path: 'assets/images/plane2.png',
      price: '300.00',
      title: 'Luxury Class',
    ),
  ];

  int selectedPlaneIndex = 0;
  bool isLoading = false;
  String? errorMessage;
  List<PlaneDetailsModel>? planeDetails;

  final _supabase = Supabase.instance.client;

  ChoosePlaneProvider() {
    // Initialize with default data
    planeTypes = [
      PlaneTypeModel(
        path: 'assets/images/plane1.png',
        price: '205.46',
        title: 'Business Class',
      ),
      PlaneTypeModel(
        path: 'assets/images/plane2.png',
        price: '300.00',
        title: 'Luxury Class',
      ),
    ];
    
    // Initialize with default plane details
    planeDetails = [
      PlaneDetailsModel(
        id: 1,
        name: 'Cessna',
        model: 'Citation',
        year: 2023,
        description: 'Premium business jet with luxurious interior and excellent performance.',
      ),
      PlaneDetailsModel(
        id: 2,
        name: 'Gulfstream',
        model: 'G650',
        year: 2022,
        description: 'Ultra-long-range business jet with spacious cabin and state-of-the-art avionics.',
      ),
    ];
  }

  // Method to refresh planes from database
  Future<void> refreshPlanes() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // Fetch plane types from database
      final planeTypesData = await _supabase
          .from('planes')
          .select('id, name, price, description, image_url');

      // If data is fetched successfully, update planeTypes
      planeTypes = planeTypesData.map<PlaneTypeModel>((plane) {
        return PlaneTypeModel(
          // FIXED: Convert the id to int if it's a string
          id: plane['id'] is String ? int.tryParse(plane['id']) : plane['id'],
          // Use 'name' instead of 'title'
          title: plane['name'] ?? 'Unknown',
          price: (plane['price'] ?? '100.00').toString(),
          path: 'assets/images/plane1.png', // Default asset path
          // FIXED: Properly set the image URL for network images
          imageUrl: plane['image_url'] != null && 
                   (plane['image_url'] as String).isNotEmpty ? 
                    plane['image_url'] : null,
        );
      }).toList();
      
      // If we got plane types, fetch plane details as well
      try {
        final planeDetailsData = await _supabase
            .from('planes')
            .select('id, name, model, year, description');
        
        planeDetails = planeDetailsData.map<PlaneDetailsModel>((plane) {
          // FIXED: Ensure proper type handling for all fields
          return PlaneDetailsModel(
            // Convert the id to int if it's a string
            id: plane['id'] is String ? int.tryParse(plane['id']) ?? 0 : plane['id'] ?? 0,
            name: plane['name'] ?? 'Unknown',
            model: plane['model'] ?? 'Unknown',
            // Convert year to int if it's a string
            year: plane['year'] is String ? 
                int.tryParse(plane['year']) ?? 2023 : 
                plane['year'] ?? 2023,
            description: plane['description'] ?? '',
          );
        }).toList();
      } catch (detailsError) {
        // Handle plane details fetch error, but still show plane types
        debugPrint('Failed to load plane details: $detailsError');
      }
    
      // Reset selectedPlaneIndex if needed
      if (planeTypes.isNotEmpty && selectedPlaneIndex >= planeTypes.length) {
        selectedPlaneIndex = 0;
      }
    } catch (e) {
      // Update error message and keep default data
      errorMessage = 'Failed to load planes: ${e.toString()}';
      debugPrint('Error refreshing planes: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void selectPlane(int index) {
    selectedPlaneIndex = index;
    notifyListeners();
  }

  void setSelectedPlane(String plane) {
    selectedPlane = plane;
    notifyListeners();
  }

  // FIXED: Improved method to get details of the selected plane
  PlaneDetailsModel? getSelectedPlaneDetails() {
    if (planeDetails == null || planeDetails!.isEmpty || planeTypes.isEmpty) {
      return null;
    }
    
    final selectedType = planeTypes[selectedPlaneIndex];
    
    // If the selected type has no ID, return the first plane details
    if (selectedType.id == null) {
      return planeDetails!.first;
    }
    
    try {
      // Find matching plane by ID
      final matchingPlane = planeDetails!.firstWhere(
        (plane) => plane.id == selectedType.id,
        orElse: () => planeDetails!.first,
      );
      return matchingPlane;
    } catch (e) {
      debugPrint('Error getting selected plane details: $e');
      // If we can't find a matching plane, return the first one
      return planeDetails!.isNotEmpty ? planeDetails!.first : null;
    }
  }
}