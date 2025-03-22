import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gyde/core/constants/api_key.dart';
import 'package:gyde/core/constants/colors.dart';
import 'package:gyde/features/home/ground_transport/autocomplete_prediction.dart';
import 'package:gyde/features/home/ground_transport/autocomplete_response.dart';
import 'package:gyde/features/home/ground_transport/network_repo.dart';

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
  List<AutocompletePrediction> placePredictions = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          onTap: widget.onTap,
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
            if (value.isNotEmpty) {
              placeAutocomplete(value);
            } else {
              setState(() {
                placePredictions = [];
              });
            }
          },
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return "Please enter ${widget.hintText}";
            }
            return null;
          },
        ),
        if (placePredictions.isNotEmpty)
          Container(
            height: 200, // Fixed height for the suggestions list
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: placePredictions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.location_on_outlined, color: lightblack),
                  title: Text(
                    placePredictions[index].description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    setState(() {
                      widget.controller.text = placePredictions[index].description;
                      placePredictions = []; // Clear suggestions after selection
                    });
                    FocusScope.of(context).unfocus(); // Close the keyboard
                  },
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
}