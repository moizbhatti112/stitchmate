import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:stitchmate/features/ai_planner/models/trip_plan.dart';

class TripPlanRepository {
  final SupabaseClient _supabase;
  static const String _tableName = 'trip_plans';

  TripPlanRepository(this._supabase);

  Future<TripPlan> saveTripPlan({
    required String destination,
    required int days,
    required String budget,
    required List<String> companions,
    required String tripPlan,
    required String localInsights,
    required String userId,
  }) async {
    final data = {
      'destination': destination,
      'days': days,
      'budget': budget,
      'companions': companions,
      'trip_plan': tripPlan,
      'local_insights': localInsights,
      'user_id': userId,
      'created_at': DateTime.now().toIso8601String(),
    };

    final response =
        await _supabase.from(_tableName).insert(data).select().single();

    return TripPlan.fromPostgrest(response);
  }

  Future<List<TripPlan>> getUserTripPlans(String userId) async {
    final response = await _supabase
        .from(_tableName)
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return response.map((json) => TripPlan.fromPostgrest(json)).toList();
  }

  Future<TripPlan> getTripPlan(String id) async {
    final response =
        await _supabase.from(_tableName).select().eq('id', id).single();

    return TripPlan.fromPostgrest(response);
  }

  Future<void> deleteTripPlan(String id) async {
    await _supabase.from(_tableName).delete().eq('id', id);
  }
}
