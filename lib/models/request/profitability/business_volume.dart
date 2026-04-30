class BusinessVolume {
  BusinessVolume({
    this.businessVolumeId,
    this.natureOfBusiness,
    this.previousYear,
    this.currentYearYtd,
    this.estimatesForNextYear,
  });

  BusinessVolume.fromJson(Map<String, dynamic> json) {
    businessVolumeId = json["businessVolumeId"];
    natureOfBusiness = json["natureOfBusiness"] ?? "";
    previousYear = json["previousYear"] ?? "";
    currentYearYtd = json["currentYearYtd"] ?? "";
    estimatesForNextYear = (json["estimatesForNextYear"])?.toString();
  }
  int? businessVolumeId; // Added for API compatibility
  String? natureOfBusiness;
  String? previousYear;
  String? currentYearYtd;
  String? estimatesForNextYear;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["businessVolumeId"] = businessVolumeId;
    data["natureOfBusiness"] = natureOfBusiness;
    data["previousYear"] = previousYear;
    data["currentYearYtd"] = currentYearYtd;
    data["estimatesForNextYear"] = estimatesForNextYear;
    return data;
  }
}
