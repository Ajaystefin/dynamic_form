/// Represents an application type item with name, subtype,
/// segment, and secondary reference details.
class ApplicationTypeItem {
  /// Creates an [ApplicationTypeItem] instance.
  const ApplicationTypeItem({
    required this.name,
    required this.subType,
    this.segment = "",
    this.ref2 = "",
  });

  /// Creates an [ApplicationTypeItem] from a Reference API response map.
  ///
  /// This factory uses the raw reference keys received from the backend.
  factory ApplicationTypeItem.fromReference(Map<String, dynamic> json) {
    return ApplicationTypeItem(
      name: json["name"] as String? ?? "",
      subType: json["reference3"] as String? ?? "",
      segment: json["reference1"] as String? ?? "",
      ref2: json["reference2"] as String? ?? "",
    );
  }

  /// Creates an [ApplicationTypeItem] from a mock map.
  ///
  /// This factory is mainly used for local mock data where all values
  /// are represented as strings.
  factory ApplicationTypeItem.fromMockMap(Map<String, String> json) {
    return ApplicationTypeItem(
      name: json["name"] ?? "",
      subType: json["subType"] ?? "",
      segment: json["reference1"] ?? "",
      ref2: json["reference2"] ?? "",
    );
  }

  /// Display name of the application type.
  final String name;

  /// Subtype value of the application type.
  final String subType;

  /// Segment value mapped from `reference1`.
  final String segment;

  /// Secondary reference value mapped from `reference2`.
  final String ref2;

  /// Converts this [ApplicationTypeItem] instance into a JSON map.
  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "reference1": segment,
      "reference2": ref2,
      "reference3": subType,
    };
  }

  /// Returns the display name of this application type item.
  @override
  String toString() => name;
}
