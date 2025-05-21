// profile_image_notifier.dart
import 'package:flutter/material.dart';

/// A global notifier for profile image changes that supports multiple users
class ProfileImageChangeNotifier extends ChangeNotifier {
  // Singleton pattern
  static final ProfileImageChangeNotifier _instance =
      ProfileImageChangeNotifier._internal();

  factory ProfileImageChangeNotifier() {
    return _instance;
  }

  ProfileImageChangeNotifier._internal();

  // Map to hold image URLs for each user
  final Map<String, String?> _imageUrls = {};

  // ValueNotifier to track when images were last updated
  final ValueNotifier<DateTime> lastUpdated = ValueNotifier<DateTime>(
    DateTime.now(),
  );

  // Method to update the image URL for a specific user
  void updateImageUrl(String userId, String? url) {
    _imageUrls[userId] = url;
    lastUpdated.value = DateTime.now();
    notifyListeners();
  }

  // Method to get image URL for a specific user
  String? getImageUrl(String userId) {
    return _imageUrls[userId];
  }

  // Clear image cache for a specific user (useful for logout)
  void clearImageUrl(String userId) {
    _imageUrls.remove(userId);
    notifyListeners();
  }

  // Clear all cached images (full app reset)
  void clearAllImageUrls() {
    _imageUrls.clear();
    lastUpdated.value = DateTime.now();
    notifyListeners();
  }
}
