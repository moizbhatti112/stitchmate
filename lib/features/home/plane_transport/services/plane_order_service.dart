import 'package:supabase_flutter/supabase_flutter.dart';

class PlaneOrderService {
  static final PlaneOrderService _instance = PlaneOrderService._internal();
  factory PlaneOrderService() => _instance;
  PlaneOrderService._internal();

  final _supabase = Supabase.instance.client;

  Future<void> addPlaneOrder({
    required String pickup,
    required String dropoff,
    required String date,
    required String time,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await _supabase.from('plane_history').insert({
        'departure': pickup,
        'arrival': dropoff,
        'date': date,
        'time': time,
        'user_id': userId,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to add plane order: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> getPlaneOrdersStream() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    return _supabase
        .from('plane_history')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map((events) => events);
  }

  Future<List<Map<String, dynamic>>> getPlaneOrders() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from('plane_history')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch plane orders: $e');
    }
  }
}
