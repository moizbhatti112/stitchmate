import 'dart:convert';
import 'package:stitchmate/features/home/ground_transport/api_service/autocomplete_prediction.dart'; // Import your custom class

class PlaceAutoCompleteResponse {
  final String status;
  final List<AutocompletePrediction> predictions;

  PlaceAutoCompleteResponse({
    required this.status,
    required this.predictions,
  });

  factory PlaceAutoCompleteResponse.fromJson(Map<String, dynamic> json) {
    return PlaceAutoCompleteResponse(
      status: json['status'] as String? ?? "UNKNOWN", 
      predictions: (json['predictions'] as List?)
              ?.map((e) => AutocompletePrediction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [], 
    );
  }

  static PlaceAutoCompleteResponse parseAutoCompleteResult(String responseBody) {
    final parsed = jsonDecode(responseBody);
    return PlaceAutoCompleteResponse.fromJson(parsed);
  }
  
}

