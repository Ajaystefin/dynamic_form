class ApplicationTypeItem {
  const ApplicationTypeItem({
    required this.name,
    required this.subType,
    this.segment = "",
    this.ref2 = "",
  });

  /// Constructs from a Reference API response map.
  /// Uses raw keys as received from backend.
  factory ApplicationTypeItem.fromReference(Map<String, dynamic> json) {
    return ApplicationTypeItem(
      name: json["name"] as String? ?? "",
      subType: json["reference3"] as String? ?? "",
      segment: json["reference1"] as String? ?? "",
      ref2: json["reference2"] as String? ?? "",
    );
  }

  factory ApplicationTypeItem.fromMockMap(Map<String, String> json) {
    return ApplicationTypeItem(
      name: json["name"] ?? "",
      subType: json["subType"] ?? "",
      segment: json["reference1"] ?? "",
      ref2: json["reference2"] ?? "",
    );
  }
  final String name;
  final String subType;
  final String segment;
  final String ref2;

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "reference1": segment,
      "reference2": ref2,
      "reference3": subType,
    };
  }

  @override
  String toString() => name;
}
