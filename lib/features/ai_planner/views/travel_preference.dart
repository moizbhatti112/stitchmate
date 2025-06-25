import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:stitchmate/core/constants/colors.dart';
import 'package:stitchmate/features/ai_planner/views/trip_plan_results.dart';
import 'package:stitchmate/features/home/ground_transport/api_service/autocomplete_prediction.dart';
import 'package:stitchmate/features/home/ground_transport/api_service/location_api_service.dart';

class TravelPreferencesScreen extends StatefulWidget {
  const TravelPreferencesScreen({super.key});

  @override
  State<TravelPreferencesScreen> createState() =>
      _TravelPreferencesScreenState();
}

class _TravelPreferencesScreenState extends State<TravelPreferencesScreen> {
  String? selectedLocation;
  String customLocation = '';
  TextEditingController daysController = TextEditingController(text: '3');
  TextEditingController locationController = TextEditingController();
  String budget = 'moderate';
  String selectedCompanion = 'solo';
  List<AutocompletePrediction> placePredictions = [];
  Timer? _debounce;
  String _lastQuery = "";
  bool isSuggestionSelected = false;

  // final List<String> locations = ['Paris', 'Tokyo', 'New York', 'Bali', 'Rome', 'Sydney'];
  final List<String> budgetOptions = ['cheap', 'moderate', 'luxury'];
  final List<String> companionOptions = ['solo', 'couple', 'family', 'friends'];

  @override
  void initState() {
    super.initState();
    daysController.addListener(_validateDaysInput);
  }

  @override
  void dispose() {
    daysController.dispose();
    locationController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _validateDaysInput() {
    final text = daysController.text;
    if (text.isEmpty) return;

    // Remove any non-digit characters
    final cleanedText = text.replaceAll(RegExp(r'[^0-9]'), '');
    if (text != cleanedText) {
      daysController.value = daysController.value.copyWith(
        text: cleanedText,
        selection: TextSelection.collapsed(offset: cleanedText.length),
      );
    }
  }

  void placeAutocomplete(String query) async {
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }

    if (query == _lastQuery) return;

    _lastQuery = query;

    if (query.isEmpty) {
      setState(() {
        placePredictions = [];
      });
      return;
    }

    _debounce = Timer(Duration(milliseconds: 500), () async {
      List<AutocompletePrediction> predictions =
          await LocationApiService.getPlacePredictions(query);

      if (mounted) {
        setState(() {
          placePredictions = predictions;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Plan Your Perfect Trip',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tell us your preferences to get personalized recommendations',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            SizedBox(height: 12),

            SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter your destination',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: locationController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    hintText: 'Type your destination',
                    prefixIcon: Icon(Icons.location_on, color: primaryColor),
                  ),
                  onChanged: (value) {
                    setState(() {
                      customLocation = value;
                      if (value.isNotEmpty) {
                        selectedLocation = null;
                        isSuggestionSelected = false;
                      }
                    });
                    placeAutocomplete(value);
                  },
                ),
                if (placePredictions.isNotEmpty)
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: placePredictions.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: Icon(
                            Icons.location_on_outlined,
                            color: Colors.grey,
                          ),
                          title: Text(
                            placePredictions[index].description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 14),
                          ),
                          onTap: () {
                            setState(() {
                              locationController.text =
                                  placePredictions[index].description;
                              customLocation =
                                  placePredictions[index].description;
                              placePredictions = [];
                              isSuggestionSelected = true;
                            });
                            FocusScope.of(context).unfocus();
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
            SizedBox(height: 24),

            // Number of Days - Now with TextField
            _buildSectionTitle('Trip Duration'),
            SizedBox(height: 12),
            TextField(
              controller: daysController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                hintText: 'Number of days',
                prefixIcon: Icon(Icons.calendar_today, color: primaryColor),
                suffixText: 'days',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            SizedBox(height: 24),

            // Budget Selection
            _buildSectionTitle('Budget'),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:
                  budgetOptions.map((option) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          budget = option;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color:
                              budget == option
                                  ? primaryColor.withValues(alpha: 0.2)
                                  : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                budget == option
                                    ? primaryColor
                                    : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              option == 'cheap'
                                  ? Icons.attach_money
                                  : option == 'moderate'
                                  ? Icons.money
                                  : Icons.money_off_csred,
                              color:
                                  budget == option
                                      ? primaryColor
                                      : Colors.grey.shade700,
                            ),
                            SizedBox(height: 4),
                            Text(
                              option[0].toUpperCase() + option.substring(1),
                              style: TextStyle(
                                color:
                                    budget == option
                                        ? primaryColor
                                        : Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
            ),
            SizedBox(height: 24),

            // Travel Companions
            _buildSectionTitle('Traveling With'),
            SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  companionOptions.map((option) {
                    return ChoiceChip(
                      label: Text(
                        option[0].toUpperCase() + option.substring(1),
                      ),
                      selected: selectedCompanion == option,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            selectedCompanion = option;
                          });
                        }
                      },
                      selectedColor: primaryColor.withValues(alpha: 0.2),
                      checkmarkColor: primaryColor,
                      labelStyle: TextStyle(
                        color:
                            selectedCompanion == option
                                ? primaryColor
                                : Colors.black87,
                      ),
                      shape: StadiumBorder(
                        side: BorderSide(
                          color:
                              selectedCompanion == option
                                  ? primaryColor
                                  : Colors.grey.shade300,
                        ),
                      ),
                    );
                  }).toList(),
            ),
            SizedBox(height: 40),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final destination =
                      customLocation.isNotEmpty
                          ? customLocation
                          : selectedLocation;
                  final days = int.tryParse(daysController.text) ?? 3;

                  if (destination == null || destination.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please select or enter a destination'),
                      ),
                    );
                    return;
                  }

                  if (!isSuggestionSelected) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Please select a location from the suggestions',
                        ),
                      ),
                    );
                    return;
                  }

                  // Navigate to trip plan results
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => TripPlanResults(
                            destination: destination,
                            days: days,
                            budget: budget,
                            companions: [selectedCompanion],
                          ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Find Perfect Trips',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }
}
