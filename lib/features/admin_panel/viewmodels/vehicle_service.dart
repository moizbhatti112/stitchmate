import 'package:flutter/material.dart';
import 'package:stitchmate/features/admin_panel/models/vehicle_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VehicleService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // Get all vehicles (both cars and planes)
  Future<List<Vehicle>> getAllVehicles() async {
    try {
      debugPrint('Fetching all vehicles...');
      final response = await _supabase
          .from('vehicles')
          .select()
          .order('created_at', ascending: false);
      
      debugPrint('Received ${response.length} vehicles from Supabase');
      return response.map<Vehicle>((json) => Vehicle.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching vehicles: $e');
      return [];
    }
  }
  
  // Get only cars
  Future<List<Vehicle>> getCars() async {
    try {
      debugPrint('Fetching cars...');
      final response = await _supabase
          .from('vehicles')
          .select()
          .eq('vehicle_type', 'car')
          .order('created_at', ascending: false);
      
      debugPrint('Received ${response.length} cars from Supabase');
      debugPrint('Raw cars data: $response');
      
      final cars = response.map<Vehicle>((json) => Vehicle.fromJson(json)).toList();
      debugPrint('Parsed ${cars.length} car objects');
      return cars;
    } catch (e) {
      debugPrint('Error fetching cars: $e');
      // Print stack trace for more detail
      debugPrintStack(label: 'Stack trace for car fetching error');
      return [];
    }
  }
  


  
  // Get vehicle by ID
  Future<Vehicle?> getVehicleById(int id) async {
    try {
      debugPrint('Fetching vehicle with ID: $id');
      final response = await _supabase
          .from('vehicles')
          .select()
          .eq('id', id)
          .single();
      
      debugPrint('Received vehicle data: $response');
      return Vehicle.fromJson(response);
    } catch (e) {
      debugPrint('Error fetching vehicle by ID: $e');
      return null;
    }
  }
  
  // Delete vehicle (admin function)
  Future<bool> deleteVehicle(int id) async {
    try {
      await _supabase
          .from('vehicles')
          .delete()
          .eq('id', id);
      
      debugPrint('Vehicle with ID $id deleted successfully');
      return true;
    } catch (e) {
      debugPrint('Error deleting vehicle: $e');
      return false;
    }
  }
  
  // Verify Supabase connection and bucket access
  Future<bool> verifyConnection() async {
    try {
      // Test database access
      final testQuery = await _supabase
          .from('vehicles')
          .select('count')
          .single();
      
      debugPrint('Database connection test: $testQuery');
      
      // Test storage access
      final bucketExists = await _supabase.storage
          .getBucket('vehicle_images');
      
      // ignore: unnecessary_null_comparison
      debugPrint('Storage bucket exists: ${bucketExists != null}');
      
      return true;
    } catch (e) {
      debugPrint('Connection verification failed: $e');
      return false;
    }
  }
}