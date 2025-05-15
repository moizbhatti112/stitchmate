import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stitchmate/core/constants/colors.dart';
import 'package:stitchmate/core/widgets/mybutton.dart';
import 'package:stitchmate/features/home/plane_transport/viewmodels/booking_provider.dart';
import 'package:stitchmate/features/home/plane_transport/viewmodels/location_service.dart';
import 'package:stitchmate/features/home/plane_transport/viewmodels/route_provider.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
// import 'package:stitchmate/features/payment/services/stripe_service.dart';
import 'package:stitchmate/features/home/plane_transport/payment/views/payment_selection.dart';

class PlaneBookingConfirmation extends StatefulWidget {
  const PlaneBookingConfirmation({super.key});

  @override
  State<PlaneBookingConfirmation> createState() => _PlaneBookingConfirmationState();
}

class _PlaneBookingConfirmationState extends State<PlaneBookingConfirmation> {
  // final TextEditingController _notescontroller = TextEditingController();
  BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor dropoffMarkerIcon = BitmapDescriptor.defaultMarker;
  late LocationService _locationService;
  bool _isMapLoading = true;
  GoogleMapController? _mapController;
  bool _markersLoaded = false;
  
  @override
  void initState() {
    super.initState();

    // Initialize with useCurrentLocation = false to avoid using device location
    _locationService = LocationService(
      onLocationUpdated: () {
        if (mounted) {
          setState(() {});
        }
      },
      useCurrentLocation: false, // Disable current location tracking
    );

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );

    // Preload both markers before showing map
    _preloadResources();
  }

  Future<void> _preloadResources() async {
    // Load both markers in parallel
    final markersFuture = Future.wait([
      BitmapDescriptor.asset(
        ImageConfiguration(size: Size(40, 40)),
        "assets/icons/pickg.png",
      ),
      BitmapDescriptor.asset(
        ImageConfiguration(size: Size(40, 40)),
        "assets/icons/dropg.png",
      ),
    ]);

    // Initialize location service without requesting current location
    final locationFuture = _locationService.initialize(useCurrentLocation: false);

    // Wait for both operations to complete
    await Future.wait([markersFuture, locationFuture]);

    // Set markers once loaded
    if (mounted) {
      final markers = await markersFuture;
      setState(() {
        markerIcon = markers[0];
        dropoffMarkerIcon = markers[1];
        _markersLoaded = true;
        _isMapLoading = false;
      });

      // Update map with markers after a small delay to ensure map is ready
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _setupRouteAndMarkers();
      });
    }
  }

  // Function to update map view to include both markers
  void _updateMapView() {
    final routeProvider = Provider.of<PlaneRouteProvider>(context, listen: false);
    final pickup = routeProvider.pickupLocation;
    final dropoff = routeProvider.dropoffLocation;
    
    if (_mapController != null && pickup != null && dropoff != null) {
      // Create bounds that include both pickup and dropoff
      LatLngBounds bounds = _createBounds(pickup, dropoff);
      
      // Animate camera to show both markers with padding
      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 80),
      );
    }
  }

  // Setup route between pickup and dropoff locations
  void _setupRouteAndMarkers() {
    final routeProvider = Provider.of<PlaneRouteProvider>(context, listen: false);
    final pickup = routeProvider.pickupLocation;
    final dropoff = routeProvider.dropoffLocation;
    
    if (pickup != null && dropoff != null) {
      // Update the current position in location service to be the pickup point
      _locationService.updateSelectedLocation(pickup);
      
      // Add dropoff marker with custom icon
      if (_markersLoaded) {
        // Clear previous markers before adding new ones
        _locationService.markers.clear();
        
        // Add pickup marker
        _locationService.markers.add(
          Marker(
            markerId: const MarkerId("pickup_location"),
            position: pickup,
            icon: markerIcon,
            infoWindow: const InfoWindow(title: "Pickup Location"),
          ),
        );
        
        // Add dropoff marker
        _locationService.markers.add(
          Marker(
            markerId: const MarkerId("dropoff_location"),
            position: dropoff,
            icon: dropoffMarkerIcon,
            infoWindow: const InfoWindow(title: "Drop-off Location"),
          ),
        );
        
        // Clear previous polylines and generate a new one
        _locationService.polylines.clear();
        _locationService.getRoutePolyline(pickup, dropoff);
        
        // Update map view to show both markers
        _updateMapView();
      }
    }
  }

  // Helper function to create bounds from two points
  LatLngBounds _createBounds(LatLng point1, LatLng point2) {
    double minLat = point1.latitude < point2.latitude ? point1.latitude : point2.latitude;
    double maxLat = point1.latitude > point2.latitude ? point1.latitude : point2.latitude;
    double minLng = point1.longitude < point2.longitude ? point1.longitude : point2.longitude;
    double maxLng = point1.longitude > point2.longitude ? point1.longitude : point2.longitude;
    
    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<PlaneBookingProvider>(context);
    final routeProvider = Provider.of<PlaneRouteProvider>(context);
    final LatLng? pickup = routeProvider.pickupLocation;
    final LatLng? dropoff = routeProvider.dropoffLocation;
    final size = MediaQuery.sizeOf(context);
    
    String routeEstimationText = "Calculating route...";
    if (_locationService.estimatedDistance.isNotEmpty && 
        _locationService.estimatedDuration.isNotEmpty) {
      routeEstimationText = "Estimated route: ${_locationService.estimatedDuration} | ${_locationService.estimatedDistance}";
    }
    
    return Scaffold(
      body: Stack(
        children: [
          // Only show map when markers are ready, otherwise show loading state
          Positioned.fill(
            child: _isMapLoading ? 
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(color: Colors.white),
              ) : 
              GoogleMap(
                myLocationEnabled: false, // Disable the current location button
                myLocationButtonEnabled: false, // Disable the current location button
                markers: Set<Marker>.from(_locationService.markers),
                polylines: _locationService.polylines,
                initialCameraPosition: CameraPosition(
                  // Using center point between pickup and dropoff if available
                  target: (pickup != null && dropoff != null) 
                      ? LatLng(
                          (pickup.latitude + dropoff.latitude) / 2,
                          (pickup.longitude + dropoff.longitude) / 2)
                      : pickup ?? LatLng(37.7749, -122.4194),
                  zoom: 12, // Zoom out a bit to potentially show both locations
                ),
                onMapCreated: (GoogleMapController controller) {
                  _mapController = controller;
                  _locationService.onMapCreated(controller);
                  
                  // Wait a moment for the map to initialize properly before updating view
                  Future.delayed(Duration(milliseconds: 300), () {
                    _setupRouteAndMarkers();
                  });
                },
                style: _locationService.mapStyle.isEmpty
                    ? null
                    : _locationService.mapStyle,
              ),
          ),
          // The rest of your UI remains unchanged
          DraggableScrollableSheet(
            initialChildSize: 0.8,
            minChildSize: 0.4,
            maxChildSize: 1.0,
            builder: (context, scrollController) {
              return Container(
                padding: const EdgeInsets.all(16.0),
                decoration: const BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Booking Confirmation',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: "PP Neue Montreal",
                        ),
                      ),
                      SizedBox(height: size.height * 0.015),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: circlemenusbg,
                              border: Border.all(color: nextbg),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              " ${bookingProvider.date}",
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: "HelveticaNeueMedium",
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          SizedBox(width: size.width * 0.02),
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: circlemenusbg,
                              border: Border.all(color: nextbg),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              " ${bookingProvider.time}",
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: "HelveticaNeueMedium",
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: size.height * 0.015),
                      Text(
                        routeEstimationText,
                        style: TextStyle(
                          fontSize: 13,
                          fontFamily: "HelveticaNeueMedium",
                          fontWeight: FontWeight.w500,
                          color: grey,
                        ),
                      ),
                      SizedBox(height: size.height * 0.015),
                      Container(
                        height: size.height * 0.12,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: phonefieldColor,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/point_a.svg',
                                    height:
                                        size.height *
                                        0.025, // Responsive height
                                    width: size.width * 0.05,
                                  ),
                                  SizedBox(width: size.width * 0.05),
                                  Expanded(
                                    child: Text(
                                      bookingProvider.pickupLocation,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontFamily: "HelveticaNeueMedium",
                                        fontWeight: FontWeight.w400,
                                      ),
                                      maxLines: 1,
                                      overflow:
                                          TextOverflow
                                              .ellipsis, // Show "..." if overflow
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Container(
                                  width: size.width * 0.006,
                                  height: size.height * 0.04,
                                  color: Colors.black, // Vertical Line
                                ),
                              ),
                              Row(
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/pointb.svg',
                                    height:
                                        size.height *
                                        0.025, // Responsive height
                                    width: size.width * 0.05,
                                  ),
                                  SizedBox(width: size.width * 0.05),
                                  Expanded(
                                    child: Text(
                                      bookingProvider.dropoffLocation,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontFamily: "HelveticaNeueMedium",
                                        fontWeight: FontWeight.w400,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: size.height * 0.03),
             
                      SizedBox(height: size.height * 0.02),
                      Divider(),
                      SizedBox(height: size.height * 0.02),
                      Row(
                        children: [
                          Container(
                            width: size.width * 0.12,
                            height: size.height * 0.05,
                            decoration: BoxDecoration(
                              color: circlemenusbg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: circlemenusborder),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SvgPicture.asset(
                                'assets/icons/wallet.svg',
                              ),
                            ),
                          ),
                          SizedBox(width: size.width * 0.04),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Price ${_locationService.calculatedPrice > 0 ? _locationService.calculatedPrice : '---'} Rs.",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: "HelveticaNeueMedium",
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                "Credit or Debit Card",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: "HelveticaNeueMedium",
                                  fontWeight: FontWeight.w400,
                                  color: grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: size.height * 0.02),
               
                      SizedBox(height: size.height * 0.02),
                      Divider(),

                      SizedBox(height: size.height * 0.02),
                      MyButton(text: "Confirm Order", onPressed: () {
                      
                            final int rate = _locationService.calculatedPrice;
                       
                         Navigator.push(context, MaterialPageRoute(builder: 
                          (context) =>  PaymentSelectionScreen(price: rate,)));
                    
                      }),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}