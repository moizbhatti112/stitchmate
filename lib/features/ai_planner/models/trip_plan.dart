
class TripPlan {
  final String id;
  final String destination;
  final int days;
  final String budget;
  final List<String> companions;
  final String tripPlan;
  final String localInsights;
  final DateTime createdAt;
  final String userId;

  TripPlan({
    required this.id,
    required this.destination,
    required this.days,
    required this.budget,
    required this.companions,
    required this.tripPlan,
    required this.localInsights,
    required this.createdAt,
    required this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'destination': destination,
      'days': days,
      'budget': budget,
      'companions': companions,
      'trip_plan': tripPlan,
      'local_insights': localInsights,
      'created_at': createdAt.toIso8601String(),
      'user_id': userId,
    };
  }

  factory TripPlan.fromJson(Map<String, dynamic> json) {
    return TripPlan(
      id: json['id'],
      destination: json['destination'],
      days: json['days'],
      budget: json['budget'],
      companions: List<String>.from(json['companions']),
      tripPlan: json['trip_plan'],
      localInsights: json['local_insights'],
      createdAt: DateTime.parse(json['created_at']),
      userId: json['user_id'],
    );
  }

  factory TripPlan.fromPostgrest(Map<String, dynamic> json) {
    return TripPlan(
      id: json['id'],
      destination: json['destination'],
      days: json['days'],
      budget: json['budget'],
      companions: List<String>.from(json['companions']),
      tripPlan: json['trip_plan'],
      localInsights: json['local_insights'],
      createdAt: DateTime.parse(json['created_at']),
      userId: json['user_id'],
    );
  }
}
