import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stitchmate/core/constants/colors.dart';
import 'package:stitchmate/features/home/ground_transport/api_service/autocomplete_prediction.dart';
import 'package:stitchmate/features/home/ground_transport/api_service/location_api_service.dart';
import 'package:stitchmate/features/home/ground_transport/viewmodels/location_service.dart';
 // Import the new service

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

class _LocationInputState extends State<LocationInput> with WidgetsBindingObserver {
  // STATE VARIABLES
  LocationService curretnloc = LocationService();
  List<AutocompletePrediction> placePredictions = [];
  FocusNode focusNode = FocusNode();
  bool isSuggestionSelected = false;
  bool isLocationServiceEnabled = false;
  bool isPermissionGranted = false;
  bool isCheckingPermission = false;
  bool isInitializing = true;
  Timer? _debounce;
  String _lastQuery = "";
  late final Stream<ServiceStatus> _serviceStatusStream;

  //---------------------------------------------
  // LIFECYCLE METHODS
  //---------------------------------------------
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkLocationStatusOnInit();
    _serviceStatusStream = Geolocator.getServiceStatusStream();
    _listenToLocationServiceChanges();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshLocationStatus();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    focusNode.dispose();
    super.dispose();
  }

  //---------------------------------------------
  // LOCATION SERVICE MANAGEMENT
  //---------------------------------------------
  
  void _listenToLocationServiceChanges() {
    _serviceStatusStream.listen((ServiceStatus status) {
      debugPrint("Location service status changed: $status");
      _refreshLocationStatus();
    });
  }

  Future<void> _refreshLocationStatus() async {
    debugPrint("Refreshing location status");
    
    if (mounted) {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      LocationPermission permission = await Geolocator.checkPermission();
      
      debugPrint("Location service: ${serviceEnabled ? 'enabled' : 'disabled'}, Permission: $permission");
      
      if (serviceEnabled != isLocationServiceEnabled || 
          isPermissionGranted != (permission == LocationPermission.whileInUse || 
                                 permission == LocationPermission.always)) {
        setState(() {
          isLocationServiceEnabled = serviceEnabled;
          isPermissionGranted = permission == LocationPermission.whileInUse || 
                               permission == LocationPermission.always;
          
          if (!serviceEnabled || !isPermissionGranted) {
            placePredictions = [];
          }
        });
        
        if (!serviceEnabled || !isPermissionGranted) {
          if (widget.controller.text.contains("Current Location")) {
            widget.controller.clear();
            isSuggestionSelected = false;
          }
        }
      }
    }
  }

  Future<void> _checkLocationStatusOnInit() async {
    await _refreshLocationStatus();
    if (mounted) {
      setState(() {
        isInitializing = false;
      });
    }
  }

  Future<bool> _checkLocationPermission({bool showDialogOnDisabled = false}) async {
    if (isCheckingPermission) return false;
    
    setState(() {
      isCheckingPermission = true;
    });
    
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      
      if (serviceEnabled != isLocationServiceEnabled) {
        setState(() {
          isLocationServiceEnabled = serviceEnabled;
          
          if (!serviceEnabled) {
            placePredictions = [];
          }
        });
      }
      
      if (!serviceEnabled) {
        if (showDialogOnDisabled && mounted) {
          await _showLocationServiceDialog();
          await _refreshLocationStatus();
        }
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      bool newPermissionState = permission == LocationPermission.whileInUse || 
                              permission == LocationPermission.always;
                              
      if (newPermissionState != isPermissionGranted) {
        setState(() {
          isPermissionGranted = newPermissionState;
          
          if (!newPermissionState) {
            placePredictions = [];
          }
        });
      }

      if (permission == LocationPermission.deniedForever) {
        if (showDialogOnDisabled && mounted) {
          await _showPermissionDeniedDialog();
          await _refreshLocationStatus();
        }
        return false;
      }

      return permission == LocationPermission.whileInUse || 
            permission == LocationPermission.always;
    } finally {
      if (mounted) {
        setState(() {
          isCheckingPermission = false;
        });
      }
    }
  }

  //---------------------------------------------
  // DIALOG UI COMPONENTS
  //---------------------------------------------
  
  Future<void> _showLocationServiceDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
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
      await Future.delayed(Duration(seconds: 2));
      await _refreshLocationStatus();
    }
  }

  Future<void> _showPermissionDeniedDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
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
      await Future.delayed(Duration(seconds: 2));
      await _refreshLocationStatus();
    }
  }

  //---------------------------------------------
  // PLACES API FUNCTIONS
  //---------------------------------------------
  
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
      await _refreshLocationStatus();
      
      if (!isLocationServiceEnabled || !isPermissionGranted || isInitializing) {
        setState(() {
          placePredictions = [];
        });
        return;
      }
      
      // Using the new API service
      List<AutocompletePrediction> predictions = await LocationApiService.getPlacePredictions(query);
      
      await _refreshLocationStatus();
      if (!isLocationServiceEnabled || !isPermissionGranted || !mounted) {
        setState(() {
          placePredictions = [];
        });
        return;
      }

      setState(() {
        placePredictions = predictions;
      });
    });
  }

  //---------------------------------------------
  // LOCATION OPERATIONS
  //---------------------------------------------
  
  Future<void> getCurrentLocationAndSet() async {
    try {
      await _refreshLocationStatus();
      if (!isLocationServiceEnabled || !isPermissionGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Location services have been disabled. Please enable them to get current location."),
              action: SnackBarAction(
                label: 'Settings',
                onPressed: () async {
                  await Geolocator.openLocationSettings();
                },
              ),
            ),
          );
        }
        return;
      }
      
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

      await curretnloc.getCurrentLocation();
      
      await _refreshLocationStatus();
      if (!isLocationServiceEnabled || !isPermissionGranted || !mounted) {
        return;
      }
      
      if (curretnloc.currentPosition.latitude == 0 && 
          curretnloc.currentPosition.longitude == 0) {
        throw Exception("Invalid coordinates received");
      }

      Map<String, String> addressDetails = {};
      int maxAttempts = 3;
      
      for (int attempt = 0; attempt < maxAttempts; attempt++) {
        await _refreshLocationStatus();
        if (!isLocationServiceEnabled || !isPermissionGranted || !mounted) {
          return;
        }
        
        // Using the new API service
        addressDetails = await LocationApiService.getDetailedAddressFromLatLng(
          curretnloc.currentPosition.latitude,
          curretnloc.currentPosition.longitude,
        );
        
        if (!addressDetails.containsKey("error")) {
          break;
        }
        
        if (attempt < maxAttempts - 1) {
          await Future.delayed(Duration(milliseconds: 500));
        }
      }

      if (mounted) {
        // Using the new API service to format the address
        String formattedAddress = LocationApiService.formatAddress(addressDetails);
        
        if (formattedAddress.isEmpty) {
          formattedAddress = "Location at ${curretnloc.currentPosition.latitude.toStringAsFixed(6)}, ${curretnloc.currentPosition.longitude.toStringAsFixed(6)}";
        }
        
        setState(() {
          widget.controller.text = formattedAddress;
        });
        
        widget.onLocationSelected?.call(curretnloc.currentPosition);
        FocusScope.of(context).unfocus();
      }
    } catch (e) {
      debugPrint("Error getting current location: $e");
      
      await _refreshLocationStatus();
      
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        
        if (!isLocationServiceEnabled || !isPermissionGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Location services are currently disabled."),
              action: SnackBarAction(
                label: 'Enable',
                onPressed: () async {
                  await Geolocator.openLocationSettings();
                },
              ),
            ),
          );
          return;
        }
        
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

  //---------------------------------------------
  // UI COMPONENTS
  //---------------------------------------------
  
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    
    final showLocationWarning = !isInitializing && 
                              (!isLocationServiceEnabled || !isPermissionGranted);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLocationTextField(context),
        const SizedBox(height: 10),
        if (!widget.isDropoff)
          _buildCurrentLocationButton(context, size),
        Divider(),
        _buildLocationSuggestions(size),
        if (showLocationWarning)
          _buildLocationWarningMessage(),
      ],
    );
  }

  Widget _buildLocationTextField(BuildContext context) {
    return TextFormField(
      focusNode: focusNode,
      onTap: () async {
        if (!isLocationServiceEnabled || !isPermissionGranted) {
          await _checkLocationPermission(showDialogOnDisabled: true);
          
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
        
        widget.onTap();
      },
      controller: widget.controller,
      enabled: !isCheckingPermission && !isInitializing,
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: const EdgeInsets.all(10.0),
          child: SvgPicture.asset(widget.iconPath, width: 20, height: 20),
        ),
        hintText: widget.hintText,
        hintStyle: TextStyle(color: phonefieldtext),
        filled: true,
        fillColor: isInitializing 
            ? Colors.grey.shade100
            : (isLocationServiceEnabled && isPermissionGranted 
                ? phonefieldColor 
                : Colors.grey.shade200),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: (value) {
        if (!isLocationServiceEnabled || !isPermissionGranted || isInitializing) {
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
    );
  }

  Widget _buildCurrentLocationButton(BuildContext context, Size size) {
    return GestureDetector(
      onTap: () async {
        if (isInitializing) return;
        
        await _refreshLocationStatus();
        
        if (!isLocationServiceEnabled || !isPermissionGranted) {
          await _checkLocationPermission(showDialogOnDisabled: true);
          
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
            ? 0.5
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
    );
  }

  Widget _buildLocationSuggestions(Size size) {
    if (placePredictions.isEmpty || isInitializing || 
        !isLocationServiceEnabled || !isPermissionGranted) {
      return SizedBox.shrink();
    }
    
    return SizedBox(
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
                  await _refreshLocationStatus();
                  if (!isLocationServiceEnabled || !isPermissionGranted) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Location services have been disabled. Please enable them to continue."),
                          action: SnackBarAction(
                            label: 'Settings',
                            onPressed: () async {
                              await Geolocator.openLocationSettings();
                            },
                          ),
                        ),
                      );
                    }
                    return;
                  }
                  
                  // Using the new API service
                  LatLng? selectedLatLng = await LocationApiService.getLatLngFromPlaceId(
                    placePredictions[index].placeId,
                  );

                  setState(() {
                    widget.controller.text =
                        placePredictions[index].description;
                    placePredictions = [];
                    isSuggestionSelected = true;
                  });

                  widget.onLocationSelected?.call(selectedLatLng!);
                  if(context.mounted) {
                    FocusScope.of(context).unfocus();
                  }
                                },
              ),
              if (index < placePredictions.length - 1)
                Divider(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLocationWarningMessage() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: red),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              "Location services must be enabled to use the map and select locations.",
              style: TextStyle(color: red, fontSize: 14),
            ),
          ),
          TextButton(
            onPressed: isCheckingPermission ? null : () async {
              await _checkLocationPermission(showDialogOnDisabled: true);
            },
            child: Text("Enable"),
          ),
        ],
      ),
    );
  }
}