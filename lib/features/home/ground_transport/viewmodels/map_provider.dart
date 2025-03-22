// booking_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gyde/core/constants/api_key.dart';
import 'package:gyde/features/home/ground_transport/autocomplete_prediction.dart';
import 'package:gyde/features/home/ground_transport/autocomplete_response.dart';
import 'package:gyde/features/home/ground_transport/network_repo.dart';

class MapProvider extends ChangeNotifier {
  // Form Controllers
  final TextEditingController pickupController = TextEditingController();
  final TextEditingController dropoffController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController durationController = TextEditingController();

  // Map State
  late GoogleMapController mapController;
  final Set<Marker> markers = {};
  LatLng initialPosition = const LatLng(33.7463, 72.8397);
  bool isLoading = true;
  String mapStyle = "";

  // Autocomplete
  List<AutocompletePrediction> placePredictions = [];

  // Form Keys
  final GlobalKey<FormState> oneWayFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> hourlyFormKey = GlobalKey<FormState>();

  Future<void> initializeMap() async {
    await _loadMapStyle();
    await _getCurrentLocation();
  }

  Future<void> _loadMapStyle() async {
    mapStyle = await rootBundle.loadString('assets/map_style.json');
    notifyListeners();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        isLoading = false;
        await Geolocator.requestPermission();
        notifyListeners();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          isLoading = false;
          notifyListeners();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        isLoading = false;
        notifyListeners();
        return;
      }

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> zoomToCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition();
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 15,
        ),
      ),
    );

    markers.clear();
    markers.add(
      Marker(
        markerId: const MarkerId("current_location"),
        position: LatLng(position.latitude, position.longitude),
        infoWindow: const InfoWindow(title: "Your Location"),
      ),
    );
    notifyListeners();
  }

  Future<void> placeAutocomplete(String query) async {
    if (query.isEmpty) {
      placePredictions = [];
      notifyListeners();
      return;
    }

    Uri uri = Uri.https(
      "maps.googleapis.com",
      '/maps/api/place/autocomplete/json',
      {"input": query, "key": googleApiKey, "components": "country:pk"},
    );

    String? response = await NetworkUtil.fetchUrl(uri);
    if (response != null) {
      try {
        placePredictions = PlaceAutoCompleteResponse
          .parseAutoCompleteResult(response)
          .predictions;
      } catch (e) {
        placePredictions = [];
      }
      notifyListeners();
    }
  }

  void selectLocation(AutocompletePrediction prediction) {
    pickupController.text = prediction.description;
    placePredictions = [];
    notifyListeners();
  }

  void handleContinue(BuildContext context, bool isOneWay) {
    if ((isOneWay ? oneWayFormKey : hourlyFormKey).currentState?.validate() ?? false) {
      if (isOneWay) {
        // Handle one-way booking logic
      } else {
        // Handle hourly booking logic
      }
      Navigator.pushNamed(context, '/choosevehicle');
    }
  }

  @override
  void dispose() {
    pickupController.dispose();
    dropoffController.dispose();
    dateController.dispose();
    timeController.dispose();
    durationController.dispose();
    super.dispose();
  }
}

