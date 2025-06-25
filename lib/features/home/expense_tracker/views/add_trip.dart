import 'package:flutter/material.dart';
import 'dart:async';
import 'package:stitchmate/core/constants/colors.dart';
import 'package:stitchmate/features/home/expense_tracker/database/db_helper.dart';
import 'package:stitchmate/features/home/ground_transport/api_service/autocomplete_prediction.dart';
import 'package:stitchmate/features/home/ground_transport/api_service/location_api_service.dart';

class AddTripScreen extends StatefulWidget {
  const AddTripScreen({super.key});

  @override
  State<AddTripScreen> createState() => _AddTripScreenState();
}

class _AddTripScreenState extends State<AddTripScreen> {
  final _destinationController = TextEditingController();
  DateTime? _startDate;
  bool _isLoading = false;
  String? _selectedCurrency;
  List<AutocompletePrediction> placePredictions = [];
  Timer? _debounce;
  String _lastQuery = "";
  bool isSuggestionSelected = false;

  final List<String> _currencies = [
    'USD',
    'EUR',
    'GBP',
    'JPY',
    'AUD',
    'CAD',
    'INR',
    'SGD',
    'AED',
    'CNY',
    'PKR',
  ];

  @override
  void dispose() {
    _destinationController.dispose();
    _debounce?.cancel();
    super.dispose();
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

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(
            context,
          ).copyWith(colorScheme: ColorScheme.light(primary: primaryColor)),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _saveTrip() async {
    if (_destinationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter destination'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!isSuggestionSelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a location from the suggestions'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select start date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final trip = {
        'destination': _destinationController.text.trim(),
        'startDate': _startDate!.toIso8601String(),
        'totalExpense': 0.0,
        'currency': _selectedCurrency,
        'createdAt': DateTime.now().toIso8601String(),
      };

      final tripId = await DatabaseHelper().insertTrip(trip);

      if (mounted) {
        Navigator.pop(context, {'id': tripId, ...trip});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving trip: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add New Trip',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: constraints.maxWidth > 600 ? 40 : 20,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Trip Details',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Enter your trip information to start tracking expenses',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    const SizedBox(height: 32),

                    // Destination Field
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _destinationController,
                          decoration: InputDecoration(
                            labelText: 'Destination',
                            hintText: 'e.g., Paris, France',
                            prefixIcon: Icon(
                              Icons.location_on,
                              color: primaryColor,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: primaryColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: primaryColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: primaryColor,
                                width: 2,
                              ),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              isSuggestionSelected = false;
                            });
                            placeAutocomplete(value);
                          },
                        ),
                        if (placePredictions.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(top: 8),
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
                                      _destinationController.text =
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
                    const SizedBox(height: 20),

                    // Start Date Field
                    GestureDetector(
                      onTap: _selectStartDate,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: primaryColor),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, color: primaryColor),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Start Date',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  Text(
                                    _startDate != null
                                        ? _formatDate(_startDate!)
                                        : 'Select start date',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color:
                                          _startDate != null
                                              ? Colors.black87
                                              : Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Currency Selection
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: primaryColor),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCurrency,
                          isExpanded: true,
                          padding: const EdgeInsets.symmetric(horizontal: 0),
                          icon: const Icon(Icons.arrow_drop_down),
                          hint: const Text(
                            'Select a currency',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                          items:
                              _currencies.map((String currency) {
                                return DropdownMenuItem<String>(
                                  value: currency,
                                  child: Text(currency),
                                );
                              }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedCurrency = newValue;
                              });
                            }
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveTrip,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child:
                            _isLoading
                                ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : const Text(
                                  'Create Trip',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
