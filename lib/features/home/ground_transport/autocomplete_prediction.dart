
class AutocompletePrediction {
  final String description;
  final String placeId;
  final String reference;
  final StructuredFormatting? structuredFormatting;

  AutocompletePrediction({
    required this.description,
    required this.placeId,
    required this.reference,
    this.structuredFormatting,
  });

  factory AutocompletePrediction.fromJson(Map<String, dynamic> json) {
    return AutocompletePrediction(
      description: json['description'] as String? ?? "", // ✅ Handle null
      placeId: json['place_id'] as String? ?? "",       // ✅ Handle null
      reference: json['reference'] as String? ?? "",    // ✅ Handle null
      structuredFormatting: json['structured_formatting'] != null
          ? StructuredFormatting.fromJson(json['structured_formatting'])
          : null, // ✅ Handle null case
    );
  }
}


class StructuredFormatting {
  final String? mainText;
  final String? secondaryText;
  StructuredFormatting({this.mainText, this.secondaryText});

  factory StructuredFormatting.fromJson(Map<String, dynamic> json) {
    return StructuredFormatting(
      mainText: json['main_text'] ?? "",
      secondaryText: json['secondary_text'] ?? "",
    );
  }
}
