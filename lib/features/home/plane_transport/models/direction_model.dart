// directions_models.dart

class DirectionsResponse {
  final String status;
  final List<Route> routes;

  DirectionsResponse({
    required this.status,
    required this.routes,
  });

  factory DirectionsResponse.fromJson(Map<String, dynamic> json) {
    return DirectionsResponse(
      status: json['status'] ?? '',
      routes: json['routes'] != null
          ? List<Route>.from(json['routes'].map((x) => Route.fromJson(x)))
          : [],
    );
  }
}

class Route {
  final String summary;
  final List<Leg> legs;
  final OverviewPolyline overviewPolyline;
  final Bounds bounds;

  Route({
    required this.summary,
    required this.legs,
    required this.overviewPolyline,
    required this.bounds,
  });

  factory Route.fromJson(Map<String, dynamic> json) {
    return Route(
      summary: json['summary'] ?? '',
      legs: json['legs'] != null
          ? List<Leg>.from(json['legs'].map((x) => Leg.fromJson(x)))
          : [],
      overviewPolyline: OverviewPolyline.fromJson(json['overview_polyline'] ?? {}),
      bounds: Bounds.fromJson(json['bounds'] ?? {}),
    );
  }
}

class Leg {
  final DistanceInfo distance;
  final DurationInfo duration;
  final String startAddress;
  final String endAddress;
  final Location startLocation;
  final Location endLocation;
  final List<Step> steps;

  Leg({
    required this.distance,
    required this.duration,
    required this.startAddress,
    required this.endAddress,
    required this.startLocation,
    required this.endLocation,
    required this.steps,
  });

  factory Leg.fromJson(Map<String, dynamic> json) {
    return Leg(
      distance: DistanceInfo.fromJson(json['distance'] ?? {}),
      duration: DurationInfo.fromJson(json['duration'] ?? {}),
      startAddress: json['start_address'] ?? '',
      endAddress: json['end_address'] ?? '',
      startLocation: Location.fromJson(json['start_location'] ?? {}),
      endLocation: Location.fromJson(json['end_location'] ?? {}),
      steps: json['steps'] != null
          ? List<Step>.from(json['steps'].map((x) => Step.fromJson(x)))
          : [],
    );
  }
}

class DistanceInfo {
  final String text;
  final int value;

  DistanceInfo({
    required this.text,
    required this.value,
  });

  factory DistanceInfo.fromJson(Map<String, dynamic> json) {
    return DistanceInfo(
      text: json['text'] ?? '',
      value: json['value'] ?? 0,
    );
  }
}

class DurationInfo {
  final String text;
  final int value;

  DurationInfo({
    required this.text,
    required this.value,
  });

  factory DurationInfo.fromJson(Map<String, dynamic> json) {
    return DurationInfo(
      text: json['text'] ?? '',
      value: json['value'] ?? 0,
    );
  }
}

class Location {
  final double lat;
  final double lng;

  Location({
    required this.lat,
    required this.lng,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      lat: json['lat']?.toDouble() ?? 0.0,
      lng: json['lng']?.toDouble() ?? 0.0,
    );
  }
}

class Step {
  final DistanceInfo distance;
  final DurationInfo duration;
  final Location startLocation;
  final Location endLocation;
  final String htmlInstructions;
  final String travelMode;
  final PolylinePoints polyline;

  Step({
    required this.distance,
    required this.duration,
    required this.startLocation,
    required this.endLocation,
    required this.htmlInstructions,
    required this.travelMode,
    required this.polyline,
  });

  factory Step.fromJson(Map<String, dynamic> json) {
    return Step(
      distance: DistanceInfo.fromJson(json['distance'] ?? {}),
      duration: DurationInfo.fromJson(json['duration'] ?? {}),
      startLocation: Location.fromJson(json['start_location'] ?? {}),
      endLocation: Location.fromJson(json['end_location'] ?? {}),
      htmlInstructions: json['html_instructions'] ?? '',
      travelMode: json['travel_mode'] ?? '',
      polyline: PolylinePoints.fromJson(json['polyline'] ?? {}),
    );
  }
}

class PolylinePoints {
  final String points;

  PolylinePoints({
    required this.points,
  });

  factory PolylinePoints.fromJson(Map<String, dynamic> json) {
    return PolylinePoints(
      points: json['points'] ?? '',
    );
  }
}

class OverviewPolyline {
  final String points;

  OverviewPolyline({
    required this.points,
  });

  factory OverviewPolyline.fromJson(Map<String, dynamic> json) {
    return OverviewPolyline(
      points: json['points'] ?? '',
    );
  }
}

class Bounds {
  final Location northeast;
  final Location southwest;

  Bounds({
    required this.northeast,
    required this.southwest,
  });

  factory Bounds.fromJson(Map<String, dynamic> json) {
    return Bounds(
      northeast: Location.fromJson(json['northeast'] ?? {}),
      southwest: Location.fromJson(json['southwest'] ?? {}),
    );
  }
}