/// Represents a country with identification and description details.
class Country {
  /// Creates a [Country] instance with optional fields.
  Country({this.code, this.description});

  /// Creates a [Country] instance from a JSON map.
  Country.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    code = json["countryCode"];
    description = json["description"];
  }

  /// Unique identifier for the country.
  int? id;

  /// Country code (e.g., ISO code).
  String? code;

  /// Description or name of the country.
  String? description;

  /// Converts this object to a JSON map.
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data["id"] = id;
    data["countryCode"] = code;
    data["description"] = description;
    return data;
  }
}
