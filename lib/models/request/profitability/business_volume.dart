/// Represents business volume information for a customer.
class BusinessVolume {
  /// Creates a [BusinessVolume] instance.
  BusinessVolume({
    this.businessVolumeId,
    this.natureOfBusiness,
    this.previousYear,
    this.currentYearYtd,
    this.estimatesForNextYear,
  });

  /// Creates a [BusinessVolume] instance from a JSON map.
  BusinessVolume.fromJson(Map<String, dynamic> json) {
    businessVolumeId = json["businessVolumeId"];
    natureOfBusiness = json["natureOfBusiness"] ?? "";
    previousYear = json["previousYear"] ?? "";
    currentYearYtd = json["currentYearYtd"] ?? "";
    estimatesForNextYear = json["estimatesForNextYear"]?.toString();
  }

  /// Business volume identifier.
  int? businessVolumeId;

  /// Nature of business.
  String? natureOfBusiness;

  /// Previous year value.
  String? previousYear;

  /// Current year YTD value.
  String? currentYearYtd;

  /// Estimated value for next year.
  String? estimatesForNextYear;

  /// Converts this [BusinessVolume] instance to a JSON map.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data["businessVolumeId"] = businessVolumeId;
    data["natureOfBusiness"] = natureOfBusiness;
    data["previousYear"] = previousYear;
    data["currentYearYtd"] = currentYearYtd;
    data["estimatesForNextYear"] = estimatesForNextYear;
    return data;
  }
}
