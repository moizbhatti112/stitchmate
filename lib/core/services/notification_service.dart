import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final _supabase = Supabase.instance.client;

  Future<void> sendOrderNotification({
    required String pickupLocation,
    required String dropoffLocation,
    required String time,
    required String date,
    required String userEmail,
  }) async {
    try {
      // Create a notification record in the database
      await _supabase.from('notifications').insert({
        'type': 'new_order',
        'title': 'New Order Placed',
        'message': 'A new order has been placed',
        'data': {
          'pickup_location': pickupLocation,
          'dropoff_location': dropoffLocation,
          'time': time,
          'date': date,
          'user_email': userEmail,
          'timestamp': DateTime.now().toIso8601String(),
        },
        'is_read': false,
      });
    } catch (e) {
      debugPrint('Error sending notification: $e');
      rethrow;
    }
  }

  Stream<List<Map<String, dynamic>>> getNotifications() {
    return _supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((events) => events);
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    await _supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('id', notificationId);
  }
}
