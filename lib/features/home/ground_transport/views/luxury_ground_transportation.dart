import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gyde/core/constants/colors.dart';
import 'package:gyde/features/home/ground_transport/viewmodels/location_service.dart';
import 'package:gyde/features/home/ground_transport/views/booking_form.dart';
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
  final LocationService _locationService = LocationService();
  bool isTapped = false;
  bool _isLoading = true; 
  bool isLocationValid = false; // Track if user selected suggestion

 void onSuggestionSelected(LatLng newLocation) {
    setState(() {
      isLocationValid = true;
      // Update map to the selected location
      _locationService.updateSelectedLocation(newLocation);
    });
  }
   void onDropoffLocationSelected(LatLng newLocation) {
    setState(() {
      // Add a second marker for drop-off location
      _locationService.addDropoffMarker(newLocation, dropoffMarkerIcon);
    });
  }
  @override
  void initState() {
    super.initState();

    addCustomIcon();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );

    // Initialize location service and map loading together
    Future.delayed(Duration.zero, () async {
         
      await _locationService.initialize();

    BitmapDescriptor.asset(
        ImageConfiguration(size: Size(40, 40)),
        "assets/icons/dropg.png", // You'll need to add this icon
      ).then((icon) {
        setState(() {
          dropoffMarkerIcon = icon;
        });
      });
      // Add a consistent delay after initialization to ensure map has time to load
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() {
            _isLoading = false; // Both map and sheet will stop shimmer together
          });
        }
      });
    });
  }

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
void onPickupLocationSelected(LatLng newLocation) {
  _locationService.updateSelectedLocation(newLocation);
}
  void expandSheet() {
    setState(() {
      isTapped = true;
    });
  }

  @override
  void dispose() {
    _locationService.dispose();
    super.dispose();
  }

  // Create shimmer for map area
  Widget _buildMapShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
            Container(
              height: 150,
              margin: EdgeInsets.only(bottom: 8, top: 32),
              color: Colors.white,
            ),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 100,
                    margin: EdgeInsets.only(right: 8),
                    color: Colors.white,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(height: 100, color: Colors.white),
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              height: 80,
              margin: EdgeInsets.only(bottom: 8),
              color: Colors.white,
            ),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                children: List.generate(
                  4,
                  (index) => Container(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Create shimmer for the bottom sheet
  Widget _buildBottomSheetShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: const BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle indicator
            Center(
              child: Container(
                width: 40,
                height: 5,
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: grey,
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
            ),

            // Form field shimmer
            Container(
              height: 50,
              margin: EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: grey,
                borderRadius: BorderRadius.circular(8),
              ),
            ),

            Container(
              height: 50,
              margin: EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: grey,
                borderRadius: BorderRadius.circular(8),
              ),
            ),

            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 50,
                    margin: EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: grey,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: grey,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 24),

            Container(
              height: 50,
              decoration: BoxDecoration(
                color: grey,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
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
            child: GoogleMap(
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              markers: Set<Marker>.from(_locationService.markers),
              initialCameraPosition: CameraPosition(
                target: _locationService.currentPosition,
                zoom: 15,
              ),
              onMapCreated: _locationService.onMapCreated,
              style:
                  _locationService.mapStyle.isEmpty
                      ? null
                      : _locationService.mapStyle,
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
