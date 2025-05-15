import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stitchmate/core/constants/colors.dart';
import 'package:stitchmate/features/home/plane_transport/viewmodels/location_service.dart';
import 'package:stitchmate/features/home/plane_transport/viewmodels/route_provider.dart';
import 'package:stitchmate/features/home/plane_transport/views/booking_form.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';


class LuxuryPlaneTransportation extends StatefulWidget {
  const LuxuryPlaneTransportation({super.key});

  @override
  State<LuxuryPlaneTransportation> createState() =>
      LuxuryPlaneTransportationState();
}

class LuxuryPlaneTransportationState
    extends State<LuxuryPlaneTransportation> {
  BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor dropoffMarkerIcon = BitmapDescriptor.defaultMarker;
  LocationService _locationService = LocationService();
  bool isTapped = false;
  bool _isLoading = true;
  bool isLocationValid = false;
  LatLng? _dropoffLocation;

  @override
  void initState() {
    super.initState();
    _locationService = LocationService(
      onLocationUpdated: () {
        if (mounted) {
          setState(() {});
        }
      },
    );

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );

    // Preload everything before showing the map
    _preloadResources();
  }

Future<void> _preloadResources() async {
  try {
    // Load both markers in parallel
    final markersFuture = Future.wait([
      BitmapDescriptor.asset(
        ImageConfiguration(size: Size(50, 50)),
        "assets/icons/pickg.png",
      ),
      BitmapDescriptor.asset(
        ImageConfiguration(size: Size(40, 40)),
        "assets/icons/dropg.png",
      ),
    ]);

    // Initialize location service with error handling
    final locationFuture = _locationService.initialize();

    // Wait for markers to load
    final markers = await markersFuture;
    
    // Check if location service initialized successfully
    final locationInitialized = await locationFuture;

    if (mounted) {
      setState(() {
        markerIcon = markers[0];
        dropoffMarkerIcon = markers[1];
        _isLoading = false;
        isLocationValid = locationInitialized;
        _locationService.setCustomMarkerIcon(markerIcon);
      });
      
      // If location wasn't initialized successfully, we need to handle permissions
      if (!locationInitialized && mounted) {
        _checkAndRequestLocationPermission();
      }
    }
  } catch (e) {
    // Handle any exceptions during preloading
    debugPrint("Error preloading resources: $e");
    if (mounted) {
      setState(() {
        _isLoading = false;
        isLocationValid = false;
      });
      _checkAndRequestLocationPermission();
    }
  }
}
Future<void> _checkAndRequestLocationPermission() async {
  // Check if location is enabled
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Show dialog to enable location services
    if (mounted) {
      // Use a completer to handle the dialog dismissal
      Completer<void> dialogCompleter = Completer<void>();
      
      // Show the dialog and keep track of its context
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          // Start a listener for location changes while dialog is showing
          _monitorLocationServices(dialogContext, dialogCompleter);
          
          return AlertDialog(
            title: Text('Location Services Disabled'),
            content: Text('Please enable location services to use this feature.'),
            actions: <Widget>[
              TextButton(
                child: Text('CANCEL'),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  dialogCompleter.complete();
                },
              ),
              TextButton(
                child: Text('SETTINGS'),
                onPressed: () async {
                  await Geolocator.openLocationSettings();
                  // Don't pop the dialog - our monitor will do that automatically
                  // if location services get enabled
                },
              ),
            ],
          );
        },
      );
      
      // Wait for dialog to be dismissed (either by cancel or by monitor)
      await dialogCompleter.future;
      return;
    }
  }

  // Check permission status
  LocationPermission permission = await Geolocator.checkPermission();
  
  // If denied but not permanently, request it
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission != LocationPermission.denied && 
        permission != LocationPermission.deniedForever) {
      // Permission granted, initialize location
      bool success = await _locationService.initialize();
      if (mounted) {
        setState(() {
          isLocationValid = success;
        });
      }
    }
  }
  
  // If permanently denied, show dialog
  if (permission == LocationPermission.deniedForever && mounted) {
    // Use a completer to handle dialog dismissal
    Completer<void> dialogCompleter = Completer<void>();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        // Start a listener for permission changes while dialog is showing
        _monitorPermissionChanges(dialogContext, dialogCompleter);
        
        return AlertDialog(
          title: Text('Location Permission Required'),
          content: Text(
            'Location permission was denied. Please enable it in app settings to use all features.'
          ),
          actions: <Widget>[
            TextButton(
              child: Text('CANCEL'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                dialogCompleter.complete();
              },
            ),
            TextButton(
              child: Text('SETTINGS'),
              onPressed: () async {
                await Geolocator.openAppSettings();
                // Don't pop the dialog - our monitor will do that automatically
                // if permissions get granted
              },
            ),
          ],
        );
      },
    );
    
    // Wait for dialog to be dismissed (either by cancel or by monitor)
    await dialogCompleter.future;
  }
}

Timer? _locationMonitorTimer;
Timer? _permissionMonitorTimer;
/////////////////////////////////////////////////////////////////////////////////////////////////

void _monitorLocationServices(BuildContext dialogContext, Completer<void> completer) {
  // Cancel any existing timer
  _locationMonitorTimer?.cancel();
  
  // Set up a timer to check if location services are enabled while dialog is showing
  _locationMonitorTimer = Timer.periodic(Duration(seconds: 1), (timer) async {
    if (!mounted) {
      timer.cancel();
      _locationMonitorTimer = null;
      if (!completer.isCompleted) completer.complete();
      return;
    }
    
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        // Location services are now enabled, cancel timer
        timer.cancel();
        _locationMonitorTimer = null;
        
        // Dismiss the dialog if it's still showing
     if(context.mounted)
     {
         if (Navigator.canPop(dialogContext)) {
          Navigator.of(dialogContext).pop();
        }
     }
        
        if (!completer.isCompleted) completer.complete();
        
        // Re-check permissions and initialize location
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission != LocationPermission.denied && 
            permission != LocationPermission.deniedForever) {
          // Initialize location
          bool success = await _locationService.initialize();
          if (mounted) {
            setState(() {
              isLocationValid = success;
            });
          }
        } else {
          // Location services enabled, but still need permission
          _checkAndRequestLocationPermission();
        }
      }
    } catch (e) {
      debugPrint("Error monitoring location services: $e");
    }
  });
}

void _monitorPermissionChanges(BuildContext dialogContext, Completer<void> completer) {
  // Cancel any existing timer
  _permissionMonitorTimer?.cancel();
  
  // Set up a timer to check permissions while dialog is showing
  _permissionMonitorTimer = Timer.periodic(Duration(seconds: 1), (timer) async {
    if (!mounted) {
      timer.cancel();
      _permissionMonitorTimer = null;
      if (!completer.isCompleted) completer.complete();
      return;
    }
    
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission != LocationPermission.denied && 
          permission != LocationPermission.deniedForever) {
        // Permission granted, cancel timer
        timer.cancel();
        _permissionMonitorTimer = null;
        
        // Dismiss the dialog if it's still showing
      if(context.mounted)
      {
          if (Navigator.canPop(dialogContext)) {
          Navigator.of(dialogContext).pop();
        }
        
      }
        if (!completer.isCompleted) completer.complete();
        
        // Initialize location
        bool success = await _locationService.initialize();
        if (mounted) {
          setState(() {
            isLocationValid = success;
          });
        }
      }
    } catch (e) {
      debugPrint("Error monitoring permission changes: $e");
    }
  });
}
  //////////////////////////////////////////////////////////////////////////////////////////
  void onSuggestionSelected(LatLng newLocation) {
    final routeProvider = Provider.of<PlaneRouteProvider>(context, listen: false);
    setState(() {
      isLocationValid = true;
      // Update map to the selected location
      _locationService.updateSelectedLocation(newLocation);
      routeProvider.setPickupLocation(newLocation);
      // If dropoff location was previously selected, update the route
      if (_dropoffLocation != null) {
        _locationService.getRoutePolyline(newLocation, _dropoffLocation!);
      }
    });
  }

  /////////////////////////////////////////////////////////////////////////////////////
  void onDropoffLocationSelected(LatLng newLocation) {
    final routeProvider = Provider.of<PlaneRouteProvider>(context, listen: false);
    setState(() {
      // Store dropoff location
      _dropoffLocation = newLocation;
      routeProvider.setDropoffLocation(newLocation);
      // Add a second marker for drop-off location
      _locationService.addDropoffMarker(newLocation, dropoffMarkerIcon);
    });

    // Get route polyline between current pickup and this dropoff
    _locationService.getRoutePolyline(
      _locationService.currentPosition,
      newLocation,
    );
  }

  ///////////////////////////////////////////////////////////////////////////////////////////
  void onPickupLocationSelected(LatLng newLocation) {
    _locationService.updateSelectedLocation(newLocation);
  }

  ///////////////////////////////////////////////////////////////////////////////////////////
  void expandSheet() {
    setState(() {
      isTapped = true;
    });
  }

  ///////////////////////////////////////////////////////////////////////////////////////////
  @override
  void dispose() {
 _locationMonitorTimer?.cancel();
  _permissionMonitorTimer?.cancel();
    _locationService.dispose();
    super.dispose();
  }

  // Create shimmer for map area
  Widget _buildMapShimmerEffect() {
    final size = MediaQuery.sizeOf(context);
    return Shimmer.fromColors(
      baseColor: nextbg,
      highlightColor: bgColor,
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
            Container(
              height: size.height * 0.6,
              margin: EdgeInsets.only(bottom: 8, top: 32),
              color: bgColor,
            ),
          ],
        ),
      ),
    );
  }

  // Create shimmer for the bottom sheet
  Widget _buildBottomSheetShimmer() {
    return Shimmer.fromColors(
      baseColor: sheetshimmer,
      highlightColor: white,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: const BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
      ),
    );
  }

 @override
Widget build(BuildContext context) {
  // Single unified loading state for entire screen
  final size = MediaQuery.sizeOf(context);
  if (_isLoading) {
    return Scaffold(
      body: Stack(
        children: [
          // Map shimmer
          Positioned.fill(child: _buildMapShimmerEffect()),

          // Bottom sheet shimmer
          DraggableScrollableSheet(
            initialChildSize: 0.45,
            minChildSize: 0.4,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return _buildBottomSheetShimmer();
            },
          ),
        ],
      ),
    );
  }

  // Show default UI with default map position when location permission is denied
  return Scaffold(
    body: Stack(
      children: [
        // Map area - with or without current location
        Positioned.fill(
          bottom: size.height * 0.1,
          child: Stack(
            children: [
              GoogleMap(
                markers: Set<Marker>.from(_locationService.markers),
                polylines: _locationService.polylines,
                initialCameraPosition: CameraPosition(
                  target: isLocationValid 
                      ? _locationService.currentPosition 
                      : LatLng(37.7749, -122.4194), // Default fallback coordinates (San Francisco)
                  zoom: 15,
                ),
                onMapCreated: (controller) {
                  if (mounted) {
                    _locationService.onMapCreated(controller);
                  }
                },
                style:
                    _locationService.mapStyle.isEmpty
                        ? null
                        : _locationService.mapStyle,
              ),
              
              // Show a location permission banner at the top if needed
              if (!isLocationValid)
                Positioned(
                  top: 40,
                  left: 0,
                  right: 0,
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.location_off, color: Colors.orange),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Location access is required for full functionality.',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            await Geolocator.openAppSettings();
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: primaryColor,
                            padding: EdgeInsets.symmetric(horizontal: 8),
                          ),
                          child: Text('ENABLE'),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Regular bottom sheet
        DraggableScrollableSheet(
          initialChildSize: isTapped ? 0.9 : 0.45,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: BookingForm(
                scrollController: scrollController,
                onFormFieldTap: () {
                  setState(() {
                    isTapped = true;
                  });
                },
                onPickupLocationSelected: onSuggestionSelected,
                onDropoffLocationSelected: onDropoffLocationSelected,
              ),
            );
          },
        ),
      ],
    ),
  );
}
}