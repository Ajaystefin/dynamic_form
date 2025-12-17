class BusinessVolume {
  int? businessVolumeId; // Added for API compatibility
  String? natureOfBusiness;
  double? previousYear;
  double? currentYearYtd;
  double? estimatesForNextYear;

  BusinessVolume({
    this.businessVolumeId,
    this.natureOfBusiness,
    this.previousYear,
    this.currentYearYtd,
    this.estimatesForNextYear,
  });

  BusinessVolume.fromJson(Map<String, dynamic> json) {
    businessVolumeId = json['businessVolumeId'];
    natureOfBusiness = json['natureOfBusiness'];
    previousYear = (json['previousYear'] as num?)?.toDouble();
    currentYearYtd = (json['currentYearYtd'] as num?)?.toDouble();
    estimatesForNextYear = (json['estimatesForNextYear'] as num?)?.toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['businessVolumeId'] = businessVolumeId;
    data['natureOfBusiness'] = natureOfBusiness;
    data['previousYear'] = previousYear;
    data['currentYearYtd'] = currentYearYtd;
    data['estimatesForNextYear'] = estimatesForNextYear;
    return data;
  }
}
