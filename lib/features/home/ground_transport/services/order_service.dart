import 'package:supabase_flutter/supabase_flutter.dart';

class OrderService {
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;
  OrderService._internal();

  final _supabase = Supabase.instance.client;

  Future<void> addOrder({
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

      await _supabase.from('order_history').insert({
        'pickup': pickup,
        'dropoff': dropoff,
        'date': date,
        'time': time,
        'user_id': userId,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to add order: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> getOrdersStream() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    return _supabase
        .from('order_history')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map((events) => events);
  }

  Future<List<Map<String, dynamic>>> getOrders() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from('order_history')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch orders: $e');
    }
  }
}
