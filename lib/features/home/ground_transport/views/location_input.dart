import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
  final Function(LatLng)? onLocationSelected;

  const LocationInput({
    super.key,
    required this.controller,
    required this.hintText,
    required this.iconPath,
    required this.onTap,
    required this.isDropoff,
    this.onLocationSelected,
  });

  @override
  State<LocationInput> createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  LocationService curretnloc = LocationService();
  List<AutocompletePrediction> placePredictions = [];
  FocusNode focusNode = FocusNode();
  bool isSuggestionSelected = false;
  bool isLocationServiceEnabled = false;
  bool isPermissionGranted = false;
  bool isCheckingPermission = false; // Flag to track when we're checking permissions
  bool isInitializing = true;
  
  @override
  void initState() {
    super.initState();
    // Check location status when widget initializes
    _checkLocationStatusOnInit();
    
    // Listen for system location service changes
    Geolocator.getServiceStatusStream().listen((ServiceStatus status) {
      _refreshLocationStatus();
    });
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  // Refresh location status without showing dialogs
  Future<void> _refreshLocationStatus() async {
    if (mounted) {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      LocationPermission permission = await Geolocator.checkPermission();
      
      setState(() {
        isLocationServiceEnabled = serviceEnabled;
        isPermissionGranted = permission == LocationPermission.whileInUse || 
                              permission == LocationPermission.always;
      });
    }
  }

  // Initial check on widget load - just sets state variables, doesn't show dialogs
  Future<void> _checkLocationStatusOnInit() async {
    await _refreshLocationStatus();
    if (mounted) {
      setState(() {
        isInitializing = false;
      });
    }
  }

  Future<bool> _checkLocationPermission({bool showDialogOnDisabled = false}) async {
    // Set checking flag to prevent multiple dialogs
    if (isCheckingPermission) return false;
    
    setState(() {
      isCheckingPermission = true;
    });
    
    try {
      // Check location service status
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      
      // Update state
      setState(() {
        isLocationServiceEnabled = serviceEnabled;
      });
      
      if (!serviceEnabled) {
        // Only show dialog if widget is mounted and showDialog flag is true
        if (showDialogOnDisabled && mounted) {
          await _showLocationServiceDialog();
          // Refresh status after dialog is closed
          await _refreshLocationStatus();
        }
        return false;
      }

      // Check permission status
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        // Request permission
        permission = await Geolocator.requestPermission();
      }

      // Update permission state
      setState(() {
        isPermissionGranted = permission == LocationPermission.whileInUse || 
                              permission == LocationPermission.always;
      });

      if (permission == LocationPermission.deniedForever) {
        // Only show dialog if widget is mounted and showDialog flag is true
        if (showDialogOnDisabled && mounted) {
          await _showPermissionDeniedDialog();
          // Refresh status after dialog is closed
          await _refreshLocationStatus();
        }
        return false;
      }

      // Return true if permissions are granted
      return permission == LocationPermission.whileInUse || 
            permission == LocationPermission.always;
    } finally {
      // Clear checking flag when done
      if (mounted) {
        setState(() {
          isCheckingPermission = false;
        });
      }
    }
  }

  Future<void> _showLocationServiceDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,  // Prevent dismissing by tapping outside
      builder: (context) => AlertDialog(
        title: Text('Location Services Disabled'),
        content: Text('Please enable your location to use this feature. The map and location selection will not work properly without location services.'),
        actions: <Widget>[
          TextButton(
            child: Text('Open Settings'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ],
      ),
    );

    if (result == true) {
      await Geolocator.openLocationSettings();
      
      // Wait a moment before checking status again to allow settings to take effect
      await Future.delayed(Duration(seconds: 2));
      await _refreshLocationStatus();
    }
  }

  Future<void> _showPermissionDeniedDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,  // Prevent dismissing by tapping outside
      builder: (context) => AlertDialog(
        title: Text('Location Permissions Denied'),
        content: Text('Location permissions are permanently denied. Please enable them in app settings to use this feature.'),
        actions: <Widget>[
          TextButton(
            child: Text('Open App Settings'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ],
      ),
    );

    if (result == true) {
      await Geolocator.openAppSettings();
      
      // Wait a moment before checking status again to allow settings to take effect
      await Future.delayed(Duration(seconds: 2));
      await _refreshLocationStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    
    // Don't show error messages during initialization
    final showLocationWarning = !isInitializing && 
                               (!isLocationServiceEnabled || !isPermissionGranted);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          focusNode: focusNode,
          onTap: () async {
            if (!isLocationServiceEnabled || !isPermissionGranted) {
              // If location permission not granted, check and show dialog
              await _checkLocationPermission(showDialogOnDisabled: true);
              
              // If still not enabled after dialog, show message
              if (!isLocationServiceEnabled || !isPermissionGranted) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Please Enable Location Services"),
                      duration: Duration(seconds: 3),
                    ),
                  );
                  FocusScope.of(context).unfocus();
                }
                return;
              }
            }
            
            // Location is enabled, proceed with onTap
            widget.onTap();
          },
          controller: widget.controller,
          enabled: !isCheckingPermission && !isInitializing,  // Disable during permission check or initialization
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: const EdgeInsets.all(10.0),
              child: SvgPicture.asset(widget.iconPath, width: 20, height: 20),
            ),
            hintText: widget.hintText,
            hintStyle: TextStyle(color: phonefieldtext),
            filled: true,
            fillColor: isInitializing 
                ? Colors.grey.shade100  // Light gray during initialization
                : (isLocationServiceEnabled && isPermissionGranted 
                    ? phonefieldColor 
                    : Colors.grey.shade200), // Different background when disabled
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            suffixIcon: isInitializing || isCheckingPermission
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                     
                    ),
                  )
                : (!isLocationServiceEnabled || !isPermissionGranted)
                    ? Tooltip(
                        message: "Location services disabled",
                        
                      )
                    : null,
          ),
          onChanged: (value) {
            if (!isLocationServiceEnabled || !isPermissionGranted || isInitializing) {
              // Don't process input if location is disabled or still initializing
              return;
            }
            
            if (value.isEmpty) {
              setState(() {
                placePredictions = [];
                isSuggestionSelected = false;
              });
            } else {
              placeAutocomplete(value);
              isSuggestionSelected = false;
            }
          },
          validator: (value) {
            if (!isInitializing && (!isLocationServiceEnabled || !isPermissionGranted)) {
              return "Location services must be enabled";
            }
            if (value == null || value.trim().isEmpty) {
              return "Please select a location";
            }
            if (!isSuggestionSelected) {
              return "Please select a location from the suggestions";
            }
            return null;
          },
        ),

        const SizedBox(height: 10),
        if (!widget.isDropoff)
          GestureDetector(
            onTap: () async {
              // Prevent interaction during initialization
              if (isInitializing) return;
              
              if (!isLocationServiceEnabled || !isPermissionGranted) {
                await _checkLocationPermission(showDialogOnDisabled: true);
                
                // After checking, if enabled proceed, otherwise skip
                if (!isLocationServiceEnabled || !isPermissionGranted) {
                  return;
                }
              }
              
              await getCurrentLocationAndSet();
              setState(() {
                isSuggestionSelected = true;
              });
              if (context.mounted) {
                widget.onLocationSelected?.call(curretnloc.currentPosition);
                FocusScope.of(context).unfocus();
              }
            },
            child: Opacity(
              opacity: isInitializing 
                  ? 0.5  // Reduced opacity during initialization
                  : (isLocationServiceEnabled && isPermissionGranted ? 1.0 : 0.5),
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
                        color: isInitializing
                            ? Colors.grey
                            : (isLocationServiceEnabled && isPermissionGranted 
                                ? primaryColor : Colors.grey),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        Divider(),

        // Location Suggestions (Shown Below Buttons)
        if (placePredictions.isNotEmpty && !isInitializing && 
            isLocationServiceEnabled && isPermissionGranted)
          SizedBox(
            height: size.height * 0.16,
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
                      onTap: () async {
                        LatLng? selectedLatLng = await getLatLngFromPlaceId(
                          placePredictions[index].placeId,
                        );

                        if (selectedLatLng != null) {
                          setState(() {
                            widget.controller.text =
                                placePredictions[index].description;
                            placePredictions = [];
                            isSuggestionSelected = true;
                          });

                          // Call the onLocationSelected callback if provided
                          widget.onLocationSelected?.call(selectedLatLng);
                          if(context.mounted)
                          {
                            FocusScope.of(context).unfocus();
                          }
                        }
                      },
                    ),
                    if (index < placePredictions.length - 1)
                      Divider(), // Divider only between items
                  ],
                );
              },
            ),
          ),
          
        // Show a message when location services are disabled
        if (showLocationWarning)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.red),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Location services must be enabled to use the map and select locations.",
                    style: TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
                TextButton(
                  onPressed: isCheckingPermission ? null : () async {
                    await _checkLocationPermission(showDialogOnDisabled: true);
                  },
                  child: isCheckingPermission 
                    ? SizedBox(
                        width: 14, 
                        height: 14, 
                        child: CircularProgressIndicator(strokeWidth: 2)
                      )
                    : Text("Enable"),
                ),
              ],
            ),
          ),
          
        // Show a loading indicator during initialization
        if (isInitializing)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                SizedBox(
                  width: 16, 
                  height: 16, 
                  child: CircularProgressIndicator(strokeWidth: 2)
                ),
                SizedBox(width: 8),
                Text(
                  "Checking location services...",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // Rest of methods unchanged...
  
  void placeAutocomplete(String query) async {
    // Skip API call if location services disabled
    if (!isLocationServiceEnabled || !isPermissionGranted || isInitializing) {
      return;
    }
    
    if (query.isEmpty) {
      setState(() {
        placePredictions = [];
      });
      return;
    }

    Uri uri = Uri.https(
      "maps.googleapis.com",
      '/maps/api/place/autocomplete/json',
      {"input": query, "key": googleApiKey},
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

  Future<Map<String, String>> getDetailedAddressFromLatLng(
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
    try {
      // Show a loading indicator while getting location
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: bgColor,
                  ),
                ),
                SizedBox(width: 12),
                Text("Getting your current location..."),
              ],
            ),
            duration: Duration(seconds: 2),
            backgroundColor: primaryColor,
          ),
        );
      }

      // Await location retrieval with timeout
      await curretnloc.getCurrentLocation();
      
      // Check if we have valid coordinates
      if (curretnloc.currentPosition.latitude == 0 && 
          curretnloc.currentPosition.longitude == 0) {
        throw Exception("Invalid coordinates received");
      }

      // Add retry logic with multiple attempts for reverse geocoding
      Map<String, String> addressDetails = {};
      int maxAttempts = 3;
      
      for (int attempt = 0; attempt < maxAttempts; attempt++) {
        addressDetails = await getDetailedAddressFromLatLng(
          curretnloc.currentPosition.latitude,
          curretnloc.currentPosition.longitude,
        );
        
        // If we got a valid address, break the retry loop
        if (!addressDetails.containsKey("error")) {
          break;
        }
        
        // Short delay before retry
        if (attempt < maxAttempts - 1) {
          await Future.delayed(Duration(milliseconds: 500));
        }
      }

      // Update UI with the address
      if (mounted) {
        String formattedAddress = addressDetails["formattedAddress"] ?? "";
        
        // If we still don't have a valid address, construct one from components
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
        
        // Final fallback if we still have no address
        if (formattedAddress.isEmpty) {
          formattedAddress = "Location at ${curretnloc.currentPosition.latitude.toStringAsFixed(6)}, ${curretnloc.currentPosition.longitude.toStringAsFixed(6)}";
        }
        
        setState(() {
          widget.controller.text = formattedAddress;
        });
        
        // Trigger the location callback if provided
        widget.onLocationSelected?.call(curretnloc.currentPosition);
        FocusScope.of(context).unfocus();
      }
    } catch (e) {
      debugPrint("Error getting current location: $e");
      
      if (mounted) {
        // Clear any existing snackbars first
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Couldn't retrieve your location. Please try again."),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () {
                getCurrentLocationAndSet();
              },
            ),
          ),
        );
      }
    }
  }

  Future<LatLng?> getLatLngFromPlaceId(String? placeId) async {
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
}