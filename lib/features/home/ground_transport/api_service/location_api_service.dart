import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gyde/core/constants/api_key.dart';
import 'package:gyde/features/home/ground_transport/api_service/autocomplete_prediction.dart';
import 'package:gyde/features/home/ground_transport/api_service/autocomplete_response.dart';
import 'package:gyde/features/home/ground_transport/api_service/network_repo.dart';


class LocationApiService {
  /// Fetches place predictions based on user input
  static Future<List<AutocompletePrediction>> getPlacePredictions(String query) async {
    if (query.isEmpty) {
      return [];
    }
    
    Uri uri = Uri.https(
      "maps.googleapis.com",
      '/maps/api/place/autocomplete/json',
      {"input": query, "key": googleApiKey},
    );

    String? response = await NetworkUtil.fetchUrl(uri);
      
    if (response != null) {
      try {
        PlaceAutoCompleteResponse result =
            PlaceAutoCompleteResponse.parseAutoCompleteResult(response);
        return result.predictions;
      } catch (e) {
        debugPrint("Error parsing autocomplete response: $e");
        return [];
      }
    } 
    
    debugPrint("No response received.");
    return [];
  }

  /// Get detailed address information from latitude and longitude
  static Future<Map<String, String>> getDetailedAddressFromLatLng(
    double lat,
    double lng,
  ) async {
    Uri uri = Uri.https("maps.googleapis.com", "/maps/api/geocode/json", {
      "latlng": "$lat,$lng",
      "key": googleApiKey,
    });

    String? response = await NetworkUtil.fetchUrl(uri);

    if (response != null) {
      final data = json.decode(response);
      if (data["status"] == "OK") {
        final results = data["results"];

        for (var result in results) {
          if (result["types"].contains("plus_code")) {
            continue;
          }

          final addressComponents = result["address_components"];

          String streetNumber = "";
          String route = "";
          String city = "";
          String state = "";
          String country = "";

          for (var component in addressComponents) {
            List types = component["types"];

            if (types.contains("street_number")) {
              streetNumber = component["long_name"];
            }
            if (types.contains("route")) {
              route = component["long_name"];
            }
            if (types.contains("locality")) {
              city = component["long_name"];
            }
            if (types.contains("administrative_area_level_1")) {
              state = component["long_name"];
            }
            if (types.contains("country")) {
              country = component["long_name"];
            }
          }

          return {
            "street": "$streetNumber $route".trim(),
            "city": city,
            "state": state,
            "country": country,
            "formattedAddress": result["formatted_address"],
          };
        }
      }
    }
    return {"error": "Unknown Location"};
  }

  /// Fetches coordinates (LatLng) from a place ID
  static Future<LatLng?> getLatLngFromPlaceId(String? placeId) async {
    if (placeId == null) return null;

    Uri uri = Uri.https("maps.googleapis.com", "/maps/api/place/details/json", {
      "place_id": placeId,
      "key": googleApiKey,
    });

    String? response = await NetworkUtil.fetchUrl(uri);
    
    if (response != null) {
      final data = json.decode(response);
      if (data["status"] == "OK") {
        final location = data["result"]["geometry"]["location"];
        return LatLng(location["lat"], location["lng"]);
      }
    }
    return null;
  }
  
  /// Creates a formatted address string from address components
  static String formatAddress(Map<String, String> addressDetails) {
    String formattedAddress = addressDetails["formattedAddress"] ?? "";
    
    if (formattedAddress.isEmpty) {
      List<String> addressParts = [];
      if (addressDetails["street"]?.isNotEmpty ?? false) {
        addressParts.add(addressDetails["street"]!);
      }
      if (addressDetails["city"]?.isNotEmpty ?? false) {
        addressParts.add(addressDetails["city"]!);
      }
      if (addressDetails["state"]?.isNotEmpty ?? false) {
        addressParts.add(addressDetails["state"]!);
      }
      if (addressDetails["country"]?.isNotEmpty ?? false) {
        addressParts.add(addressDetails["country"]!);
      }
      
      formattedAddress = addressParts.join(", ");
    }
    
    return formattedAddress;
  }
}