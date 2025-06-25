import 'package:flutter/material.dart';

class Vehicle {
  final int id;
  final String name;
  final String model;
  final int year;
  final double? price;
  final String imageUrl;
  final String description;
  final String vehicleType;
  final DateTime createdAt;

  // Optional fields for planes
  final int? rangeKm;
  final int? maxAltitudeFt;
  final int? maxSpeedKn;

  Vehicle({
    required this.id,
    required this.name,
    required this.model,
    required this.year,
    this.price,
    required this.imageUrl,
    required this.description,
    required this.vehicleType,
    required this.createdAt,
    this.rangeKm,
    this.maxAltitudeFt,
    this.maxSpeedKn,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    // Add debug print to check raw data
    debugPrint('Raw vehicle JSON: $json');

    // Safely parse the id field - could be int or String
    int parsedId;
    if (json['id'] is int) {
      parsedId = json['id'] as int;
    } else if (json['id'] is String) {
      parsedId = int.parse(json['id'] as String);
    } else {
      throw FormatException('Invalid ID format: ${json['id']}');
    }

    // Safely parse the year field - could be int or String
    int parsedYear;
    if (json['year'] is int) {
      parsedYear = json['year'] as int;
    } else if (json['year'] is String) {
      parsedYear = int.parse(json['year'] as String);
    } else {
      throw FormatException('Invalid year format: ${json['year']}');
    }

    // Safely parse the price field - could be double, int, String, or null
    double? parsedPrice;
    if (json['price'] != null) {
      if (json['price'] is double) {
        parsedPrice = json['price'] as double;
      } else if (json['price'] is int) {
        parsedPrice = (json['price'] as int).toDouble();
      } else if (json['price'] is String) {
        parsedPrice = double.parse(json['price'] as String);
      }
    }

    // Safely parse optional plane fields (if they exist)
    int? rangeKm;
    if (json['range_km'] != null) {
      if (json['range_km'] is int) {
        rangeKm = json['range_km'] as int;
      } else if (json['range_km'] is String) {
        rangeKm = int.parse(json['range_km'] as String);
      }
    }

    int? maxAltitudeFt;
    if (json['max_altitude_ft'] != null) {
      if (json['max_altitude_ft'] is int) {
        maxAltitudeFt = json['max_altitude_ft'] as int;
      } else if (json['max_altitude_ft'] is String) {
        maxAltitudeFt = int.parse(json['max_altitude_ft'] as String);
      }
    }

    int? maxSpeedKn;
    if (json['max_speed_kn'] != null) {
      if (json['max_speed_kn'] is int) {
        maxSpeedKn = json['max_speed_kn'] as int;
      } else if (json['max_speed_kn'] is String) {
        maxSpeedKn = int.parse(json['max_speed_kn'] as String);
      }
    }

    return Vehicle(
      id: parsedId,
      name: json['name'] as String,
      model: json['model'] as String,
      year: parsedYear,
      price: parsedPrice,
      imageUrl: json['image_url'] as String,
      description: json['description'] as String,
      vehicleType: json['vehicle_type'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      rangeKm: rangeKm,
      maxAltitudeFt: maxAltitudeFt,
      maxSpeedKn: maxSpeedKn,
    );
  }

  bool get isPlane => vehicleType == 'plane';
  bool get isCar => vehicleType == 'car';

  // Format price as currency
  String get formattedPrice {
    return price != null ? '\$${price!.toStringAsFixed(2)}' : 'Price not set';
  }
}
