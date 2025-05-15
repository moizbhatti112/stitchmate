// This is the fixed version of plane_type.dart
class PlaneTypeModel {
  final int? id;
  final String path;
  final String price;
  final String title;
  final String? imageUrl;

  PlaneTypeModel({
    this.id,
    required this.path,
    required this.price,
    required this.title,
    this.imageUrl,
  });
  
  // ADDED: Factory method to create a PlaneTypeModel from JSON
  factory PlaneTypeModel.fromJson(Map<String, dynamic> json) {
    return PlaneTypeModel(
      id: json['id'] is String ? int.tryParse(json['id']) : json['id'],
      path: json['path'] ?? 'assets/images/plane1.png',
      price: (json['price'] ?? '0.00').toString(),
      title: json['name'] ?? json['title'] ?? 'Unknown',
      imageUrl: json['image_url'],
    );
  }
  
  // ADDED: Method to convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'path': path,
      'price': price,
      'title': title,
      'image_url': imageUrl,
    };
  }
}

class PlaneDetailsModel {
  final int id;
  final String name;
  final String model;
  final int year;
  final String description;

  PlaneDetailsModel({
    required this.id,
    required this.name,
    required this.model,
    required this.year,
    required this.description,
  });
  
  // ADDED: Factory method to create a PlaneDetailsModel from JSON
  factory PlaneDetailsModel.fromJson(Map<String, dynamic> json) {
    return PlaneDetailsModel(
      id: json['id'] is String ? int.tryParse(json['id']) ?? 0 : json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      model: json['model'] ?? 'Unknown',
      year: json['year'] is String ? 
          int.tryParse(json['year']) ?? 2023 : 
          json['year'] ?? 2023,
      description: json['description'] ?? '',
    );
  }
  
  // ADDED: Method to convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'model': model,
      'year': year,
      'description': description,
    };
  }
}