import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:stitchmate/features/ai_planner/services/gemini_api_config.dart';
import 'package:stitchmate/features/ai_planner/repositories/trip_plan_repository.dart';
import 'package:stitchmate/features/ai_planner/models/trip_plan.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TripPlannerService {
  final GeminiApiConfig _apiConfig;
  final TripPlanRepository _repository;
  GenerativeModel? _model;
  ChatSession? _chat;
  bool _isInitialized = false;

  TripPlannerService()
    : _apiConfig = GeminiApiConfig(),
      _repository = TripPlanRepository(Supabase.instance.client);

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      final apiKey = await _apiConfig.getApiKey();
      final modelName = await _apiConfig.getModel();
      _model = GenerativeModel(model: modelName, apiKey: apiKey);
      _chat = _model!.startChat();
      _isInitialized = true;
    }
  }

  Future<TripPlan> generateTripPlan({
    required String destination,
    required int days,
    required String budget,
    required List<String> companions,
    required String userId,
  }) async {
    try {
      await _ensureInitialized();

      final prompt = '''
Create a detailed $days-day trip plan for ${companions.join(', ')} traveling to $destination with a $budget budget.
Include:
1. Daily itinerary with recommended activities and attractions
2. Estimated costs for each activity
3. Local transportation options
4. Recommended accommodations
5. Local cuisine recommendations
6. Tips for the specific travel companions
7. Any special considerations based on the budget level

Format the response in a clear, organized way with sections and bullet points.
''';

      final tripPlanResponse = await _chat!.sendMessage(Content.text(prompt));
      final tripPlan =
          tripPlanResponse.text ??
          'Unable to generate trip plan. Please try again.';

      final localInsightsPrompt = '''
Provide local insights and tips for ${companions.join(', ')} traveling to $destination with a $budget budget.
Include:
1. Best times to visit attractions
2. Local customs and etiquette
3. Safety tips
4. Money-saving tips for the specific budget level
5. Local transportation hacks
6. Hidden gems and off-the-beaten-path recommendations
7. Cultural considerations for the travel companions

Format the response in a clear, organized way with sections and bullet points.
''';

      final localInsightsResponse = await _chat!.sendMessage(
        Content.text(localInsightsPrompt),
      );
      final localInsights =
          localInsightsResponse.text ??
          'Unable to generate local insights. Please try again.';

      // Save the trip plan to the database
      return await _repository.saveTripPlan(
        destination: destination,
        days: days,
        budget: budget,
        companions: companions,
        tripPlan: tripPlan,
        localInsights: localInsights,
        userId: userId,
      );
    } catch (e) {
      throw Exception('Error generating trip plan: $e');
    }
  }

  Future<List<TripPlan>> getUserTripPlans(String userId) async {
    return await _repository.getUserTripPlans(userId);
  }

  Future<TripPlan?> getTripPlan(String id) async {
    return await _repository.getTripPlan(id);
  }

  Future<void> deleteTripPlan(String id) async {
    await _repository.deleteTripPlan(id);
  }
}
