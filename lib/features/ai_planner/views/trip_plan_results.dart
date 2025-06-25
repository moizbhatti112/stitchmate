import 'package:flutter/material.dart';
import 'package:stitchmate/core/constants/colors.dart';
import 'package:stitchmate/features/ai_planner/services/trip_planner_service.dart';
import 'package:stitchmate/features/ai_planner/models/trip_plan.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TripPlanResults extends StatefulWidget {
  final String destination;
  final int days;
  final String budget;
  final List<String> companions;
  final TripPlan? savedTripPlan;

  const TripPlanResults({
    super.key,
    required this.destination,
    required this.days,
    required this.budget,
    required this.companions,
    this.savedTripPlan,
  });

  @override
  State<TripPlanResults> createState() => _TripPlanResultsState();
}

class _TripPlanResultsState extends State<TripPlanResults> {
  final TripPlannerService _tripPlanner = TripPlannerService();
  TripPlan? _tripPlan;
  bool _isLoading = true;
  bool _showLocalInsights = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.savedTripPlan != null) {
      _tripPlan = widget.savedTripPlan;
      _isLoading = false;
    } else {
      _generateTripPlan();
    }
  }

  Future<void> _generateTripPlan() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final tripPlan = await _tripPlanner.generateTripPlan(
        destination: widget.destination,
        days: widget.days,
        budget: widget.budget,
        companions: widget.companions,
        userId: userId,
      );

      setState(() {
        _tripPlan = tripPlan;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Your Trip Plan',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body:
          _isLoading
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: primaryColor),
                    SizedBox(height: 16),
                    Text(
                      'Generating your perfect trip plan...',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
              : _error != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 48),
                    SizedBox(height: 16),
                    Text(
                      _error!,
                      style: TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _generateTripPlan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Try Again'),
                    ),
                  ],
                ),
              )
              : SingleChildScrollView(
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Trip Plan Section
                    Text(
                      'Trip Plan',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.1),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Text(
                        _tripPlan?.tripPlan ?? '',
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    SizedBox(height: 24),

                    // Local Insights Toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Local Insights',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Switch(
                          value: _showLocalInsights,
                          onChanged: (value) {
                            setState(() {
                              _showLocalInsights = value;
                            });
                          },
                          activeColor: primaryColor,
                        ),
                      ],
                    ),
                    if (_showLocalInsights) ...[
                      SizedBox(height: 16),
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withValues(alpha: 0.1),
                              spreadRadius: 1,
                              blurRadius: 10,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Text(
                          _tripPlan?.localInsights ?? '',
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
    );
  }
}
