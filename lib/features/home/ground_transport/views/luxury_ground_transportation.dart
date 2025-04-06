import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gyde/core/constants/colors.dart';
import 'package:gyde/features/home/ground_transport/viewmodels/location_service.dart';
import 'package:gyde/features/home/ground_transport/viewmodels/route_provider.dart';
import 'package:gyde/features/home/ground_transport/views/booking_form.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class LuxuryGroundTransportation extends StatefulWidget {
  const LuxuryGroundTransportation({super.key});

  @override
  State<LuxuryGroundTransportation> createState() =>
      LuxuryGroundTransportationState();
}

class LuxuryGroundTransportationState
    extends State<LuxuryGroundTransportation> {
  BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor dropoffMarkerIcon = BitmapDescriptor.defaultMarker;
  LocationService _locationService = LocationService();
  bool isTapped = false;
  bool _isLoading = true;
  bool isLocationValid = false;
  LatLng? _dropoffLocation; // Track if user selected suggestion
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
    addCustomIcon();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _locationService.initialize();

      BitmapDescriptor.asset(
        ImageConfiguration(size: Size(40, 40)),
        "assets/icons/dropg.png",
      ).then((icon) {
        if (mounted) {
          setState(() {
            dropoffMarkerIcon = icon;
          });
        }
      });

      await Future.delayed(const Duration(milliseconds: 500)); // safer delay
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  //////////////////////////////////////////////////////////////////////////////////////////
  void onSuggestionSelected(LatLng newLocation) {
    final routeProvider = Provider.of<RouteProvider>(context, listen: false);
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
    final routeProvider = Provider.of<RouteProvider>(context, listen: false);
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
  void addCustomIcon() {
    BitmapDescriptor.asset(
      ImageConfiguration(size: Size(50, 50)),
      "assets/icons/pickg.png",
    ).then((icon) {
      setState(() {
        markerIcon = icon;
        _locationService.setCustomMarkerIcon(markerIcon);
      });
    });
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
    // Regular UI when everything is loaded
    return Scaffold(
      body: Stack(
        children: [
          // Map
          Positioned.fill(
            bottom: size.height * 0.1,
            child: Visibility(
              visible: !_isLoading,
              child: GoogleMap(
                markers: Set<Marker>.from(_locationService.markers),
                polylines: _locationService.polylines,
                initialCameraPosition: CameraPosition(
                  target: _locationService.currentPosition,
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
