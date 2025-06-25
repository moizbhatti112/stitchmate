import 'package:flutter/material.dart';
import 'package:stitchmate/core/constants/colors.dart';
import 'package:stitchmate/features/ai_planner/models/trip_plan.dart';
import 'package:stitchmate/features/ai_planner/services/trip_planner_service.dart';
import 'package:stitchmate/features/ai_planner/views/trip_plan_results.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SavedTripPlans extends StatefulWidget {
  const SavedTripPlans({super.key});

  @override
  State<SavedTripPlans> createState() => _SavedTripPlansState();
}

class _SavedTripPlansState extends State<SavedTripPlans>
    with AutomaticKeepAliveClientMixin {
  final TripPlannerService _tripPlanner = TripPlannerService();
  final FocusNode _focusNode = FocusNode();
  List<TripPlan> _tripPlans = [];
  bool _isLoading = true;
  String? _error;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadTripPlans();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _loadTripPlans();
    }
  }

  Future<void> _loadTripPlans() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final tripPlans = await _tripPlanner.getUserTripPlans(userId);

      if (!mounted) return;

      setState(() {
        _tripPlans = tripPlans;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteTripPlan(String id) async {
    try {
      await _tripPlanner.deleteTripPlan(id);
      await _loadTripPlans(); // Reload the list
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Trip plan deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting trip plan: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return Focus(
      focusNode: _focusNode,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Saved Trip Plans',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body:
            _isLoading
                ? Center(child: CircularProgressIndicator(color: primaryColor))
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
                        onPressed: _loadTripPlans,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('Try Again'),
                      ),
                    ],
                  ),
                )
                : _tripPlans.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.travel_explore,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No saved trip plans yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                )
                : RefreshIndicator(
                  onRefresh: _loadTripPlans,
                  color: primaryColor,
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _tripPlans.length,
                    itemBuilder: (context, index) {
                      final plan = _tripPlans[index];
                      return Dismissible(
                        key: Key(plan.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(right: 20),
                          color: Colors.red,
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) {
                          _deleteTripPlan(plan.id);
                        },
                        child: Card(
                          margin: EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => TripPlanResults(
                                        destination: plan.destination,
                                        days: plan.days,
                                        budget: plan.budget,
                                        companions: plan.companions,
                                        savedTripPlan: plan,
                                      ),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          plan.destination,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '${plan.days} days',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Budget: ${plan.budget}',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Traveling with: ${plan.companions.join(", ")}',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Created: ${plan.createdAt.toString().split('.')[0]}',
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
      ),
    );
  }
}
