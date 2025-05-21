import 'package:flutter/material.dart';

class ItineraryItem {
  final String id;
  final String type; // 'ground' or 'plane'
  final String pickupLocation;
  final String dropoffLocation;
  final String date;
  final String time;
  final String duration;
  final int price;
  final String paymentMethod;
  final DateTime createdAt;

  ItineraryItem({
    required this.id,
    required this.type,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.date,
    required this.time,
    required this.duration,
    required this.price,
    required this.paymentMethod,
    required this.createdAt,
  });
}

class ItineraryProvider extends ChangeNotifier {
  final List<ItineraryItem> _items = [];

  List<ItineraryItem> get items => _items;

  void addItem(ItineraryItem item) {
    _items.add(item);
    notifyListeners();
  }

  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void clearItems() {
    _items.clear();
    notifyListeners();
  }
}
