import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stitchmate/core/constants/api_key.dart';
import 'package:stitchmate/core/constants/colors.dart';
import 'package:stitchmate/features/home/ground_transport/api_service/autocomplete_prediction.dart';
import 'package:stitchmate/features/home/ground_transport/api_service/autocomplete_response.dart';
import 'package:stitchmate/features/home/ground_transport/api_service/network_repo.dart';
import 'package:stitchmate/features/home/ground_transport/viewmodels/booking_provider.dart';
import 'package:stitchmate/features/home/ground_transport/views/custom_datepicker.dart';
import 'package:stitchmate/features/home/ground_transport/views/time_picker.dart';
import 'package:provider/provider.dart';

class LuxuryGroundTransportation extends StatefulWidget {
  const LuxuryGroundTransportation({super.key});

  @override
  State<LuxuryGroundTransportation> createState() =>
      _LuxuryGroundTransportationState();
}

class _LuxuryGroundTransportationState extends State<LuxuryGroundTransportation>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _formKeyhour = GlobalKey<FormState>();
  late TabController _tabController;
  final TextEditingController _pickupLocationController =
      TextEditingController();
  final TextEditingController _dropoffLocationController =
      TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  // Default position (will be updated with user's location)
  final position = Geolocator.getCurrentPosition();
  final LatLng _initialPosition = LatLng(33.7463, 72.8397);
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  bool _isLoading = true;
  bool _mapInitialized = false;
  String _mapStyle = "";
  bool isTapped = false;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );
    _loadMapStyle();
    _getCurrentLocation();
    _zoomToCurrentLocation();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pickupLocationController.dispose();
    _dropoffLocationController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _durationController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  // Load Custom Map Style
  Future<void> _loadMapStyle() async {
    String style = await rootBundle.loadString('assets/map_style.json');
    setState(() {
      _mapStyle = style;
    });
  }

  // Combined function to get location permission, current position and zoom to it
  Future<void> _getCurrentLocation() async {
    try {
      // Check location services
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _isLoading = false);
        await Geolocator.requestPermission();
        return;
      }

      // Check and request permission
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _isLoading = false);
          _showErrorSnackBar('Location permission denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() => _isLoading = false);
        _showErrorSnackBar('Location permissions permanently denied');
        return;
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Error getting location: ${e.toString()}');
    }
  }

  //Zoom to current location
  void _zoomToCurrentLocation() async {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );
    // Get position
    final position = await Geolocator.getCurrentPosition(
      locationSettings: locationSettings,
    );
    if (!_mapInitialized) return;

    try {
      _mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 15,
            tilt: 0, // Ensure flat view
            bearing: 0, // North facing
          ),
        ),
      );

      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId("current_location"),
          position: LatLng(position.latitude, position.longitude),
          infoWindow: const InfoWindow(title: "Your Location"),
        ),
      );

      if (mounted) setState(() {});
    } catch (e) {
      debugPrint("Error zooming to location: $e");
    }
  }

  //Error Snackbar
  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  //Places Autocomplete
  List<AutocompletePrediction> placePredictions = [];
  List<AutocompletePrediction> dropoffPlacePredictions = [];
  void placeAutocomplete(String query, {bool isDropoff = false}) async {
  if (query.isEmpty) {
    setState(() {
      if (isDropoff) {
        dropoffPlacePredictions = [];
      } else {
        placePredictions = [];
      }
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

  try {
    PlaceAutoCompleteResponse result =
        PlaceAutoCompleteResponse.parseAutoCompleteResult(response!);

    setState(() {
      if (isDropoff) {
        dropoffPlacePredictions = result.predictions;
      } else {
        placePredictions = result.predictions;
      }
    });
  } catch (e) {
    debugPrint("Error parsing autocomplete response: $e");
    setState(() {
      if (isDropoff) {
        dropoffPlacePredictions = [];
      } else {
        placePredictions = [];
      }
    });
  }
}

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Stack(
        children: [
          // Map takes the full screen
          Positioned.fill(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : GoogleMap(
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      markers: _markers,
                      initialCameraPosition: CameraPosition(
                        target: _initialPosition,
                        zoom: 15,
                      ),
                      onMapCreated: (GoogleMapController controller) {
                        setState(() {
                          _mapController = controller;
                          _mapInitialized = true;
                        });

                        // Apply custom map style if needed
                        // controller.setMapStyle(mapStyle);

                        // Now zoom to location with a slight delay to ensure map is ready
                        Future.delayed(Duration(milliseconds: 300), () {
                          _zoomToCurrentLocation();
                        });
                      },
                      style: _mapStyle.isEmpty ? null : _mapStyle,
                    ),
          ),
          // Bottom sheet for ride booking
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
      child: Stack(
        children: [
          SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Book a ride',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: "PP Neue Montreal",
                  ),
                ),
                const SizedBox(height: 16),
                _buildTabSelector(),
                const SizedBox(height: 20),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.9,
                  child: TabBarView(
                    controller: _tabController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildOneWayRideForm(),
                      _buildByTheHourRideForm(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  },
),
        ],
      ),
    );
  }

  Widget _buildTabSelector() {
    return TabBar(
      controller: _tabController,
      indicatorColor: primaryColor,
      labelColor: primaryColor,
      unselectedLabelColor: lightgrey,
      indicator: const UnderlineTabIndicator(
        borderSide: BorderSide(width: 2.3, color: primaryColor),
        insets: EdgeInsets.symmetric(horizontal: 135),
      ),
      tabs: const [
        Tab(
          child: Text(
            'One Way',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontFamily: "HelveticaNeueMedium",
            ),
          ),
        ),
        Tab(
          child: Text(
            'By the hour',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontFamily: "HelveticaNeueMedium",
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOneWayRideForm() {
    final size = MediaQuery.of(context).size;
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pickup',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                fontFamily: "HelveticaNeueMedium",
                color: black,
              ),
            ),
            SizedBox(height: size.height * 0.015),
            _buildLocationInput(
              _pickupLocationController,
              'Pickup location',
              'assets/icons/pickup.svg',
            ),
            SizedBox(height: size.height * 0.015),
            Text(
              'Drop-off',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                fontFamily: "HelveticaNeueMedium",
                color: black,
              ),
            ),
            SizedBox(height: size.height * 0.015),
            _builddropoffLocationInput(
              _dropoffLocationController,
              'Drop-off location',
              'assets/icons/drop_off.svg',
            ),
            SizedBox(height: size.height * 0.03),
            _buildPickupTimeSelector(),
            SizedBox(height: size.height * 0.02),
            Divider(color: grey),
            SizedBox(height: size.height * 0.02),
            _buildContinueButton(isOneWay: true),
          
              
          ],
        ),
      ),
    );
  }

  Widget _buildByTheHourRideForm() {
    final size = MediaQuery.of(context).size;
    return Form(
      key: _formKeyhour,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pickup',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              fontFamily: "HelveticaNeueMedium",
              color: black,
            ),
          ),
          SizedBox(height: size.height * 0.015),
          _buildLocationInput(
            _pickupLocationController,
            'Pickup location',
            'assets/icons/pickup.svg',
          ),
          SizedBox(height: size.height * 0.03),
          _buildPickupTimeSelector(),
          SizedBox(height: size.height * 0.03),
          Text(
            'Duration',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              fontFamily: "HelveticaNeueMedium",
              color: black,
            ),
          ),
          SizedBox(height: size.height * 0.015),
          _buildDurationSelector(),
          SizedBox(height: size.height * 0.06),
          Divider(color: grey),
          SizedBox(height: size.height * 0.02),
          _buildContinueButton(isOneWay: false),
        ],
      ),
    );
  }

 Widget _buildLocationInput(
  TextEditingController controller,
  String hintText,
  String iconPath,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TextFormField(
        onTap: () {
          setState(() {
            isTapped = true;
          });
        },
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.all(10.0),
            child: SvgPicture.asset(iconPath, width: 20, height: 20),
          ),
          hintText: hintText,
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
            return "Please enter $hintText";
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
                offset: Offset(0, 2),)
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
                    controller.text = placePredictions[index].description;
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
Widget _builddropoffLocationInput(
  TextEditingController controller,
  String hintText,
  String iconPath,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TextFormField(
        onTap: () {
          setState(() {
            isTapped = true;
          });
        },
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.all(10.0),
            child: SvgPicture.asset(iconPath, width: 20, height: 20),
          ),
          hintText: hintText,
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
            placeAutocomplete(value, isDropoff: true); // Call with isDropoff: true
          } else {
            setState(() {
              dropoffPlacePredictions = []; // Clear drop-off suggestions
            });
          }
        },
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "Please enter $hintText";
          }
          return null;
        },
      ),
      if (dropoffPlacePredictions.isNotEmpty)
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
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: dropoffPlacePredictions.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: const Icon(Icons.location_on_outlined, color: lightblack),
                title: Text(
                  dropoffPlacePredictions[index].description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  setState(() {
                    controller.text = dropoffPlacePredictions[index].description;
                    dropoffPlacePredictions = []; // Clear suggestions after selection
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
  Widget _buildPickupTimeSelector() {
    final size = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pickup time',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            fontFamily: "HelveticaNeueMedium",
            color: black,
          ),
        ),
        SizedBox(height: size.height * 0.015),
        Row(
          children: [
            Expanded(flex: 7, child: _buildDateInput('Date', _dateController)),
            SizedBox(width: size.width * 0.02),
            Expanded(flex: 4, child: _buildTimeInput('Time', _timeController)),
          ],
        ),
      ],
    );
  }

  Widget _buildDateInput(String hint, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: () => showCustomDatePicker(context, controller),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: phonefieldtext),
        filled: true,
        fillColor: circlemenusbg,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: circlemenusborder, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: circlemenusborder, width: 2.5),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Please select a date";
        }
        return null;
      },
    );
  }

  Widget _buildTimeInput(String hint, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: () => showCustomTimePicker(context, controller),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: phonefieldtext),
        filled: true,
        fillColor: circlemenusbg,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: circlemenusborder, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: circlemenusborder, width: 2.5),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Please select a time";
        }
        return null;
      },
    );
  }

  Widget _buildDurationSelector() {
    return TextFormField(
      controller: _durationController,
      decoration: InputDecoration(
        hintText: 'Enter duration (hours)',
        hintStyle: TextStyle(color: phonefieldtext),
        filled: true,
        fillColor: phonefieldColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Please enter duration";
        }
        try {
          final hours = int.parse(value);
          if (hours <= 0) {
            return "Duration must be greater than 0";
          }
        } catch (e) {
          return "Please enter a valid number";
        }
        return null;
      },
    );
  }

  Widget _buildContinueButton({required bool isOneWay}) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      width: double.infinity,
      height: size.height * 0.07,
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState?.validate() ?? false) {
            final bookingProvider = Provider.of<BookingProvider>(
              context,
              listen: false,
            );

            // Set common fields
            bookingProvider.setPickupLocation(_pickupLocationController.text);
            bookingProvider.setDate(_dateController.text);
            bookingProvider.setTime(_timeController.text);

            // Set fields based on ride type
            if (isOneWay) {
              bookingProvider.setDropoffLocation(
                _dropoffLocationController.text,
              );
            } else {
              bookingProvider.setTime(_durationController.text);
            }

            Navigator.pushNamed(context, '/choosevehicle');
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Continue',
          style: TextStyle(color: bgColor, fontSize: 16),
        ),
      ),
    );
  }
}
