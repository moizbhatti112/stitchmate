import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gyde/core/constants/api_key.dart';
import 'package:gyde/core/constants/colors.dart';
import 'package:gyde/features/home/ground_transport/autocomplete_prediction.dart';
import 'package:gyde/features/home/ground_transport/autocomplete_response.dart';
import 'package:gyde/features/home/ground_transport/network_repo.dart';
import 'package:gyde/features/home/ground_transport/viewmodels/location_service.dart';

class LocationInput extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String iconPath;
  final VoidCallback onTap;
  final bool isDropoff;

  const LocationInput({
    super.key,
    required this.controller,
    required this.hintText,
    required this.iconPath,
    required this.onTap,
    required this.isDropoff,
  });

  @override
  State<LocationInput> createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  LocationService curretnloc = LocationService();
  List<AutocompletePrediction> placePredictions = [];
  FocusNode focusNode = FocusNode();
  bool showButtons = false; // To control button visibility

  @override
  void initState() {
    super.initState();
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        setState(() {
          showButtons = true; // Jab user tap kare, buttons enable ho jayein
        });
      }
    });
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          focusNode: focusNode,
          onTap: () {
            widget.onTap();
            setState(() {
              showButtons = true; // Tap karne se buttons enable ho jayein
            });
          },
          controller: widget.controller,
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: const EdgeInsets.all(10.0),
              child: SvgPicture.asset(widget.iconPath, width: 20, height: 20),
            ),
            hintText: widget.hintText,
            hintStyle: TextStyle(color: phonefieldtext),
            filled: true,
            fillColor: phonefieldColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (value) {
            if (value.isEmpty) {
              setState(() {
                placePredictions =
                    []; // Jab field empty ho, predictions hide ho jayein
              });
            } else {
              placeAutocomplete(value);
            }
          },
        ),


  const SizedBox(height: 10),
  if (!widget.isDropoff)
  GestureDetector(
    onTap: () async {
      await getCurrentLocationAndSet();
      if(context.mounted)
      {
        FocusScope.of(context).unfocus();
      }
    },
    child: SizedBox(
      height: size.height * 0.05,
      width: double.infinity,
      child: Row(
        children: [
          SizedBox(width: size.width * 0.03),
          SvgPicture.asset('assets/icons/loc.svg'),
          SizedBox(width: size.width * 0.03),
          Text(
            'Current Location',
            style: TextStyle(
              fontSize: 16,
              fontFamily: "HelveticaNeueMedium",
              color: primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
  ),
  Divider(),


        // Location Suggestions (Shown Below Buttons)
        if (placePredictions.isNotEmpty)
          SizedBox(
            height: size.height*0.16,
            child: ListView.builder(
              shrinkWrap: true,
           
              itemCount: placePredictions.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.location_on_outlined,
                        color: lightblack,
                      ),
                      title: Text(
                        placePredictions[index].description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 16, color: lightblack),
                      ),
                      onTap: () {
                        setState(() {
                          widget.controller.text =
                              placePredictions[index].description;
                          placePredictions = [];
                          showButtons = false; // Hide buttons on selection
                        });
                        FocusScope.of(context).unfocus(); // Hide keyboard
                      },
                    ),
                    if (index < placePredictions.length - 1)
                      Divider(), // Divider only between items
                  ],
                );
              },
            ),
          ),
      ],
    );
  }

  void placeAutocomplete(String query) async {
    if (query.isEmpty) {
      setState(() {
        placePredictions = [];
      });
      return;
    }

    Uri uri = Uri.https(
      "maps.googleapis.com",
      '/maps/api/place/autocomplete/json',
      {"input": query, "key": googleApiKey, "components": "country:pk"},
    );

    String? response = await NetworkUtil.fetchUrl(uri);
    debugPrint("API Response: $response");

    if (response != null) {
      try {
        PlaceAutoCompleteResponse result =
            PlaceAutoCompleteResponse.parseAutoCompleteResult(response);

        setState(() {
          placePredictions = result.predictions;
        });
      } catch (e) {
        debugPrint("Error parsing autocomplete response: $e");
        setState(() {
          placePredictions = [];
        });
      }
    } else {
      debugPrint("No response received.");
      setState(() {
        placePredictions = [];
      });
    }
  }

Future<Map<String, String>> getDetailedAddressFromLatLng(double lat, double lng) async {
  Uri uri = Uri.https("maps.googleapis.com", "/maps/api/geocode/json", {
    "latlng": "$lat,$lng",
    "key": googleApiKey,
  });

  String? response = await NetworkUtil.fetchUrl(uri);

  if (response != null) {
    final data = json.decode(response);
    if (data["status"] == "OK") {
      final results = data["results"];
      
      // Ensure we are not using Plus Code only
      for (var result in results) {
        if (result["types"].contains("plus_code")) {
          continue; // Ignore plus code addresses
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


Future<void> getCurrentLocationAndSet() async {
  await curretnloc.getCurrentLocation();

  // Reverse Geocode to get address
  Map<String, String> addressDetails = await getDetailedAddressFromLatLng(
    curretnloc.currentPosition.latitude,
    curretnloc.currentPosition.longitude,
  );

  String formattedAddress = addressDetails["formattedAddress"] ?? "Location not found";

  setState(() {
    widget.controller.text = formattedAddress; // Set address in text field
  });
}


}
